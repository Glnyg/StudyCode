# HTTP 状态码语义

## 它是什么
- `HTTP` 状态码语义，说的是一次 operator/public API 请求，到底应该用哪个真实状态码表达成功、失败、拒绝、冲突或依赖故障。

## 为什么重要
- 如果把真实失败包成 outer `200`，网关、日志、监控、告警和调用方很容易误判。
- 多租户系统里，auth、tenant、permission、dependency failure 都需要第一眼就能看出大类。

## 本项目怎么用
- operator/public API 出错时，默认直接返回真实 non-`2xx` HTTP status。
- body 里的 error envelope 继续提供 `code` 和 [[Error Source]]，帮助你区分到底是 gateway 先拒绝，还是系统自己失败。
- auth、tenant、permission、validation、conflict、dependency、internal failure 都不能靠 outer `200` 包装。
- 所有 `GET` surface 不接受 request body；如果客户端发送 body，应该直接返回 `400`。

## 工作里怎么落地
- 排障顺序固定为：
  1. 先看 HTTP status
  2. 再看 [[Error Source]]
  3. 最后看 `code`
- 设计接口时，复杂结构化读取如果需要请求体，就不要硬塞进 `GET`，而要显式建模成 `POST`。

## 面试里怎么表达
- “我会把 operator/public failure 先落到真实 HTTP status，再用 `error_source` 和业务 `code` 做二级定位。这样网关、观测和调用方的默认语义都不会被破坏。”

## 你下一步应该看什么
1. [[Error Source]]
2. [[Contract Package V1]]
3. [[02-Domain/租户解析与授权冻结包 V1|租户解析与授权冻结包 V1]]
