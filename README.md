# gen-commit-msg

这是一个辅助生成 Git 提交信息的脚本工具。它通过分析当前 Git 分支名称和工作区的代码变更，提取关键上下文信息，旨在帮助开发者（或配合 AI 工具）快速生成符合规范的 Commit Message。

## 功能特性

*   **自动提取 Ticket Key**：从当前分支名称中解析出工单号（格式如 `PROJ-123`）。
*   **智能识别变更函数**：针对 Go 语言项目，尝试分析 `git diff` 并提取受影响的函数名称，作为提交信息的上下文参考。
*   **标准化输出**：生成包含 Key、函数名列表和完整 Diff 的结构化输出，便于脚本调用或 LLM（大语言模型）处理。

## 前置要求

*   Git
*   Bash 环境
*   Awk
*   当前工作目录需为一个 Git 仓库

## 安装与使用

你可以直接运行脚本，或者将其添加到你的 `PATH` 中。

```bash
# 赋予执行权限
chmod +x scripts/gen-commit-msg.sh

# 在 Git 仓库根目录下运行
./scripts/gen-commit-msg.sh
```

### 输出格式

脚本运行成功后，将输出以下格式的文本：

```text
KEY=SPLOP-123
NAMES=HandleRequest,ValidateInput
DIFF=<<EOF
diff --git a/main.go b/main.go
... (具体的 diff 内容) ...
EOF
```

*   `KEY`: 从分支名提取的工单号。
*   `NAMES`: 逗号分隔的变更函数名列表（目前主要支持 Go 语言）。
*   `DIFF`: `git diff --unified=0` 的完整输出。

## 配合 AI 使用建议

该工具的输出非常适合作为 Prompt 提供给 AI 助手，以生成标准化的提交信息。

**推荐的提交信息格式：**

```text
KEY: 动词+对象+目的
```

**示例：**

```text
SPLOP-123: 修复 HandleRequest 处理空指针异常以增强稳定性
```

## 错误处理

如果脚本执行遇到以下情况，将输出错误信息并以非零状态码退出：
*   无法获取分支名。
*   分支名中不包含合法的工单号（例如 `ABC-123`）。
*   工作区没有检测到代码变更。
