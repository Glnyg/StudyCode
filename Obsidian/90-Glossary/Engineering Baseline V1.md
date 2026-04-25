# Engineering Baseline V1

## 它是什么
- 这是把设计包真正变成工程系统的实现冻结包。
- 它关心的是仓库怎么组织、环境怎么分层、CI/CD 怎么跑、[[Helm]] 和部署约定怎么统一。

## 为什么重要
- 如果没有统一的 engineering baseline（工程基线），每个 service 都会长成自己的小王国。
- 结果通常不是“灵活”，而是 local、CI、deploy 三套规则彼此不兼容。

## 本项目怎么用
- 它至少要冻结：
  - repository layout（仓库结构）
  - solution structure（解决方案结构）
  - shared building blocks（共享构件）边界
  - local development topology（本地开发拓扑）
  - 配置分层
  - CI pipeline stages（持续集成阶段）
  - [[Helm]] 约定
  - `local/dev/staging/production` 环境矩阵

## 工作里怎么落地
- 你可以把它理解成“团队默认工程规矩”。
- 以后新 service、shared library、测试项目、部署清单都应该沿着这套基线生长，而不是每次重新发明目录和流程。

## 面试里怎么表达
- “我会把工程基线当成实现前置条件来冻结，先统一仓库形态、环境分层和 CI/CD 规则，再开始大面积脚手架和服务落地。” 

## 你下一步应该看什么
1. [[Helm]]
2. [[Kubernetes]]
3. [[K8s 平台基线]]
4. [[开工前设计冻结清单]]
