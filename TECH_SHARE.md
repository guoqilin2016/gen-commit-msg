# 🚀 提效小工具分享：Gen-Commit-Msg —— 让 AI 帮我们写 Git 提交信息

## 👋 背景与痛点

在日常开发中，写 Commit Message 是一件"小"事，但往往也是一件"烦"事：
*   **格式不统一**：有的写了 Ticket 号，有的忘了；有的中文有的英文。
*   **上下文缺失**："Fix bug" —— 到底 Fix 了哪个函数的 bug？
*   **思维中断**：刚写完复杂的逻辑，还得停下来组织语言描述变更，容易打断心流。

虽然现在有很多 AI 辅助工具，但直接把整个 Diff 丢给 AI 往往因为上下文过多导致 Token 浪费，或者因为缺乏业务上下文（如工单号）导致生成的信息不够准确。

## 💡 解决方案：Gen-Commit-Msg

`gen-commit-msg` 是一个轻量级的 Bash 脚本工具，旨在**连接 Git 仓库与 AI 模型**。

它的核心理念是：**由脚本负责提取"硬"信息（工单号、变更函数名、Diff），由 AI 负责生成"软"描述（语义化总结）。**

### ✨ 核心功能

1.  **自动提取工单号**：从分支名（如 `feature/PROJ-123-login`）中直接提取 `PROJ-123`。
2.  **智能识别变更范围**：针对 Go 语言，自动分析 Diff 并反查源码，定位到具体改动了哪个**函数**。
3.  **标准化上下文输出**：生成格式化的 Key-Value 数据，完美适配 LLM Prompt。

## 🛠 技术实现深度解析

这个工具没有引入任何重型依赖，完全基于 `git`、`bash` 和 `awk` 实现，保证了极致的轻量和兼容性。

### 1. 极简的 Diff 获取
我们使用了 `--unified=0` 参数，只获取变更行本身，不带周围的上下文行，最大程度减少干扰信息：
```bash
diff=$(git diff --unified=0)
```

### 2. "穷人版" AST 解析 (The Magic of Awk)
这是脚本最有趣的部分。我们没有用复杂的 Go 解析器，而是用 `awk` 配合 `git diff` 的元数据实现了函数级定位。

**原理流程：**
1.  解析 Diff 输出，找到变更的文件名和行号。
2.  如果文件是 `.go` 结尾，读取本地文件。
3.  利用 `awk` 从变更行号向上回溯，找到最近的 `func` 关键字。
4.  正则清洗，提取纯函数名。

```bash
# 核心逻辑片段
cmd="awk -v n=" line " \"NR<=n{if ($0 ~ /^func /) last=$0} END{print last}\" \"" file "\""
```
*这种方法虽然不如 AST 精确，但在 90% 的场景下足够有效且速度极快。*

## 🤖 最佳实践 Workflow

建议将此工具集成到你的 shell alias 或 IDE 插件中。

**Step 1: 运行脚本**
```bash
$ ./scripts/gen-commit-msg.sh
KEY=SPLOP-123
NAMES=HandleRequest
DIFF=...
```

**Step 2: 发送给 AI (ChatGPT/Claude/Trae)**
将输出内容配合如下 Prompt：
> "使用以下上下文生成一个中文 Git Commit Message，格式为 'KEY: 动词+对象+目的'。"

**Step 3: 得到结果**
> `SPLOP-123: 优化 HandleRequest 函数的空值校验逻辑以防止 Panic`

## 🔮 未来规划

*   **多语言支持**：目前仅支持 Go 函数提取，计划增加 Python (def/class) 和 TS/JS 支持。
*   **Git Hook 集成**：通过 `prepare-commit-msg` 钩子自动填充模板。
*   **CLI 化**：用 Go 重写以获得更好的跨平台体验和更强的解析能力。

## 🔗 源码与贡献

仓库地址：[https://github.com/guoqilin2016/gen-commit-msg](https://github.com/guoqilin2016/gen-commit-msg)

欢迎大家试用并提 PR！让我们把写 Commit Message 变成一件自动化的乐事。
