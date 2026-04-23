# AI Service Design

## Role Of AI Service
`ai-service` is a policy-controlled decision layer, not a free-form chatbot bolted onto the side of the platform.

## Internal Modules
- `orchestrator`: chooses the execution path for each AI request.
- `rag`: retrieves evidence and assembles grounded context.
- `tool-executor`: invokes controlled business tools.
- `policy-engine`: decides what AI is allowed to do for a tenant and scenario.
- `prompt-config`: resolves published prompt profiles and prompt fragments.
- `evaluation`: stores and exposes quality and safety metrics.
- `learning-pipeline`: turns eligible chat history into reviewed learning candidates.

## AI Technology Stack
- `Microsoft.Extensions.AI` as the application-facing abstraction.
- Provider-specific SDKs remain behind the model gateway.
- `Polly` or equivalent resilience policies wrap model and tool calls.
- `OpenTelemetry` records model, tool, and policy spans.

## Interaction Modes
- `SuggestOnly`
- `Copilot`
- `Autopilot`
- `EscalationOnly`

## Decision Order
1. Resolve trusted `tenant_id`, channel, and conversation context.
2. Load published AI policy version.
3. Detect intent and risk level.
4. Prefer structured facts or approved tools when business facts are needed.
5. Use RAG only for answer synthesis or explanation.
6. Select fixed asset or link card if policy and channel allow it.
7. Audit the entire decision and fallback reason.

## Multimodal Rules
- Supported inbound AI understanding:
  - text
  - image
- Unsupported inbound AI understanding in V1:
  - video
- Supported outbound AI responses:
  - text
  - fixed image
  - fixed video
  - predefined link card
- Forbidden outbound behavior:
  - generated image
  - generated video
  - unreviewed asset selection

## Policy Configuration
- Database-backed, versioned configuration is authoritative.
- Minimum configuration groups:
  - `PromptProfile`
  - `ReplyPolicy`
  - `ToolPolicy`
  - `AssetSelectionPolicy`
  - `TenantAiSettings`
  - `KnowledgeReleasePolicy`
- Lifecycle:
  - `Draft`
  - `Review`
  - `Published`
  - `RolledBack`

## Tool Execution Rules
- `ReadOnly`: may run automatically when policy permits.
- `LowRiskMutating`: requires tenant allowlist, validated parameters, precondition check, confidence threshold, and idempotency key.
- `HighRiskMutating`: never auto-executes; AI may only suggest and route to human confirmation.

## Audit Requirements
- Every AI decision must record:
  - `tenant_id`
  - `conversation_id`
  - `mode`
  - `policy_version`
  - `prompt_version`
  - `model_name`
  - `confidence`
  - `tool_calls`
  - `asset_choice`
  - `fallback_reason`
- Sensitive image content must not be persisted as raw narrative logs. Only the minimum summary needed for audit is retained.

## Failure Handling
- Model timeout:
  - degrade to human or text-only fallback
- Retrieval failure:
  - return no-answer or human escalation, never hallucinated business facts
- Tool failure:
  - explicit failure reason, no silent retry loops that can repeat side effects
- Policy load failure:
  - fail closed
