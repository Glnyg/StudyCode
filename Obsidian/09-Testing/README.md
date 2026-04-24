# 09-Testing 阅读导航

## 这部分讲什么
- 这里讲“什么才算真正验证过”和“不同改动需要哪一层测试保护”。

## 为什么重要
- 这个仓库强调 tests have guarantees，不是随便有个测试就算覆盖。
- 如果没有验证基线和质量闸门，很多多租户、重放和 AI 边界问题会在上线后才暴露。

## 建议先读
1. [[验证基线]]
2. [[测试策略与质量闸门]]

## 对应正式文档
- `docs/testing/verification-baseline.md`
- `docs/testing/test-strategy-and-quality-gates.md`

## 读完去哪里
- 想回系统总览：[[01-Architecture/README|01-Architecture]]
- 想看搜索降级与重建：[[06-Search/README|06-Search]]
- 想看恢复语义：[[08-Reliability/README|08-Reliability]]
