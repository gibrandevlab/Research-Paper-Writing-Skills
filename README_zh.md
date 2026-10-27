# Skills: Research Paper Writing

**语言 / Language:**
[English](./README.md) | [Bahasa Indonesia](./README_id.md) | [日本語](./README_ja.md) | [العربية](./README_ar.md)

---

> **重要归属说明**
> 本仓库中的大部分写作经验与方法论来自彭思达老师公开的学习笔记：
> https://pengsida.notion.site/c1a22465a0fa4b15a12985223916048e
> 彭老师原始仓库：https://github.com/pengsida/learning_research
> 衷心感谢彭思达老师把这些宝贵经验公开分享出来。
> 我主要做了资料整理、结构化适配，以及 Skills 封装。

---

## 这是什么？

这个仓库为你的 AI 助手提供**深度学术论文写作知识** —— 基于彭思达老师的方法论，一位顶尖的 AI 研究者。

**一次配置，终身受益。** 之后只需像平常一样向 AI 提问，AI 会自动：
- 指导撰写 Abstract / Introduction / Method / Experiments / Conclusion
- 改善段落衔接与章节逻辑
- 检查 claim-evidence 对齐
- 从 reviewer 视角进行提交前自审

---

## 快速配置（3 步，只需一次）

### 第 1 步 — 克隆本仓库

**Windows（PowerShell）：**
```powershell
git clone https://github.com/gibrandevlab/Research-Paper-Writing-Skills.git
cd Research-Paper-Writing-Skills
```

**Mac / Linux（终端）：**
```bash
git clone https://github.com/gibrandevlab/Research-Paper-Writing-Skills.git
cd Research-Paper-Writing-Skills
```

> 没有 Git？请在 https://git-scm.com/downloads 下载

---

### 第 2 步 — 安装到你使用的 AI 编辑器

#### Gemini（Google）
```powershell
# Windows
xcopy /E /I research-paper-writing "%USERPROFILE%\.gemini\skills\research-paper-writing"
```
```bash
# Mac / Linux
cp -R research-paper-writing ~/.gemini/skills/
```

#### Claude Code / Cline
```powershell
# Windows（全局安装）
xcopy /E /I research-paper-writing "%USERPROFILE%\.claude\skills\research-paper-writing"
```
```bash
# Mac / Linux（全局安装）
cp -R research-paper-writing ~/.claude/skills/
```

#### Cursor
打开 Cursor → Settings → AI → 将 `research-paper-writing` 文件夹路径添加到 Skills 目录。

#### Codex（OpenAI）
```bash
mkdir -p "$CODEX_HOME/skills"
cp -R research-paper-writing "$CODEX_HOME/skills/"
```

---

### 第 3 步 — 打开 AI 编辑器，开始提问

**完成。** 无需其他配置。AI 将自动知道如何帮助你。

---

## 日常使用方法

直接打开 AI 编辑器，像平常一样提问 —— 无需特殊命令，无需记住任何工具名称。

**撰写 Abstract：**
> "帮我写一段 abstract。我论文的主要贡献是一种新的三维目标检测方法，速度比 SOTA 快 2 倍。"

**改进 Introduction：**
> "我的 introduction 读起来不流畅，能帮我 review 并改进吗？"

**检查 Method 部分：**
> "我的 Method 部分是否清晰地解释了为什么需要模块 X？"

**提交前 review：**
> "请从 CVPR reviewer 的视角 review 我的论文。"

**AI 会给出结构化的专业指导** —— 你无需了解任何工具名称、命令或配置。

---

## 支持的 AI 编辑器

| AI / 编辑器 | 状态 |
|---|---|
| Claude Code | ✅ 全自动 |
| Gemini / Antigravity | ✅ 全自动 |
| Cursor | ✅ 自动（规则始终激活） |
| Cline | ✅ 全自动 |
| GitHub Copilot | ✅ 自动（会话开始时读取上下文） |
| OpenAI Codex | ✅ 完全支持 |
| 其他 AI | ✅ 手动模式（让 AI 加载上下文） |

---

## 跨会话记忆（.ai-context）

本仓库包含共享记忆系统，这意味着：
- 在不同 AI 编辑器中处理同一篇论文？**所有 AI 共享相同的上下文。**
- AI 不会"忘记"之前会话中讨论的内容。
- 从 Cursor 切换到 Claude Code？没问题 —— 上下文会自动延续。

这一切都在**后台自动运行** —— 你无需做任何操作。

---

## 致谢

再次说明：仓库核心知识来源于彭思达老师公开笔记；我主要负责整理与 Skills 化适配。
彭老师原始仓库：https://github.com/pengsida/learning_research

## 许可证

本项目采用 MIT License，详见 [LICENSE](./LICENSE)。
