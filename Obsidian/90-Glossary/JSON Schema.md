# JSON Schema

## 这是什么
- `JSON Schema` 是描述 `JSON` 数据结构的标准格式。
- 你可以把它理解成“给 JSON 用的字段规则说明书”。

## 为什么重要
- 它能把字段名、类型、必填项、枚举值和 example 写成统一标准。
- 这样事件、配置、异步 payload 和 contract test 都可以共用同一份规则。

## 在本项目里怎么用
- 这个项目把事件 envelope、事件 payload 和共享类型冻结成 `JSON Schema`。
- 这样 `conversation-service`、`routing-service`、`search-service`、`media-service`、`ai-service` 在异步协作时不会各说各话。
- 字段解释可以用中文辅助理解，但 `JSON Schema` 里的 property names（属性名）和正式 contract identity 保持英文，不在学习笔记里改名。

## 工作里怎么用
- 设计事件时先写 `JSON Schema`，再写 producer 和 consumer。
- 这样字段是否兼容、是否是 breaking change，会更容易检查出来。

## 面试怎么说
- “我会用 JSON Schema 固定事件和共享 payload，减少微服务之间的契约漂移，也方便自动化校验。”

## 你下一步应该看什么
1. [[Contract Package V1]]
2. [[OpenAPI]]
3. [[05-API/公共接口与事件目录|公共接口与事件目录]]
