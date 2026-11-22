# REQ-001 — Initial Azure Network Infrastructure

## 1. Request Information

| Field | Details |
|---|---|
| Request ID | REQ-001 |
| Email Reference | Email 001 |
| Requestor | Chief Technology Officer (CTO) |
| Request Type | Azure Infrastructure |
| Project | AZ-PRJ-001 — Azure Environment Foundation |
| Target Platform | Microsoft Azure |
| Target Region | South Africa North |
| Status | Implemented |

---

## 2. Original Business Request

**From:** CTO

**Subject:** Initial Network Infrastructure

> We are preparing our Azure environment for the deployment of our production and development workloads.
>
> Please establish the initial network infrastructure.

### Requirements

1. Create a production virtual network.
2. Create a development virtual network.
3. Ensure that the networks use separate IP address spaces.
4. Create appropriate subnets for application workloads.
5. Establish communication between the two virtual networks using VNet Peering.
6. Ensure that the networks are deployed in South Africa North.

---

## 3. Business Objective

Establish the initial Azure network foundation required to support future production and development workloads.

The environment must provide logical separation between production and development while allowing communication between the two virtual networks through Azure Virtual Network Peering.

The network design must also provide appropriate subnet segmentation for application workloads.

---

## 4. Technical Requirements

The original request translates into the following technical requirements:

| ID | Requirement | Expected Outcome |
|---|---|---|
| REQ-001-01 | Production VNet | Dedicated production virtual network |
| REQ-001-02 | Development VNet | Dedicated development virtual network |
| REQ-001-03 | IP address separation | Non-overlapping address spaces |
| REQ-001-04 | Subnet allocation | Separate workload subnets |
| REQ-001-05 | VNet Peering | Connectivity between production and development VNets |
| REQ-001-06 | Azure Region | All network resources deployed in South Africa North |

---

## 5. Implementation Mapping

The request was addressed through Lab 01 — Initial Azure Network Infrastructure.

| Requirement | Implementation |
|---|---|
| Production VNet | Vnet-001-PRD |
| Development VNet | Vnet-001-DEV |
| Separate address spaces | 10.10.0.0/16 and 10.20.0.0/16 |
| Application subnet | App-Sub-Workload01 — 10.10.1.0/24 |
| Development application subnet | AppDev-Sub-Workload01 — 10.20.1.0/24 |
| Production database subnet | Db-Sub-Workload01 — 10.10.2.0/24 |
| Development database subnet | DbDev-Sub-Workload01 — 10.20.2.0/24 |
| VNet Peering | Bidirectional peering between production and development |
| Azure Region | South Africa North |

---

## 6. Implementation Outcome

The requested network foundation was established.

The production and development virtual networks were deployed with separate, non-overlapping IP address spaces and segmented application and database subnets.

Bidirectional VNet Peering was configured between the two networks.

Subsequent Azure CLI verification showed:

- Production-to-development peering: Connected.
- Development-to-production peering: Connected.
- Peering synchronisation: FullyInSync.

These results confirm the peering configuration state. They do not independently demonstrate successful application-level or database-level connectivity.

---

## 7. Related Implementation Records

This request initiated the following implementation work:

- Lab 01 — Initial Azure Network Infrastructure.
- Lab 01.2 — Network Security Groups.
- Lab 01.3 — Virtual Machine Deployment.
- Lab 01.4 — Cloud-init and Outbound Connectivity.
- Lab 01.5 — SQL Server and Key Vault Integration.

These are implementation milestones under the project, not separate CTO requests.

---

## 8. Conclusion

REQ-001 established the initial network foundation for the Azure Environment Foundation project.

The production and development environments were deployed in South Africa North using separate IP address spaces, workload subnets and bidirectional VNet Peering.

The resulting network infrastructure provided the foundation for subsequent security controls, virtual machine deployments and database workload implementation.

**Related Project:** [AZ-PRJ-001 — Azure Environment Foundation](../README.md)
