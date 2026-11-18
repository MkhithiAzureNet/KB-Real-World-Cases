#requires -Version 5.1
<#
SEC-001 - External Document Triage v1.2
Purpose:
  Perform safe, static triage of an externally received Office document or PDF.
  The script does NOT open the document in Word, execute macros, follow links,
  extract files to disk, or upload the document to any service.

Checks:
  - File metadata and SHA256
  - Microsoft Defender custom scan (if Defender cmdlets are available)
  - DOCX/other ZIP-based Office package inventory
  - Macro / ActiveX / embedded-object indicators
  - External OOXML relationships and hyperlink destinations
  - Basic PDF structure, active-feature indicators and visible URL strings
  - Optional VirusTotal hash-only lookup (requires an API key)
  - Heuristic URL checks and severity-based triage classification
  - TXT and HTML reports

Limitations:
  - A clean scan or no VirusTotal detections is not proof of safety.
  - Sender authenticity, email headers, document meaning, and Entra ID
    configuration correctness require separate human validation.
  - VirusTotal hash lookup sends only the SHA256 hash, never the file.
  - URL checks are heuristic and do not query live reputation services.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$FilePath,

    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = "C:\Sec+\Reports",

    [Parameter(Mandatory = $false)]
    [switch]$SkipDefenderScan,

    [Parameter(Mandatory = $false)]
    [switch]$UseVirusTotal
)

$ErrorActionPreference = "Stop"
$report = New-Object System.Collections.Generic.List[string]
$findings = New-Object System.Collections.Generic.List[object]
$urlsSeen = New-Object System.Collections.Generic.List[string]
$defenderScanStatus = "Not run"
$defenderDetectionCount = 0
$vtMaliciousCount = 0
$vtSuspiciousCount = 0

function Add-Report {
    param([string]$Text = "")
    $report.Add($Text)
    Write-Host $Text
}

function Add-Finding {
    param(
        [string]$Text,
        [ValidateSet("Informational", "Low", "Medium", "High", "Critical")]
        [string]$Severity = "Medium"
    )
    $findings.Add([pscustomobject]@{ Severity = $Severity; Text = $Text })
    Add-Report("[REVIEW][$Severity] $Text")
}

function Get-RiskLevel {
    param([object[]]$Items)
    if (@($Items | Where-Object { $_.Severity -eq "Critical" }).Count -gt 0) { return "CRITICAL" }
    if (@($Items | Where-Object { $_.Severity -eq "High" }).Count -gt 0) { return "HIGH" }
    if (@($Items | Where-Object { $_.Severity -eq "Medium" }).Count -gt 0) { return "MEDIUM" }
    if (@($Items | Where-Object { $_.Severity -eq "Low" }).Count -gt 0) { return "LOW" }
    return "NO AUTOMATED INDICATORS - MANUAL REVIEW STILL REQUIRED"
}

function ConvertTo-HtmlSafe {
    param([string]$Value)
    return [System.Net.WebUtility]::HtmlEncode($Value)
}

