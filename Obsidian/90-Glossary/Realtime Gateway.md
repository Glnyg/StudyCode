# Realtime Gateway

## 是什么
- 专门负责实时连接和推送的边缘服务。

## 在本项目里怎么用
- 管理 [[SignalR]] 连接，把消息和状态变化推到坐席台和主管台。

## 生产里要注意
- 不要把业务决策放在这里。
- 它负责推送，不负责发明状态，也不替代 [[conversation-service]] 或 [[routing-service]] 做业务判断。

## 面试怎么说
- “Realtime Gateway 的职责是连接和推送，不应该承担消息真相和路由判断。”
