# Implementation Project Template

Use this template to document an implementation project or milestone. Adapt or remove sections that do not apply. Record verified facts, distinguish planned work from completed work, and redact secrets and sensitive information.

## 1. Document Information

| Field | Details |
|---|---|
| Project ID | `<project-id>` |
| Implementation ID | `<implementation-id>` |
| Project | `<project-name>` |
| Workstream | `<workstream>` |
| Related requirement | `<requirement-document>` |
| Environment or scope | `<environment-and-scope>` |
| Region or location | `<region-or-location>` |
| Implementation approach | `<portal, CLI, IaC, or other>` |
| Status | `<planned, in progress, or completed; include verification status>` |

---

## 2. Implementation Objective

Describe the intended outcome, why the work is needed, and the scope of this implementation. Note important exclusions or prerequisites.

## 3. Original Requirements

Summarize the source requirements and link to the original request or design record.

1. `<requirement>`
2. `<requirement>`
3. `<requirement>`

Identify any additional scope introduced during implementation and explain why it was added.

---

## 4. Architecture and Configuration

Describe the target design and the relevant configuration. Use tables for values that are easier to compare.

### 4.1 `<Component or environment>`

| Setting | Configuration |
|---|---|
| `<setting>` | `<value>` |
| `<setting>` | `<value>` |

Include architecture diagrams or configuration screenshots where they clarify the design. Store approved, redacted images in the project evidence directory and link them relative to this document.

![<Descriptive alt text>](../images/IMPLEMENTATION-ID/image-name.png)

### 4.2 `<Additional component or environment>`

Repeat or adapt this subsection as needed.

## 5. Implementation Activities

Document what was actually configured or changed. Organize work into numbered steps or components. Include relevant resource names, configuration values, and image evidence near the related explanation.

### 5.1 `<Activity or component>`

Describe the work performed, its outcome, and any relevant configuration.

![<Descriptive alt text>](../images/IMPLEMENTATION-ID/image-name.png)

### 5.2 `<Activity or component>`

Describe the work performed and its outcome.

## 6. Validation and Results

Record how the implementation was verified. Distinguish resource/configuration checks from end-to-end or user-level tests, and note anything not tested.

| Validation | Result |
|---|---|
| `<check>` | `<verified result>` |
| `<check>` | `<verified result>` |

### Validation commands or procedures

Include only commands and procedures that were actually run. Redact secrets and sensitive values.

```text
<command or procedure>
```

**Validation limitations:** `<state what the checks do not prove, or write "None identified" if appropriate>`

## 7. Challenges and Lessons Learned

Record significant implementation obstacles and the confirmed resolution or lesson. Do not present an unverified hypothesis as a root cause.

### 7.1 `<Challenge>`

- **Observed:** `<symptom or obstacle>`
- **Resolution:** `<what was changed or how it was resolved>`
- **Lesson:** `<reusable takeaway>`

## 8. Security Considerations and Outstanding Work

Describe security-relevant decisions, limitations, and follow-up actions. Include owners or due dates only when known.

- `<security consideration or action>`
- `<outstanding work>`

## 9. Final Outcome

Summarize what was completed, the resulting state, and any remaining blockers or follow-up work. Do not describe planned or unverified work as complete.

## 10. Related Documentation

- `<relative link to requirement, design, or related implementation>`
- `<vendor documentation or procedure>`

## 11. Evidence

Store approved, redacted screenshots and other implementation evidence in the project’s `images/<implementation-id>/` directory. Link to it from this document and include evidence near the relevant implementation or validation details.

Store approved, redacted screenshots in [images/IMPLEMENTATION-ID](../images/IMPLEMENTATION-ID/).

Only include evidence that supports the documented claims. Remove credentials, tokens, personal information, subscription or tenant identifiers, and other sensitive data before committing files.

---

**Implementation:** `<implementation-id> — <implementation-name>`  
**Project:** `<project-id> — <project-name>`  
**Status:** `<current status>`
