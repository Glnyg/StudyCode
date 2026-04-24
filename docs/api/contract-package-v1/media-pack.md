# Media Pack（媒体合同包）

## Scope（范围）
- 冻结 fixed assets（固定素材）的上传、审核、列表、预览 URL 合同。
- 冻结 `AssetItem`、`AttachmentRef` 和 preview access（预览访问）的最小可见字段。
- 冻结 media governance（媒体治理）对 `ai-service` 的 asset selection（素材选择）边界。

## APIs（接口）
- `OpenAPI`: [openapi/media-service.openapi.yaml](./openapi/media-service.openapi.yaml)

### HTTP Surface（HTTP 接口面）
- `POST /v1/assets`
- `POST /v1/assets/{asset_id}:review`
- `GET /v1/assets`
- `POST /v1/assets/{asset_id}:preview-url`

## Event Schemas（事件 Schema）
- `JSON Schema`: [schemas/asset-ai-events.schema.json](./schemas/asset-ai-events.schema.json)
- 当前覆盖的 event types：
  - `AssetSent`

## Contract Rules（合同规则）
- 资产上传必须带 `Idempotency-Key`。
- review transition（审核状态迁移）必须带 `If-Match`。
- preview URL 只返回短期签名结果，不返回底层对象存储 secret。
- `AssetItem` 必须保留以下字段：
  - `tenant_id`
  - `asset_type`
  - `business_tags`
  - `channel_support`
  - `review_status`
  - `effective_from`
  - `effective_to`
  - `version`

## Negative Cases（负例）
- preview another tenant asset（预览其他租户素材）：
  - `404 media.asset_not_found`
- selecting an unreviewed asset（选择未审核素材）：
  - `409 media.asset_not_reviewed`
- review request with stale version（用旧版本做审核请求）：
  - `409 conflict.version_mismatch`

## Compatibility Notes（兼容性说明）
- asset URL 永远不作为长期稳定字段暴露；只暴露 `preview_url` 和过期时间。
- `channel_support` 可以新增 channel 值，但旧 consumer 必须容忍未知枚举。