function Get-RelativeEntryName {
    param([string]$Name)
    return $Name.Replace("\", "/")
}

try {
    if (-not $FilePath) {
        Add-Type -AssemblyName System.Windows.Forms
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Title = "Select an external Office document for SEC-001 triage"
        $dialog.Filter = "Office and PDF documents (*.pdf;*.docx;*.docm;*.dotx;*.dotm;*.xlsx;*.xlsm;*.pptx;*.pptm)|*.pdf;*.docx;*.docm;*.dotx;*.dotm;*.xlsx;*.xlsm;*.pptx;*.pptm|All files (*.*)|*.*"
        $dialog.Multiselect = $false
        if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
            Write-Host "No file selected. Exiting."
            return
        }
        $FilePath = $dialog.FileName
    }

    $item = Get-Item -LiteralPath $FilePath
    if ($item.PSIsContainer) { throw "The selected path is a folder. Select a single document." }

    if (-not (Test-Path -LiteralPath $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $safeBase = [IO.Path]::GetFileNameWithoutExtension($item.Name) -replace '[^\w.-]', '_'
    $reportPath = Join-Path $OutputDirectory ("SEC-001_{0}_{1}.txt" -f $safeBase, $timestamp)

    Add-Report "============================================================"
    Add-Report "SEC-001 - EXTERNAL DOCUMENT TRIAGE v1.2"
    Add-Report "============================================================"
    Add-Report "Started:       $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')"
    Add-Report "Computer:      $env:COMPUTERNAME"
    Add-Report "User:          $env:USERNAME"
    Add-Report "File:          $($item.FullName)"
    Add-Report ""

    # Metadata and hash
    Add-Report "--- 1. FILE METADATA ---"
    Add-Report "Name:          $($item.Name)"
    Add-Report "Extension:     $($item.Extension)"
    Add-Report "Size (bytes):  $($item.Length)"
    Add-Report "Created:       $($item.CreationTime)"
    Add-Report "Modified:      $($item.LastWriteTime)"
    try {
        Get-Item -LiteralPath $item.FullName -Stream Zone.Identifier -ErrorAction Stop | Out-Null
        $zoneText = Get-Content -LiteralPath $item.FullName -Stream Zone.Identifier -ErrorAction Stop
        Add-Report "Mark-of-the-Web stream:"
        $zoneText | ForEach-Object { Add-Report "  $_" }
    } catch {
        Add-Report "Mark-of-the-Web stream: Not present or not readable."
    }

    $hash = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash
    Add-Report "SHA256:        $hash"
    Add-Report ""

    # Defender scan and detection review
    Add-Report "--- 2. MICROSOFT DEFENDER ---"
    if ($SkipDefenderScan) {
        $defenderScanStatus = "Skipped by user"
        Add-Report $defenderScanStatus
    } else {
        try {
            $startScanTime = Get-Date
            $startMpScan = Get-Command Start-MpScan -ErrorAction SilentlyContinue
            if ($startMpScan) {
                Add-Report "Requesting Microsoft Defender custom scan of the selected file..."
                Start-MpScan -ScanType CustomScan -ScanPath $item.FullName
                $defenderScanStatus = "Custom scan requested; completion must be confirmed in Windows Security Protection History"
                Add-Report "Scan request submitted. This script does not assume that command return alone proves a completed, clean scan."

                try {
                    $mpStatus = Get-MpComputerStatus
                    Add-Report "Antivirus enabled: $($mpStatus.AntivirusEnabled)"
                    Add-Report "Real-time protection enabled: $($mpStatus.RealTimeProtectionEnabled)"
                    Add-Report "Signature version: $($mpStatus.AntivirusSignatureVersion)"
                    Add-Report "Signature last updated: $($mpStatus.AntivirusSignatureLastUpdated)"
                    if (-not $mpStatus.AntivirusEnabled) {
                        Add-Finding "Microsoft Defender Antivirus reports that antivirus protection is not enabled." "High"
                    }
                    if (-not $mpStatus.RealTimeProtectionEnabled) {
                        Add-Finding "Microsoft Defender real-time protection is not enabled." "Medium"
                    }
                } catch {
                    Add-Report "Defender status query unavailable: $($_.Exception.Message)"
                }

                try {
                    $detections = @(Get-MpThreatDetection -ErrorAction Stop | Where-Object {
                        $_.InitialDetectionTime -and ([datetime]$_.InitialDetectionTime) -ge $startScanTime.AddMinutes(-2)
                    })
                    $defenderDetectionCount = $detections.Count
                    Add-Report "Recent Defender detections since scan request (approximate time filter): $defenderDetectionCount"
                    foreach ($detection in $detections) {
                        Add-Report "Detection: ThreatID=$($detection.ThreatID); DetectionTime=$($detection.InitialDetectionTime); ActionSuccess=$($detection.ActionSuccess)"
                        Add-Finding "Microsoft Defender reports a recent threat detection. Review Protection History and incident handling procedures." "Critical"
                    }
                    if ($defenderDetectionCount -eq 0) {
                        Add-Report "No recent detections were returned by Get-MpThreatDetection. This is not proof that the scan completed cleanly."
                    }
                } catch {
                    Add-Report "Could not query Defender threat detections: $($_.Exception.Message)"
                    $defenderScanStatus = "Scan requested; detection query unavailable; verify Protection History"
                }
                Add-Report "Required verification: Windows Security > Virus & threat protection > Protection history."
            } else {
                $defenderScanStatus = "Defender PowerShell cmdlets unavailable"
                Add-Report $defenderScanStatus
            }
        } catch {
            $defenderScanStatus = "Scan request failed"
            Add-Report "Defender scan could not be started or queried: $($_.Exception.Message)"
            Add-Report "Use Windows Security to scan the file and review Protection History."
        }
    }
    Add-Report ""

    # ZIP-based OOXML inspection
    Add-Report "--- 3. OFFICE PACKAGE / ARCHIVE INSPECTION ---"
    $zipExtensions = @(".docx", ".docm", ".dotx", ".dotm", ".xlsx", ".xlsm", ".xltx", ".xltm", ".pptx", ".pptm", ".potx", ".potm", ".ppsx", ".ppsm")
    $isZipOffice = $zipExtensions -contains $item.Extension.ToLowerInvariant()

    if ($isZipOffice) {
        Add-Type -AssemblyName System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $archive = $null
        try {
            $archive = [System.IO.Compression.ZipFile]::OpenRead($item.FullName)
            Add-Report "Archive entries: $($archive.Entries.Count)"
            foreach ($entry in $archive.Entries) {
                Add-Report ("  {0} ({1} bytes)" -f $entry.FullName, $entry.Length)
            }

            $entryNames = @($archive.Entries | ForEach-Object { Get-RelativeEntryName $_.FullName })

            $macroEntries = @($entryNames | Where-Object { $_ -match 'vbaProject\.bin$' })
            $activeXEntries = @($entryNames | Where-Object { $_ -match '(^|/)activeX/' })
            $embeddingEntries = @($entryNames | Where-Object { $_ -match '(^|/)embeddings/' })
            $oleEntries = @($entryNames | Where-Object { $_ -match 'oleObject' })

            Add-Report ""
            Add-Report "Indicators:"
            Add-Report "VBA project entries: $($macroEntries.Count)"
            Add-Report "ActiveX entries:     $($activeXEntries.Count)"
            Add-Report "Embedded entries:    $($embeddingEntries.Count)"
            Add-Report "OLE object entries:  $($oleEntries.Count)"

            if ($macroEntries.Count -gt 0) { Add-Finding "VBA project found. Verify whether macros are expected and inspect in an isolated analysis workflow." "High" }
            if ($activeXEntries.Count -gt 0) { Add-Finding "ActiveX components found; inspect before opening." "High" }
            if ($embeddingEntries.Count -gt 0 -or $oleEntries.Count -gt 0) { Add-Finding "Embedded/OLE content found; identify and inspect the embedded objects." "Medium" }

            # Inspect OOXML relationship files without extracting archive contents.
            Add-Report ""
            Add-Report "--- 4. EXTERNAL RELATIONSHIPS / HYPERLINKS ---"
            $relationshipEntries = @($archive.Entries | Where-Object { $_.FullName -match '(^|/)_rels/[^/]+\.rels$' })
            $externalRelationshipCount = 0

            foreach ($relEntry in $relationshipEntries) {
                $stream = $null
                $reader = $null
                try {
                    $stream = $relEntry.Open()
                    $reader = New-Object System.IO.StreamReader($stream)
                    [xml]$relXml = $reader.ReadToEnd()
                    foreach ($rel in $relXml.Relationships.Relationship) {
                        $targetMode = [string]$rel.TargetMode
                        $type = [string]$rel.Type
                        $target = [string]$rel.Target
                        if ($targetMode -eq "External" -or $type -match 'hyperlink') {
                            $externalRelationshipCount++
                            Add-Report "Relationship file: $($relEntry.FullName)"
                            Add-Report "  Id:         $($rel.Id)"
                            Add-Report "  Type:       $type"
                            Add-Report "  TargetMode: $targetMode"
                            Add-Report "  Target:     $target"

                            if ($target -match '^(?i)https?://') {
                                try {
                                    $uri = [System.Uri]$target
                                    Add-Report "  Host:       $($uri.Host)"
                                    if (-not $urlsSeen.Contains($target)) { $urlsSeen.Add($target) }
                                    Add-Finding "External URL requires human verification: $target" "Low"
                                    if ($uri.Scheme -ne "https") {
                                        Add-Finding "Non-HTTPS external URL found: $target" "High"
                                    }
                                    if ($uri.UserInfo) {
                                        Add-Finding "URL contains user-info credentials: $target" "High"
                                    }
                                    if ($uri.Host -match '(^|\.)xn--') {
                                        Add-Finding "Internationalized/punycode hostname found; verify carefully: $($uri.Host)" "Medium"
                                    }
                                    if ($uri.Host -match '^(\d{1,3}\.){3}\d{1,3}$') {
                                        Add-Finding "URL uses an IP-literal host rather than a DNS hostname: $($uri.Host)" "Medium"
                                    }
                                    if ($uri.Host -match '(bit\.ly|tinyurl\.com|t\.co|goo\.gl|is\.gd|cutt\.ly)$') {
                                        Add-Finding "URL uses a known URL-shortening domain; expand and verify the final destination through an approved process." "Medium"
                                    }
                                } catch {
                                    Add-Finding "Could not parse external relationship target: $target"
                                }
                            } else {
                                Add-Finding "External relationship is not a standard HTTP(S) URL: $target"
                            }
                        }
                    }
                } catch {
                    Add-Finding "Could not parse relationship file $($relEntry.FullName): $($_.Exception.Message)"
                } finally {
                    if ($reader) { $reader.Dispose() }
                    elseif ($stream) { $stream.Dispose() }
                }
            }
            Add-Report "External relationships found: $externalRelationshipCount"
            if ($externalRelationshipCount -eq 0) {
                Add-Report "No external relationships were identified in the inspected relationship files."
            }
        } finally {
            if ($archive) { $archive.Dispose() }
        }
    } elseif ($item.Extension -ieq ".pdf") {
        Add-Report "PDF detected. Performing a basic static byte-level inspection (no PDF viewer is launched)."
        Add-Report "NOTE: This is heuristic inspection. Compressed object streams, obfuscation and advanced PDF features may not be fully decoded."

        $bytes = [System.IO.File]::ReadAllBytes($item.FullName)
        $pdfText = [System.Text.Encoding]::Latin1.GetString($bytes)

        if ($pdfText.StartsWith("%PDF-")) {
            Add-Report "PDF header: Present"
        } else {
            Add-Finding "Expected PDF header was not found at the beginning of the file."
        }

        if ($pdfText -match '%%EOF') {
            Add-Report "PDF end marker: Present"
        } else {
            Add-Finding "PDF end marker %%EOF was not found."
        }

        $pdfIndicators = @(
            @{ Name = "JavaScript name (/JavaScript)"; Pattern = '/JavaScript\b' },
            @{ Name = "JavaScript action (/JS)"; Pattern = '/JS\b' },
            @{ Name = "Document open action (/OpenAction)"; Pattern = '/OpenAction\b' },
            @{ Name = "Additional actions (/AA)"; Pattern = '/AA\b' },
            @{ Name = "Launch action (/Launch)"; Pattern = '/Launch\b' },
            @{ Name = "Embedded files (/EmbeddedFiles)"; Pattern = '/EmbeddedFiles\b' },
            @{ Name = "File specification (/Filespec)"; Pattern = '/Filespec\b' },
            @{ Name = "Rich media (/RichMedia)"; Pattern = '/RichMedia\b' },
            @{ Name = "AcroForm (/AcroForm)"; Pattern = '/AcroForm\b' },
            @{ Name = "XFA forms (/XFA)"; Pattern = '/XFA\b' },
            @{ Name = "URI actions (/URI)"; Pattern = '/URI\b' },
            @{ Name = "Encryption dictionary (/Encrypt)"; Pattern = '/Encrypt\b' },
            @{ Name = "Object streams (/ObjStm)"; Pattern = '/ObjStm\b' }
        )

        Add-Report ""
        Add-Report "PDF feature indicators (presence is not proof of maliciousness):"
        foreach ($indicator in $pdfIndicators) {
            $count = ([regex]::Matches($pdfText, $indicator.Pattern)).Count
            Add-Report ("{0}: {1}" -f $indicator.Name, $count)
            if ($count -gt 0 -and $indicator.Name -match 'JavaScript|Launch action|Document open action|Additional actions|Embedded files|Rich media') {
                $pdfSeverity = "High"
                if ($indicator.Name -match 'Embedded files|Rich media') { $pdfSeverity = "Medium" }
                Add-Finding "PDF contains potentially active or embedded feature indicator: $($indicator.Name). Review with an approved PDF analysis tool." $pdfSeverity
            }
        }

        $uriMatches = [regex]::Matches($pdfText, '(?i)https?://[^\s<>()\[\]{}"''`]+')
        $uniqueUris = @($uriMatches | ForEach-Object { $_.Value.TrimEnd('.', ',', ';') } | Sort-Object -Unique)
        Add-Report ""
        Add-Report "HTTP(S) URL strings found in raw PDF bytes: $($uniqueUris.Count)"
        foreach ($uri in $uniqueUris) {
            Add-Report "  URL: $uri"
            try {
                $parsedUri = [System.Uri]$uri
                Add-Report "  Host: $($parsedUri.Host)"
                if (-not $urlsSeen.Contains($uri)) { $urlsSeen.Add($uri) }
                Add-Finding "PDF URL string requires human verification: $uri" "Low"
                if ($parsedUri.Scheme -ne "https") {
                    Add-Finding "PDF contains a non-HTTPS URL string: $uri" "High"
                }
                if ($parsedUri.UserInfo) {
                    Add-Finding "PDF URL contains user-info credentials: $uri" "High"
                }
            } catch {
                Add-Finding "Could not parse PDF URL string: $uri"
            }
        }

        if ($pdfText -match '/Encrypt\b') {
            Add-Finding "PDF appears to contain an encryption dictionary. Content inspection may be limited, especially if password protected."
        }
        if ($pdfText -match '/ObjStm\b') {
            Add-Report "Object streams detected. Some PDF objects may not be visible to this simple byte-level scan."
        }

        # Optional deeper inspection with common command-line PDF utilities if installed.
        $pdfinfo = Get-Command pdfinfo -ErrorAction SilentlyContinue
        $qpdf = Get-Command qpdf -ErrorAction SilentlyContinue
        $mutool = Get-Command mutool -ErrorAction SilentlyContinue
        Add-Report ""
        Add-Report "Optional PDF analysis utilities:"
        Add-Report "pdfinfo available: $([bool]$pdfinfo)"
        Add-Report "qpdf available:    $([bool]$qpdf)"
        Add-Report "mutool available:   $([bool]$mutool)"
        if ($qpdf) {
            Add-Report "qpdf is installed. Consider a separate approved structural check, e.g. qpdf --check `"$($item.FullName)`"."
        }
        if ($pdfinfo) {
            Add-Report "pdfinfo is installed. Consider reviewing metadata separately with pdfinfo."
        }
        if ($mutool) {
            Add-Report "mutool is installed. It can provide deeper PDF object inspection under an approved workflow."
        }

    } else {
        Add-Report "The extension is not a recognised ZIP-based Office format or PDF."
        Add-Report "Legacy .doc files and other formats require separate handling; do not assume this script inspected their internal structure."
    }
    Add-Report ""

    # Optional VirusTotal hash lookup (hash only)
    Add-Report "--- 5. VIRUSTOTAL HASH LOOKUP (OPTIONAL) ---"
    if ($UseVirusTotal) {
        $apiKey = $env:VT_API_KEY
        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Add-Report "Skipped: VT_API_KEY environment variable is not set."
            Add-Report "Set it securely in your session before running with -UseVirusTotal. Do not place the key in this script."
        } else {
            try {
                $headers = @{ "x-apikey" = $apiKey }
                $vt = Invoke-RestMethod -Method Get -Uri "https://www.virustotal.com/api/v3/files/$hash" -Headers $headers
                $stats = $vt.data.attributes.last_analysis_stats
                Add-Report "VirusTotal report found for this hash."
                $vtMaliciousCount = [int]$stats.malicious
                $vtSuspiciousCount = [int]$stats.suspicious
                Add-Report "Last analysis stats: malicious=$($stats.malicious), suspicious=$($stats.suspicious), undetected=$($stats.undetected), harmless=$($stats.harmless)"
                Add-Report "Last analysis date (Unix): $($vt.data.attributes.last_analysis_date)"
                if ($vtMaliciousCount -gt 0) {
                    Add-Finding "VirusTotal reports one or more malicious detections. Do not open; escalate for security review." "Critical"
                } elseif ($vtSuspiciousCount -gt 0) {
                    Add-Finding "VirusTotal reports suspicious detections. Escalate for manual review; do not treat this as a definitive verdict." "High"
                }
            } catch {
                $statusCode = $null
                try { $statusCode = $_.Exception.Response.StatusCode.value__ } catch {}
                if ($statusCode -eq 404) {
                    Add-Report "VirusTotal has no existing report for this hash (HTTP 404). The file was NOT uploaded."
                } else {
                    Add-Report "VirusTotal lookup failed: $($_.Exception.Message)"
                }
            }
        }
    } else {
        Add-Report "Skipped. Use -UseVirusTotal only when an approved API key is configured."
    }
    Add-Report ""

    # Risk classification and summary
    Add-Report "--- 6. TRIAGE SUMMARY ---"
    Add-Report "SHA256: $hash"
    Add-Report "Defender status: $defenderScanStatus"
    Add-Report "Defender recent detections returned: $defenderDetectionCount"
    Add-Report "VirusTotal malicious detections: $vtMaliciousCount"
    Add-Report "VirusTotal suspicious detections: $vtSuspiciousCount"

    $riskLevel = Get-RiskLevel -Items ($findings.ToArray())
    Add-Report "Automated risk classification: $riskLevel"
    Add-Report "Review indicators: $($findings.Count)"
    foreach ($finding in $findings) {
        Add-Report (" - [{0}] {1}" -f $finding.Severity, $finding.Text)
    }
    if ($findings.Count -eq 0) {
        Add-Report "No automated indicators were raised. This is NOT a clean bill of health; manual review remains required."
    }

    Add-Report ""
    Add-Report "IMPORTANT LIMITATIONS:"
    Add-Report "- This is triage, not a malware verdict or safety certification."
    Add-Report "- Defender scan initiation and detection queries do not independently prove scan completion; verify Protection History."
    Add-Report "- URL checks are heuristic. No live URL reputation or destination safety is asserted."
    Add-Report "- The script does not verify the sender, email authentication, or business legitimacy."
    Add-Report "- The script does not assess whether document instructions or Entra ID permissions are safe."
    Add-Report "- Do not click extracted links. Verify domains and destinations independently."
    Add-Report "- Do not upload confidential documents to public scanning services."
    Add-Report ""

    $txtReportPath = $reportPath
    $htmlReportPath = [System.IO.Path]::ChangeExtension($reportPath, ".html")
    Add-Report "Text report: $txtReportPath"
    Add-Report "HTML report: $htmlReportPath"

    $report | Set-Content -LiteralPath $txtReportPath -Encoding UTF8

    $htmlLines = foreach ($line in $report) {
        $safe = ConvertTo-HtmlSafe -Value $line
        if ($line -match '^\[REVIEW\]\[(Critical|High)\]') {
            "<div class='finding high'>$safe</div>"
        } elseif ($line -match '^\[REVIEW\]') {
            "<div class='finding'>$safe</div>"
        } elseif ($line -match 'Automated risk classification:') {
            "<h2>$safe</h2>"
        } elseif ($line -match '^---') {
            "<h3>$safe</h3>"
        } elseif ([string]::IsNullOrWhiteSpace($line)) {
            "<br>"
        } else {
            "<div>$safe</div>"
        }
    }

    $riskCss = "info"
    if ($riskLevel -eq "CRITICAL") { $riskCss = "critical" }
    elseif ($riskLevel -eq "HIGH") { $riskCss = "high" }
    elseif ($riskLevel -eq "MEDIUM") { $riskCss = "medium" }
    elseif ($riskLevel -eq "LOW") { $riskCss = "low" }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>SEC-001 Triage Report - $(ConvertTo-HtmlSafe $item.Name)</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;background:#f4f6f8;color:#202938;margin:0;padding:28px}
main{max-width:1100px;margin:auto;background:#fff;padding:28px;border-radius:10px;box-shadow:0 2px 12px rgba(0,0,0,.08)}
h1{margin-top:0}h2{padding:12px;border-radius:6px;background:#eef2f7}
h3{margin-top:24px;padding-bottom:6px;border-bottom:1px solid #d8dee8;color:#263b59}
div{line-height:1.55;overflow-wrap:anywhere}
.finding{padding:8px 12px;margin:6px 0;background:#fff8e6;border-left:4px solid #d69e00}
.finding.high{background:#fff0f0;border-left-color:#c53030}
.badge{display:inline-block;padding:8px 14px;border-radius:6px;font-weight:700}
.badge.critical,.badge.high{background:#ffe0e0;color:#8a1010}
.badge.medium{background:#fff1cc;color:#704b00}
.badge.low{background:#e5f2ff;color:#174a75}
.badge.info{background:#e7edf5;color:#334155}
.notice{margin-top:24px;padding:14px;background:#f1f5f9;border-radius:6px}
</style>
</head>
<body><main>
<h1>SEC-001 – External Document Triage v1.2</h1>
<p><strong>Automated risk classification:</strong> <span class="badge $riskCss">$(ConvertTo-HtmlSafe $riskLevel)</span></p>
<p><strong>File:</strong> $(ConvertTo-HtmlSafe $item.Name)<br><strong>SHA256:</strong> $(ConvertTo-HtmlSafe $hash)</p>
<hr>
$($htmlLines -join "`n")
<div class="notice"><strong>Important:</strong> Automated triage is not a malware verdict or safety certification. Verify Defender Protection History, sender authenticity, extracted URLs, document content and any requested identity/configuration changes. Do not treat absence of automated indicators as proof of safety.</div>
</main></body></html>
"@
    Set-Content -LiteralPath $htmlReportPath -Value $html -Encoding UTF8

    Write-Host ""
    Write-Host "Triage complete." -ForegroundColor Green
    Write-Host "Text report: $txtReportPath"
    Write-Host "HTML report: $htmlReportPath"
    Write-Host "Automated classification: $riskLevel"
    Write-Host "Review all indicators and verify Windows Security Protection History."
}
catch {
    Write-Error "SEC-001 triage failed: $($_.Exception.Message)"
    throw
}
