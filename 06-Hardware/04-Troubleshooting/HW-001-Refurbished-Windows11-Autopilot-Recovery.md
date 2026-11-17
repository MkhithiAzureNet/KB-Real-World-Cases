# HW-001: Troubleshooting a Refurbished Windows 11 PC Blocked by Previous Organisation's Autopilot Registration

## 1. Case Information

| Field | Details |
|---|---|
| Case ID | HW-001 |
| Category | Hardware / Endpoint Management |
| Subcategory | Workstation Deployment / Windows Autopilot |
| Technology | Windows 11, Microsoft Entra ID, Microsoft Intune, Windows Autopilot, Active Directory |
| Tools | Windows OOBE, Command Prompt, ADUC, Windows Settings |
| Scenario Type | Device Recovery / Deployment Failure |
| Audience | IT Support / Endpoint Administrators / System Administrators |
| Status | Resolved |
| Evidence | Text-based runbook; screenshots unavailable |

---

## 2. Problem Description

A refurbished Windows 11 workstation was acquired for organisational use.

Following a Windows reset, the device entered the Windows Out-of-Box Experience (OOBE) but displayed a previous organisation's work or school account sign-in requirement.

The device requested credentials belonging to the organisation that had previously owned or registered it.

This prevented the normal Windows setup process from proceeding.

The issue was associated with an existing Windows Autopilot hardware registration belonging to another Microsoft tenant.

### Reported Symptoms

During Windows initial setup, the following screen appeared:

```text
Let's set up your work or school account.
```

The device requested the previous organisation's email address.

### Expected Outcome

The objective was to:

1. Return the refurbished workstation to a usable Windows 11 state.
2. Complete Windows setup without using the previous organisation's Microsoft account.
3. Create a local Windows administrator account.
4. Connect the workstation to the corporate network.
5. Join the workstation to the company's on-premises Active Directory domain.
6. Identify the correct Active Directory user account.
7. Grant the required local administrator permissions for Microsoft Office installation.
8. Verify access to internal company resources.

---

## 3. Technical Background

### Understanding Windows Autopilot

Windows Autopilot is a Microsoft cloud-based deployment technology used to provision and configure Windows devices for organisational environments.

It allows organisations to configure Windows devices during their initial setup process without requiring traditional manual deployment methods.

Autopilot uses device hardware registration to associate a Windows device with an organisation's deployment environment.

### Why the Windows Reset Did Not Resolve the Issue

A Windows reset removes the existing Windows installation and configuration, but does not necessarily remove the device's Windows Autopilot hardware registration.

When the refurbished workstation connected to the internet during OOBE, Windows contacted the Autopilot service and retrieved the deployment configuration associated with the previous organisation.

Consequently, the device continued displaying the previous organisation's work or school account sign-in requirement.

### Important Distinction

The following are separate device-management records:

| Component | Purpose |
|---|---|
| Microsoft Entra ID Device | Represents the device identity within Microsoft Entra ID. |
| Microsoft Intune Device | Represents the device's management record within Intune. |
| Windows Autopilot Registration | Associates the device hardware with an organisation's Autopilot deployment environment. |

Deleting a device from an Intune device list does not necessarily remove its Windows Autopilot registration.

---

## 4. Prerequisites

Before attempting device recovery, ensure that the following are available:

### Required Environment

- Windows 11 installation or reset environment.
- Physical access to the refurbished workstation.
- Access to Windows OOBE.
- Command Prompt access during OOBE.
- Corporate network connectivity.
- Access to the on-premises Active Directory domain.
- Appropriate domain-joining credentials.
- An authorised local administrator account.

### Administrative Access

Depending on the environment, access may also be required to:

- Microsoft Entra Admin Center.
- Microsoft Intune Admin Center.
- Windows Autopilot device management.

**Important:** The previous organisation must ultimately release the device from its Autopilot tenant for a proper ownership and deployment handover.

---

## 5. Investigation and Diagnosis

### Initial Assessment

The workstation was identified as a refurbished Windows 11 device.

Following a Windows reset, the device continued requesting authentication against a previous organisation's Microsoft environment.

The following factors were considered:

| Investigation | Finding |
|---|---|
| Windows reset | Completed successfully. |
| Windows OOBE | Displayed previous organisation's sign-in requirement. |
| Device ownership | Refurbished workstation. |
| Autopilot registration | Associated with previous organisation. |
| Local Windows setup | Could not proceed through the normal setup path. |

### Identified Root Cause

The workstation's Windows Autopilot hardware registration remained associated with the previous organisation's Microsoft tenant.

The Windows reset did not remove the existing Autopilot registration.

When the workstation connected to the internet during OOBE, the previous organisation's deployment configuration was retrieved.

