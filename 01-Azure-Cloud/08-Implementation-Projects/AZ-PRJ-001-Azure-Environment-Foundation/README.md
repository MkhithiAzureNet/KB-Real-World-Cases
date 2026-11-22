# AZ-PRJ-001 — Azure Environment Foundation

**Category:** Azure Cloud / Implementation Projects  
**Project ID:** AZ-PRJ-001  
**Platform:** Microsoft Azure  
**Implementation Approach:** Terraform with Azure Portal and Azure CLI validation  
**Status:** Documentation in Progress  
**Project Period:** Labs 01–01.5  
**Request Owner:** CTO — source evidence pending

---

## 1. Project Context

AZ-PRJ-001 is the parent implementation record for the Azure environment foundation built in response to CTO-led requests. Rather than treating the work as isolated labs, this project preserves the engineering story: the business request, design and implementation decisions, validation evidence, issues encountered, and lessons learned.

The original **Email 001** initiated the environment work. Its original wording and date have not yet been added to this repository and must be attached as source evidence before a detailed requirement record is written. Subsequent CTO emails have not been supplied and are intentionally not reconstructed here.

## 2. Scope and Milestones

The project covers the foundation and workload steps completed across Labs 01–01.5.

| Milestone | Focus | Documentation State |
|---|---|---|
| Email 001 / Lab 01 | Initial production and development network foundation, subnets, and VNet peering | Pending detailed evidence record |
| Lab 01.2 | Database-subnet Network Security Groups and SQL access policy | Pending detailed implementation case |
| Lab 01.3 | Azure virtual machines, network interfaces, and private addressing | Pending detailed implementation case |
| Lab 01.4 | Cloud-init, outbound connectivity, and NAT Gateway | Pending detailed implementation case |
| Lab 01.5 | SQL Server 2022, managed identity, Key Vault, and SQL validation | Pending detailed implementation case |

This README is the project index only. It does not replace the five milestone documents listed below.

## 3. Architecture Summary

The environment was built as separate production and development Azure network contexts. The foundation includes segmented application and database subnets, VNet peering, and database-subnet NSGs intended to permit SQL traffic only from the matching application subnet. Later milestones added workload VMs, cloud-init-based configuration, outbound connectivity through a NAT Gateway, and a development SQL Server integration using managed identity and Azure Key Vault.

```text
Production VNet                         Development VNet
  Application subnet                      Application subnet
        |                                       |
  Database subnet / NSG  <--- VNet peering --->  Database subnet / NSG
        |                                       |
  Workload resources                       VM, SQL Server, managed identity,
                                           Key Vault, outbound connectivity
```

Architecture details, resource names, IP ranges, and deviations will be recorded only in the relevant milestone documents and backed by Terraform, portal, CLI, or test evidence.

## 4. Documentation Map

| Area | Location | Purpose |
|---|---|---|
| CTO requests and traceability | [01-Requirements](01-Requirements/README.md) | Preserve request evidence and map each request to work completed |
| Implementation milestones | [02-Implementation](02-Implementation/README.md) | Hold the five detailed, evidence-based implementation cases |
| Incidents and investigations | [03-Troubleshooting](03-Troubleshooting/README.md) | Record material failures separately when they warrant a standalone case |
| Screenshots and diagrams | [images](images/README.md) | Store supporting visual evidence referenced from Markdown |

Planned milestone documents — not created in this deliverable:

1. `AZ-001-Network-Infrastructure.md` — Email 001 / Lab 01
2. `AZ-002-Network-Security-Groups.md` — Lab 01.2
3. `AZ-003-Virtual-Machine-Deployment.md` — Lab 01.3
4. `AZ-004-Cloud-Init-and-Outbound-Connectivity.md` — Lab 01.4
5. `AZ-005-SQL-Server-and-Key-Vault-Integration.md` — Lab 01.5

## 5. Evidence and Traceability

Each milestone must distinguish between configured, observed, and tested states.

| Evidence Type | Examples | Use in This Project |
|---|---|---|
| Request evidence | CTO email, ticket, approved change | Establishes why the work was requested and the acceptance criteria |
| Implementation evidence | Terraform configuration, Azure activity records, portal screenshots | Shows what was deployed or configured |
| Validation evidence | CLI output, connection tests, SQL query output | Confirms what was actually tested |
| Issue evidence | Error output, investigation notes, remediation steps | Supports the troubleshooting and lessons-learned record |

**Source-evidence gap:** Attach Email 001 and any later CTO requests before documenting their exact instructions, dates, or acceptance criteria. Do not infer missing content from the lab names.

## 6. Challenges and Lessons Learned to Capture

The detailed cases will document the actual engineering issues encountered, including outbound package-download failures, a missing Microsoft tools repository, non-interactive SQL setup considerations, Key Vault authentication issues, and the final successful SQL query. These points remain pending their supporting commands, screenshots, and chronology.

- Keep the original business instruction separate from the technical implementation.
- Record an issue only with its observed symptom, investigation, root cause, resolution, and validation.
- Do not present a configured NSG rule as proof of successful end-to-end SQL connectivity.
- Treat a significant incident as a standalone troubleshooting case while retaining a concise summary in its implementation milestone.

## 7. Validation Boundaries

This initial artifact establishes the documentation structure; it does **not** certify the current state of Azure resources.

Later milestone documents should claim validation only where supporting evidence is included, for example:

- Resource deployment and intended associations.
- VNet peering state.
- NSG rule configuration and subnet association.
- Authorised and unauthorised network-path tests.
- VM configuration, outbound package access, and SQL Server operation.
- Managed-identity access to Key Vault and the final SQL query result.

## 8. Security Notes

- Apply least privilege to NSG rules, managed identities, Azure RBAC, and Key Vault access.
- Record rule priority and scope; broad deny rules can override Azure default virtual-network and load-balancer traffic allowances.
- Keep secrets out of Terraform state, terminal transcripts, screenshots, and this repository.
- Redact public IP addresses, account identifiers, tokens, passwords, and connection strings before publishing evidence.

## 9. Cost Notes

NAT Gateway and public IP resources can create ongoing charges. The environment should be documented before any cost optimisation or cleanup work so the implemented state and a later removal or change are clearly separated. No Azure resource changes are made by this documentation project.

## 10. Next Documentation Steps

1. Add Email 001 as source evidence and create its requirement record.
2. Create the five milestone implementation documents in order, using the documented case format.
3. Add redacted evidence and cross-link it from each milestone.
4. Record material troubleshooting cases and final validation results.
5. Document any later cost-optimisation change separately from the original implementation.

---

**Document Owner:** Nhlanhla  
**Knowledge Base Reference:** AZ-PRJ-001  
**Category:** Azure Cloud / Implementation Projects

