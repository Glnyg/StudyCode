# device-service

## 是什么
- 负责设备、订单、套餐等外部业务事实的防腐层服务。

## 在本项目里怎么用
- [[routing-service]] 在创建 [[UrgentIntervention]] 或 [[ResponseTimeoutAlert]] 后，可以向 [[device-service]] 请求受限的设备快照。
- [[ai-service]] 需要业务事实或受控工具时，也只能通过 [[device-service]] 读取或执行。
- 它把外部系统的不一致协议隔离在本服务边界内。

## 生产里要注意
- 它返回的是可信业务事实，不是 AI 推断结果。
- 外部调用超时或失败不能反过来阻塞聊天热路径。
- 所有外部动作和高风险读写都要可审计。

## 面试怎么说
- “device-service 是典型的防腐层，把设备和订单系统包成受控接口，避免外部 API 细节污染核心客服服务。”