This caused Windows to request the previous organisation's work or school account credentials.

---

## 6. Recovery and Resolution Procedure

### 6.1 Reset Windows

A Windows reset was performed to remove the previous Windows installation and configuration.

The reset completed successfully, and Windows entered the Out-of-Box Experience (OOBE).

However, the previous organisation's sign-in requirement remained.

### 6.2 Attempt the Standard OOBE Bypass

The standard OOBE bypass command was attempted.

```cmd
OOBE\BYPASSNRO
```

**Result:**

The command did not provide the required local setup path on the Windows build being used.

The recovery procedure therefore continued using an alternative local-account creation method.

### 6.3 Create a Local Windows Administrator Account

At the previous organisation's work or school account screen:

**Step 1:** Disconnect the workstation from the network.

**Step 2:** Press:

```text
Shift + F10
```

This opens Command Prompt during OOBE.

**Step 3:** Execute the following command:

```cmd
start ms-cxh:localonly
```

**Step 4:** Windows displays the local account creation interface.

**Step 5:** Create a temporary local administrator account.

**Step 6:** Complete the remaining Windows OOBE configuration.

This allowed Windows setup to proceed without authenticating against the previous organisation's Microsoft tenant.

**Result:**

A local Windows administrator account was successfully created, and the workstation became accessible.

---

## 7. Join the Workstation to Local Active Directory

Once Windows setup was completed, the workstation was connected to the corporate network.

### 7.1 Verify Network Connectivity

Before attempting to join the domain:

1. Connect the workstation to the corporate LAN.
2. Verify that the workstation receives the correct internal DNS servers.
3. Confirm connectivity to the domain controller.
4. Ensure the workstation can resolve the Active Directory domain.

DNS configuration is particularly important because domain-joined Windows computers rely on DNS to locate domain controllers and other domain services.

### 7.2 Join the Active Directory Domain

Navigate through:

```text
Settings
    |
    └── System
          |
          └── About
                |
                └── Advanced system settings
                      |
                      └── Computer Name
                            |
                            └── Change
                                  |
                                  └── Domain
```

Enter the appropriate corporate Active Directory domain.

Provide authorised domain-joining credentials when prompted.

**Result:**

The workstation successfully joined the company's on-premises Active Directory domain.

---

## 8. Verify Domain Membership

After joining the domain, perform the following checks.

### Verify the Logged-in Account

```powershell
whoami
```

Displays the current Windows security context.

### Verify the User Principal Name

```powershell
whoami /upn
```

Displays the current user's User Principal Name, where available.

### Identify the Domain Controller

Replace `YOURDOMAIN` with the actual domain DNS name.

```cmd
nltest /dsgetdc:YOURDOMAIN
```

This checks whether the workstation can locate a domain controller.

### Check Device Join Status

```cmd
dsregcmd /status
```

Review the following fields:

| Property | Purpose |
|---|---|
| AzureAdJoined | Indicates Microsoft Entra ID join status. |
| DomainJoined | Indicates on-premises Active Directory domain membership. |
| WorkplaceJoined | Indicates workplace registration status. |

**Note:** Joining an on-premises Active Directory domain does not automatically mean that the workstation is Microsoft Entra joined or enrolled into Intune.

These are separate device-management states.

---

## 9. Identify the Correct Active Directory User Account

After the workstation successfully joined the domain, the assigned user required assistance installing Microsoft Office.

The installation required local administrator privileges, while the user was a standard domain user.

The next step was to identify the correct on-premises Active Directory user object.

### 9.1 Open Active Directory Users and Computers

Execute:

```cmd
dsa.msc
```

This launches Active Directory Users and Computers.

### 9.2 Locate the User

Within ADUC:

1. Navigate to the appropriate Organizational Unit (OU).
2. Locate the assigned user.
3. Alternatively, use the Find functionality.
4. Open the user's Properties.
5. Select the Account tab.

### 9.3 Verify the Account Attributes

Check:

- User logon name.
- User logon name (pre-Windows 2000).

The pre-Windows 2000 logon name was used to identify the correct domain security principal.

The AD object did not contain the user's complete surname, so the account was verified through its properties rather than relying solely on the display name.

The resulting account format was:

```text
DOMAIN\username
```

---

## 10. Grant Local Administrator Permissions

The assigned user needed local administrator permissions to elevate the Microsoft Office installation.

### Procedure

On the affected workstation:

1. Open Computer Management.
2. Navigate to Local Users and Groups.
3. Select Groups.
4. Open the Administrators group.
5. Select Add.
6. Enter the user's on-premises AD account.

Use the following format:

```text
DOMAIN\username
```

7. Select Check Names.
8. Confirm that Windows resolves the correct account.
9. Apply the change.

