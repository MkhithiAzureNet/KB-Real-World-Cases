# AZ-001 — Azure Network Infrastructure

**Project:** [AZ-PRJ-001 — Azure Environment Foundation](../README.md)  
**Case ID:** AZ-001  
**Request Reference:** [Email 001 — CTO Initial Network Infrastructure](../01-Requirements/Email-001-CTO-Initial-Network-Infrastructure.md)  
**Platform:** Microsoft Azure  
**Region:** South Africa North  
**Resource Group:** RG-CloudEng-01  
**Implementation Approach:** Terraform with Azure Portal and Azure CLI validation  
**Status:** Implemented Scope Documented — Original Request Evidence Pending

---

## 1. Overview

This milestone established the initial Azure network foundation for separate production and development environments. The implementation created segmented network contexts for application and database workloads and connected the two virtual networks through VNet peering.

This case records the observed implementation scope. The original Email 001 wording, date, and acceptance criteria are not available in the repository and are deliberately not inferred. See the linked requirement record for the source-evidence boundary.

## 2. Business Request and Expected Outcome

### Request Evidence Status

Email 001 initiated the work, but its original content is pending. This document must not be read as a verbatim CTO instruction.

### Implemented Outcome

The resulting Lab 01 environment provided:

- A production virtual-network context.
- A development virtual-network context.
- Application and database subnet segmentation in each context.
- Bidirectional VNet peering between production and development.

Later milestones used this foundation for database-subnet NSGs, workload VMs, outbound connectivity, SQL Server, managed identity, and Key Vault integration.

## 3. Technical Planning and Design

### Network Segmentation

The design separates application and database tiers by subnet and keeps production and development in distinct virtual networks.

| Environment | Virtual Network | Application Subnet | Database Subnet |
|---|---|---|---|
| Production | `Vnet-001-PRD` | `10.10.1.0/24` | `10.10.2.0/24` (`Db-Sub-Workload01`) |
| Development | `Vnet-001-DEV` | `10.20.1.0/24` | `10.20.2.0/24` (`DbDev-Sub-Workload01`) |

The VNet-level address spaces and application-subnet resource names are not included here because they require direct source evidence before publication.

### Connectivity Design

The virtual networks were paired through reciprocal peering:

| Source VNet | Peering Name | Destination VNet |
|---|---|---|
| `Vnet-001-PRD` | `VnetPRDtoVnetDEV` | `Vnet-001-DEV` |
| `Vnet-001-DEV` | `VnetDevToVnetPRD` | `Vnet-001-PRD` |

VNet peering provides private network connectivity between the environments; it does not by itself define application access controls. Those controls are addressed by the database-subnet NSGs in the following milestone.

## 4. Implementation

Terraform was used as the implementation approach for the Azure foundation. Azure Portal and Azure CLI output were used as supporting verification sources.

The recorded implementation sequence was:

1. Establish the Azure resource group context in South Africa North.
2. Create the production and development virtual networks.
3. Create application and database subnets in each virtual network.
4. Configure reciprocal VNet peering between the two virtual networks.
5. Verify the peering relationship and subnet associations in Azure.

This case does not reproduce Terraform source because the repository is a knowledge base, not the infrastructure source of truth. The future evidence set should link to approved, redacted Terraform excerpts or deployment output where appropriate.

## 5. Validation and Results

### Observed Validation

Later Azure CLI evidence recorded both VNet peerings as **Connected** and **FullyInSync**:

| VNet | Peering | State | Synchronisation |
|---|---|---|---|
| `Vnet-001-DEV` | `VnetPRDtoVnetDEV` | Connected | FullyInSync |
| `Vnet-001-PRD` | `VnetDevToVnetPRD` | Connected | FullyInSync |

The differing VNet-to-peering-name pairing in the retained evidence should be reconciled against the Azure resource view before treating the table as a final configuration record.

### Validation Boundaries

The available evidence supports that the peerings were connected and synchronised. It does not independently prove:

- End-to-end application-to-database connectivity.
- Effective NSG behaviour.
- DNS resolution across peerings.
- Application reachability, authentication, or workload health.

Those tests belong to later milestones and must be documented with their own commands and outputs.

## 6. Challenges and Troubleshooting

No Lab 01-specific failure, error message, root cause, or remediation has been retained as source evidence for this record. No troubleshooting outcome is inferred.

If a material Lab 01 incident is supplied, document it either in this section or as a standalone record under [03-Troubleshooting](../03-Troubleshooting/README.md), depending on its scope.

## 7. Security and Cost Considerations

### Security

- Network separation is a foundation control; it does not replace subnet-level NSGs, host firewalls, identity controls, or application access controls.
- Database-subnet protection is documented in the subsequent NSG milestone.
- Keep network diagrams and future evidence free of sensitive identifiers, public IP addresses, credentials, and connection strings.

### Cost

- VNet peering data-transfer charges can apply and should be evaluated against actual traffic patterns.
- No NAT Gateway, public IP, VM, SQL Server, or Key Vault cost is attributed to this milestone unless supported by a later deployment record.

## 8. Lessons Learned

- Separate production and development environments from the beginning to support predictable security and operational boundaries.
- Segment application and database tiers before deploying workloads.
- Treat a connected VNet peering state as a control-plane result, not proof of application connectivity.
- Preserve the originating request and acceptance criteria alongside technical evidence so implementation intent remains auditable.

## 9. Outstanding Evidence

To complete this milestone, add or link:

1. The original, redacted Email 001 or authorised request record.
2. Approved VNet address spaces and application-subnet names.
3. Terraform plan or deployment evidence, with sensitive values removed.
4. Screenshot or CLI evidence for each VNet, subnet, and peering.
5. A controlled connectivity test where applicable.

## 10. Related Records

- [Email 001 — CTO Initial Network Infrastructure](../01-Requirements/Email-001-CTO-Initial-Network-Infrastructure.md)
- [AZ-PRJ-001 — Azure Environment Foundation](../README.md)
- AZ-002 — Network Security Groups — pending creation

---

**Document Owner:** Nhlanhla  
**Knowledge Base Reference:** AZ-001  
**Category:** Azure Cloud / Implementation Projects

