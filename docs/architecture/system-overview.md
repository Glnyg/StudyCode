# System Overview

## Goal
Build a production-grade, multi-tenant customer service system for portable WiFi devices that combines human support workflows and AI assistance without compromising tenant isolation, auditability, or operational clarity.

## Product Scope
- Customer entry: Enterprise WeChat customer service and official account channels.
- Human support: realtime chat, routing, queueing, transfer, assist, evaluation, quality inspection, performance analytics, and urgent manager intervention notification.
- AI support: reply recommendation, autopilot replies, image-aware handling, controlled tool execution, knowledge retrieval, and learning candidates.
- Business support: device information lookup, order/after-sales facts, and package recommendation.

## Explicit Non-Goals For V1
- No tenant-specific custom code branches.
- No video understanding in the AI hot path.
- No dynamic image or video generation.
- No OpenSearch ownership of transactional truth.
- No Kafka, ClickHouse, or dedicated vector database as mandatory day-one dependencies.

## Architecture Principles
- Every request, event, cache key, search document, and object key must include a trusted `tenant_id`.
- Realtime chat is the hot path. AI, quality inspection, analytics, and search indexing are side lanes.
- PostgreSQL is the source of truth for messages, conversations, audit, AI configuration, and knowledge metadata.
- OpenSearch is a derived read model for chat history search only.
- AI must use explicit policy, explicit tools, explicit audit, and explicit fallback.
- Anything that can affect routing, tenancy, billing, or device operations must fail closed and fail loudly.

## Top-Level Service Map
- Edge services:
  - `api-gateway`
  - `realtime-gateway`
- Core business services:
  - `identity-service`
  - `channel-service`
  - `conversation-service`
  - `routing-service`
  - `media-service`
  - `search-service`
  - `knowledge-service`
  - `ai-service`
  - `device-service`
  - `analytics-service`

## Operating Model
- External inbound traffic enters via `api-gateway`.
- Channel webhooks are verified and normalized by `channel-service`.
- Durable message and conversation state are owned by `conversation-service`.
- Queueing, assignment, transfer, and agent state are owned by `routing-service`.
- High-risk intervention rules, intervention acknowledgement, and management alert dispatch are owned by `routing-service`.
- Realtime fan-out to agent and supervisor consoles is owned by `realtime-gateway`.
- AI decisions, knowledge retrieval, and controlled tool execution are owned by `ai-service`.
- Search projections are built asynchronously by `search-service` from domain events.

## Realtime And Performance Targets
- Message ingress to agent push:
  - `p95 < 800ms`
  - `p99 < 2s`
- Agent outbound send to upstream accept:
  - `p95 < 1s`
- AI text or text+image assist response:
  - `p95 < 1.5s`
- Daily tenant volume baseline:
  - `700k` messages/day
  - `10x` traffic spike planning
  - `200+` concurrent online agents

## Delivery Stages
1. Design package and ADR baseline.
2. Platform baseline and shared contracts.
3. Realtime conversation loop.
4. Search read-side and agent search experience.
5. AI assist, multimodal image handling, and controlled tools.
6. Knowledge release, analytics, and quality inspection.
