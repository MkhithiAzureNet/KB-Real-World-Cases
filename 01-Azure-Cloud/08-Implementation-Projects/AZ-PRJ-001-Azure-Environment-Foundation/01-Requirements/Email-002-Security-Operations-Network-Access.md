# REQ-002 — Azure Network Access Restrictions

## 1. Request Information

| Field | Details |
|---|---|
| Request ID | REQ-002 |
| Email Reference | Email 002 |
| Requestor | Security Operations |
| Request Type | Network Security |
| Project | AZ-PRJ-001 — Azure Environment Foundation |
| Target Platform | Microsoft Azure |
| Status | Implemented |

---

## 2. Original Business Request

**From:** Security Operations

**Subject:** Network Access Restrictions

### Requirements

1. Create separate Network Security Groups for production and development database workloads.
2. Permit SQL traffic over TCP port 1433 only from the corresponding application subnet.
3. Deny all other inbound traffic.

*Note: Retain the original email as the authoritative source for its complete wording and subject. This record captures the requirements recovered from the project correspondence.*

---

## 3. Business Objective

Implement network-level access restrictions for the production and development database workloads.

Database access must be restricted to the corresponding application subnet, with SQL Server traffic permitted over TCP port 1433.

Other inbound traffic must be denied to reduce unnecessary network exposure.

---

## 4. Technical Requirements

| ID | Requirement | Expected Outcome |
|---|---|---|
| REQ-002-01 | Production database NSG | Dedicated NSG for production database subnet |
| REQ-002-02 | Development database NSG | Dedicated NSG for development database subnet |
| REQ-002-03 | SQL access restriction | Permit TCP 1433 from the matching application subnet |
| REQ-002-04 | Inbound restriction | Deny other inbound traffic |

---

## 5. Implementation Mapping

The requirements were implemented through Lab 01.2 — Network Security Groups.

### Production environment

**NSG:** NSG-DB-PRD-01

**Associated subnet:** Db-Sub-Workload01

| Priority | Rule | Source | Protocol | Port | Action |
|---:|---|---|---|---:|---|
| 100 | Allow_SQL_1433 | 10.10.1.0/24 | TCP | 1433 | Allow |
| 200 | DenyAll-Other-Inbound | Any | Any | Any | Deny |

### Development environment

**NSG:** NSG-DB-DEV-01

**Associated subnet:** DbDev-Sub-Workload01

| Priority | Rule | Source | Protocol | Port | Action |
|---:|---|---|---|---:|---|
| 110 | Allow_SQL_1433 | 10.20.1.0/24 | TCP | 1433 | Allow |
| 200 | DenyAll-Other-Inbound | Any | Any | Any | Deny |

---

## 6. Implementation Outcome

Two separate Network Security Groups were created and associated with their respective database subnets.

The custom inbound rules were configured to:

- Permit SQL traffic from the matching application subnet.
- Deny other inbound traffic.
- Maintain separate security policies for production and development.

Azure Portal and Azure CLI evidence confirmed the NSG resources, custom rules and subnet associations.

**Validation limitation:** The available evidence confirms the security configuration. It does not establish a successful TCP 1433 application-to-database connectivity test or a packet-level denial test from an unauthorised source.

---

## 7. Technical Considerations

### NSG rule priority

Azure evaluates custom NSG rules in ascending priority order. Lower numerical values are evaluated first.

The SQL allow rules therefore take precedence over the custom deny rule.

### Scope of the deny rule

The custom deny rule is broad. Because it has priority 200, it also takes precedence over Azure's default inbound rules for VirtualNetwork and AzureLoadBalancer traffic.

This behaviour must be considered when introducing additional infrastructure services or future workload dependencies.

### Outbound traffic

The custom rules documented in this request concern inbound traffic.

Outbound traffic follows the NSG's configured outbound rules. Inbound restrictions should not be interpreted as proof that outbound connectivity is restricted.

---

## 8. Lessons Learned

- Separate NSGs provide independent security policy boundaries for production and development.
- Subnet-level NSG associations allow consistent enforcement across workloads in a subnet.
- Rule priorities are critical to the effective security policy.
- Broad deny rules can affect internal Azure traffic as well as external traffic.
- Configured network rules and successfully tested network connectivity are different validation outcomes.
- Security controls should be reviewed against future application and infrastructure dependencies.

---

## 9. Related Implementation Records

- [Lab 01 — Initial Azure Network Infrastructure](../02-Implementation/AZ-001-Network-Infrastructure.md)
- [Lab 01.2 — Network Security Groups](../02-Implementation/AZ-002-Network-Security-Groups.md)
- [Project Overview — AZ-PRJ-001](../README.md)

---

## 10. Conclusion

REQ-002 introduced network access restrictions for the production and development database workloads.

Separate NSGs were configured and associated with their respective database subnets. SQL traffic was permitted from the corresponding application subnet, while other inbound traffic was denied through custom security rules.

This established the network security foundation for the subsequent virtual machine and database deployment milestones.
