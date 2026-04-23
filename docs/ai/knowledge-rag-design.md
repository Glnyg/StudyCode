# Knowledge And RAG Design

## Goal
Provide grounded answers for customer service flows while keeping knowledge publication, retrieval, and rollback deterministic and auditable.

## Knowledge Sources
- Reviewed FAQ
- SOP and troubleshooting documents
- Product and package documentation
- Approved operational playbooks
- Chat-derived learning candidates after review

## V1 Non-Goals
- No raw chat transcript direct publish.
- No autonomous self-training.
- No OpenSearch ownership of vector truth.

## Data Flow
1. Import file or structured FAQ.
2. Store original content in object storage.
3. Parse and normalize content.
4. Chunk content.
5. Generate embeddings.
6. Write chunk and embedding metadata to PostgreSQL.
7. Review staged content.
8. Publish a knowledge release.
9. `ai-service` retrieves only from published releases.

## Core Entities
- `KnowledgeBase`
- `KnowledgeDocument`
- `KnowledgeDocumentVersion`
- `KnowledgeChunk`
- `KnowledgeChunkEmbedding`
- `KnowledgeRelease`
- `KnowledgeReleaseItem`
- `KnowledgeFeedback`
- `LearningCandidate`

## Storage Decisions
- PostgreSQL is the source of truth for metadata, versions, releases, and embeddings.
- `pgvector` stores embeddings.
- Object storage stores raw source files and large parsed artifacts.
- Retrieval uses metadata filters first, then vector search, then rerank.

## Release Model
- Only `Published` releases are visible to runtime retrieval.
- New imports stay in a staged area until reviewed.
- Rollback switches the active release pointer instead of mutating content in place.

## Retrieval Rules
- Mandatory tenant filter.
- Optional filters:
  - channel
  - product line
  - scenario tag
  - effective date
- Retrieval returns evidence chunks and release version metadata to `ai-service`.

## Learning Pipeline
- Chat transcripts create candidates only after:
  - masking sensitive data
  - extracting candidate Q&A
  - de-duplicating
  - human review
  - offline evaluation
- Published knowledge must always reference a reviewed release.

## Metrics
- hit rate
- citation coverage
- answer adoption rate
- no-answer rate
- false-answer rate
- stale-document recall
- tool-needed vs knowledge-needed routing quality