**Result:**

The user's domain account was successfully added to the workstation's local Administrators group.

This allowed the user to elevate the Microsoft Office installation.

**Security consideration:**

Local administrator membership grants significant privileges over the workstation.

Where possible, use approved endpoint management and least-privilege procedures rather than permanently granting local administrator access to standard users.

---

## 11. Final Verification

Following the recovery procedure, the workstation reached the required operational state.

| Verification | Expected Outcome |
|---|---|
| Windows OOBE | Completed successfully. |
| Local administrator | Created successfully. |
| Corporate network | Connected successfully. |
| Internal DNS | Configured for corporate network access. |
| Active Directory domain | Workstation joined successfully. |
| Domain user identification | Correct AD account identified. |
| Local Administrators group | Assigned domain account added. |
| Office installation | Required elevation permissions provided. |
| Internal resources | Workstation prepared for internal resource access. |

### Final Device State

```text
Refurbished Windows 11 PC
          |
          v
Windows Reset
          |
          v
Previous Organisation's Autopilot Registration
          |
          v
Work/School Account Prompt
          |
          v
Local Windows Administrator Created
          |
          v
Windows Setup Completed
          |
          v
Corporate Network Connected
          |
          v
Local Active Directory Domain Joined
          |
          v
Correct AD User Identified
          |
          v
User Added to Local Administrators
          |
          v
Office Installation Can Proceed
          |
          v
Internal Resources Available
```

---

## 12. Lessons Learned

This scenario highlights several important endpoint management and identity administration concepts.

1. A Windows reset does not necessarily remove Windows Autopilot hardware registration.
2. Refurbished devices can remain associated with a previous organisation's Microsoft tenant.
3. Microsoft Intune device records and Windows Autopilot registrations are separate concepts.
4. Windows OOBE provides recovery options that can assist with local device setup.
5. Corporate DNS configuration is essential when joining a workstation to an Active Directory domain.
6. Microsoft Entra ID and on-premises Active Directory domain membership are different device identity states.
7. A user's Microsoft Entra administrative permissions do not automatically make that user a local administrator on a domain-joined workstation.
8. When adding users to local groups, verify the actual AD security principal rather than relying solely on display names or email addresses.
9. Local administrator permissions should follow the organisation's least-privilege requirements.
10. Refurbished devices should undergo ownership and Autopilot registration checks before being deployed.

---

## 13. Recommended Future Procedure

For future refurbished Windows workstation deployments, use the following process.

| Step | Action |
|---|---|
| 1 | Confirm device ownership and refurbishment status. |
| 2 | Check whether the device is registered in Windows Autopilot. |
| 3 | Check the Microsoft Intune device record. |
| 4 | Check the Microsoft Entra device record. |
| 5 | Confirm that the previous organisation has released the device. |
| 6 | Reset Windows if required. |
| 7 | Complete Windows OOBE. |
| 8 | Create a local recovery administrator if authorised and required. |
| 9 | Verify corporate DNS and network connectivity. |
| 10 | Join the Active Directory domain where required. |
| 11 | Verify domain membership and user authentication. |
| 12 | Install required business applications. |
| 13 | Apply approved permissions. |
| 14 | Determine whether the device should be enrolled into Intune. |
| 15 | Document the final device state. |

---

## 14. Important Security and Ownership Consideration

The recovery procedure documented in this case addressed the immediate operational requirement of getting the workstation working.

It did not remove the device's existing Windows Autopilot registration from the previous organisation's tenant.

The long-term supported resolution is for the previous organisation or authorised refurbisher to release or deregister the device from its Windows Autopilot environment.

A device should not be considered fully transferred and ready for standard organisational deployment until its ownership and registration status have been appropriately resolved.

---

## 15. References and Further Reading

- Microsoft Learn – Windows Autopilot overview.
- Microsoft Learn – Windows Autopilot device registration.
- Microsoft Learn – Windows Autopilot device deregistration.
- Microsoft Learn – Microsoft Intune device management.
- Microsoft Learn – Join a computer to a domain.
- Microsoft Learn – Microsoft Entra device identity.

---

## 16. Case Closure

| Field | Details |
|---|---|
| Case ID | HW-001 |
| Resolution Status | Resolved |
| Primary Category | Hardware / Endpoint Management |
| Primary Technology | Windows 11 / Windows Autopilot |
| Related Technologies | Microsoft Entra ID, Intune, Active Directory |
| Primary Issue | Previous organisation's Autopilot registration |
| Recovery Method | Local Windows account creation and domain joining |
| Additional Work | Local administrator configuration |
| Verification | Windows setup and domain joining completed |
| Documentation Type | Real-World Troubleshooting Case |

**End of Knowledge Base Article**
