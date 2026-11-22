# AZ-PRJ-001 - Azure Environment Foundation

## Executive Summary

I translated infrastructure and security requirements into a working Azure foundation for production and development workloads. I combined network design, Terraform provisioning, Linux automation, outbound connectivity troubleshooting, and secure database operations.

### Delivery Highlights

- Designed separate production and development VNets with non-overlapping address spaces, workload subnets, and bidirectional peering.
- Configured database-subnet Network Security Groups (NSGs) and scoped SQL access rules.
- Provisioned four Ubuntu Linux virtual machines across the two environments using Terraform.
- Diagnosed package download failures, distinguished DNS resolution from outbound connectivity, and deployed a NAT Gateway to enable egress.
- Installed SQL Server 2022 Developer Edition on Ubuntu and verified the service and a local authenticated SQLCMD query.
- Integrated a system-assigned managed identity, Azure RBAC, and Key Vault so the VM could retrieve the SQL administrator secret at runtime without embedding or printing its value.

**Technologies:** Microsoft Azure, Terraform, Azure CLI, Ubuntu Server 22.04, cloud-init, NAT Gateway, NSGs, Azure RBAC, Managed Identity, Key Vault, SQL Server 2022, SQLCMD.

**Engineering strengths demonstrated:** Translating requirements into infrastructure; Infrastructure as Code; cloud networking and security; Linux automation and troubleshooting; secure secret handling; and evidence-based validation.

**Scope:** This is a hands-on engineering portfolio project, not a production-readiness certification. Validation was limited to the documented checks; end-to-end workload connectivity, disaster recovery, and a complete security assessment were not established.

---

## 1. Project Overview
This project documents the design, implementation, configuration, troubleshooting, and validation of an Azure environment across five implementation milestones.

**Project classification:** Azure Cloud Infrastructure Implementation
**Project ID:** AZ-PRJ-001
**Platform:** Microsoft Azure
**Resource Group:** RG-CloudEng-01
**Azure Region:** South Africa North
**Infrastructure as Code:** Terraform
**Primary implementation environments:** Production and Development

---

## 2. Business Context
The organisation was preparing its Azure environment for the deployment of production and development workloads.

The initial requirements focused on establishing network connectivity and separating the two environments. A subsequent security request introduced network access restrictions for database workloads.

Following the initial infrastructure requirements, the implementation was extended to include virtual machines, automated Linux configuration, outbound connectivity and a SQL Server workload.

This project records the complete implementation journey, including the technical decisions, challenges, troubleshooting activities, validation results and lessons learned.

---

## 3. Original Business Requests
The project was initiated through two internal requests.

### Email 001 - Initial Network Infrastructure
**From:** CTO
**Subject:** Initial network infrastructure

**Business request:**

The organisation was preparing its Azure environment for production and development workloads and required the initial network infrastructure to be established.

**Requirements:**

1. Create a production virtual network.
2. Create a development virtual network.
3. Ensure that the networks use separate IP address spaces.
4. Create appropriate subnets for application workloads.
5. Establish communication between the two virtual networks using VNet Peering.
6. Ensure that the networks are deployed in South Africa North.

**Implementation reference:** Lab 01 - Initial Azure Network Infrastructure.

### Email 002 - Network Access Restrictions
**From:** Security Operations

**Requirements:**

1. Create separate Network Security Groups for production and development database workloads.
2. Permit SQL traffic over TCP port 1433 only from the corresponding application subnet.
3. Deny all other inbound traffic.

**Implementation reference:** Lab 01.2 - Network Security Groups.

*The original Email 002 record should be retained separately, preserving its original subject and wording when the source email is added.*

---

## 4. Implementation Milestones
The two original requests resulted in five implementation milestones.

Milestone | Implementation | Scope
--- | --- | ---
Lab 01 | Initial Azure Network Infrastructure | VNets, address spaces, subnets and VNet peering
Lab 01.2 | Network Security Groups | Production and development database security controls
Lab 01.3 | Virtual Machine Deployment | Deployment and configuration of Azure virtual machines
Lab 01.4 | Cloud-init and Outbound Connectivity | Ubuntu configuration, package installation and NAT Gateway
Lab 01.5 | SQL Server and Key Vault Integration | SQL Server 2022, managed identity, Key Vault and SQL connectivity validation

These milestones are implementation activities under the original project scope. They are not separate business requests.

---

## 5. Environment Architecture

### 5.1 Azure Network Infrastructure
The environment was designed with separate production and development virtual networks.

Environment | Virtual Network | Address Space
--- | --- | ---
Production | Vnet-001-PRD | 10.10.0.0/16
Development | Vnet-001-DEV | 10.20.0.0/16

### 5.2 Subnet Allocation

Environment | Subnet | Address Range
--- | --- | ---
Production | App-Sub-Workload01 | 10.10.1.0/24
Production | Db-Sub-Workload01 | 10.10.2.0/24
Development | AppDev-Sub-Workload01 | 10.20.1.0/24
Development | DbDev-Sub-Workload01 | 10.20.2.0/24

### 5.3 Network Security
Separate database Network Security Groups were implemented:

- NSG-DB-PRD-01
- NSG-DB-DEV-01

The custom rules permit SQL traffic from the matching application subnet and deny other inbound traffic.

### 5.4 Virtual Machines and Database Workload
Four virtual machines were deployed across the production and development environments.

The development database workload was subsequently configured with:

- Ubuntu Server 22.04 LTS.
- Microsoft SQL Server 2022 Developer Edition.
- A configured SQL Server memory limit of 4,096 MB.
- A system-assigned managed identity.
- Azure Key Vault integration for secure retrieval of the SQL administrator password.

---

## 6. Implementation Challenges
The implementation involved several practical troubleshooting activities.

Area | Challenge | Resolution
--- | --- | ---
Outbound connectivity | Ubuntu package downloads timed out despite successful DNS resolution | Implemented NAT Gateway for the development database subnet
Cloud-init | Package installation depended on outbound connectivity | Corrected network egress and redeployed the development VM configuration
SQL Server setup | Interactive configuration was unsuitable for Azure Run Command | Used unattended SQL Server setup
Key Vault authentication | Initial secret retrieval returned Unauthorized | Acquired a fresh managed identity token and performed token acquisition and secret retrieval in the same execution
SQL tools installation | APT could not locate mssql-tools18 | Registered Microsoft's Ubuntu production repository
SQL configuration validation | Initial verification command did not locate the memory setting | Inspected the SQL Server configuration file directly

Detailed troubleshooting records will be maintained under `03-Troubleshooting/`.

---

## 7. Validation and Results
The following outcomes were verified during implementation:

- Production and development VNets were deployed.
- Separate IP address spaces were configured.
- VNet peerings showed Connected and FullyInSync.
- Database NSGs were associated with their intended subnets.
- Four Azure virtual machines were deployed.
- NAT Gateway enabled outbound package downloads for the development database subnet.
- Ubuntu package installation completed.
- SQL Server 2022 Developer Edition was installed and configured.
- The development VM successfully authenticated to Azure Key Vault using its system-assigned managed identity.
- The SQL administrator secret was retrieved without printing its value.
- SQL Server service status was confirmed as active and enabled.
- The SQL Server memory configuration was verified as 4,096 MB.
- SQL command-line tools were installed.
- An authenticated local SQL query successfully returned SQL Server version information and the connected login.

**Validation boundary:** These results demonstrate the configuration and tests performed during the labs. They do not establish production readiness, external SQL connectivity, disaster recovery capability or a complete security assessment.

---

## 8. Security Considerations
The implementation introduced several important security controls:

- Separate production and development network address spaces.
- Database subnet-level NSG controls.
- Restricted inbound SQL access.
- System-assigned managed identity for the development database VM.
- Azure RBAC using the Key Vault Secrets User role.
- SQL administrator credentials stored in Azure Key Vault rather than hardcoded into Terraform or cloud-init.
- Runtime secret retrieval without displaying the password.

Further hardening, certificate validation, database least-privilege administration and production credential management remain areas for improvement.

---

## 9. Cost Considerations
A NAT Gateway and dedicated public IP were deployed to provide outbound connectivity to the development database subnet.

These resources incur ongoing costs. Once package installation and the required connectivity tests are complete, their removal should be considered.

**Outstanding action:** Review the Terraform configuration and state, then remove the temporary development NAT Gateway and its dedicated public IP through Terraform, ensuring unrelated resources are preserved.

---

## 10. Lessons Learned
This project provided practical experience in:

- Designing Azure network infrastructure using separate production and development address spaces.
- Implementing subnet-level security using NSGs.
- Understanding Azure VNet peering and network isolation.
- Provisioning virtual machines using Terraform.
- Automating Linux configuration using cloud-init.
- Understanding Azure outbound connectivity and NAT Gateway.
- Troubleshooting DNS resolution versus outbound network connectivity.
- Deploying SQL Server on Ubuntu.
- Using managed identities instead of embedded credentials.
- Applying Azure RBAC to Key Vault.
- Retrieving secrets securely at runtime.
- Validating infrastructure through Azure CLI, Linux commands and SQL queries.
- Managing cloud resource costs during infrastructure development.

---

## 11. Project Documentation Index

### 01 - Requirements

- [Email 001 - Initial Network Infrastructure](01-Requirements/Email-001-CTO-Initial-Network-Infrastructure.md)
- [Email 002 - Network Access Restrictions](01-Requirements/Email-002-Security-Operations-Network-Access.md)

### 02 - Implementation

- [Lab 01 - Initial Azure Network Infrastructure](02-Implementation/AZ-001-Network-Infrastructure.md)
- [Lab 01.2 - Network Security Groups](02-Implementation/AZ-002-Network-Security-Groups.md)
- [Lab 01.3 - Terraform-Based Virtual Machine Provisioning](02-Implementation/AZ-003-Terraform-Based-Virtual-Machine-Provisioning.md)
- [Lab 01.4 - Cloud-init and Outbound Connectivity](02-Implementation/AZ-004-Cloud-Init-and-Outbound-Connectivity.md)
- [Lab 01.5 - SQL Server and Key Vault Integration](02-Implementation/AZ-005-SQL-Server-and-Key-Vault-Integration.md)


### Evidence
Screenshots, deployment outputs, configuration evidence and relevant architecture diagrams will be maintained in the `images/` directory.

---

## 12. Project Conclusion
The project established an Azure foundation for production and development workloads and extended that foundation with virtual machines, automated Linux configuration and a secured SQL Server development workload.

The work demonstrates the progression from business requirements to infrastructure design, Infrastructure as Code, implementation, troubleshooting and validation.

The project remains a learning and engineering implementation. Additional validation and hardening would be required before treating the environment as production-ready.
