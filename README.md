# 子智能体 / Sub-agent

另起一个独立的模型实例，带着自己的系统提示去处理子任务，只把结果交回来。

Spawn a separate model instance with its own system prompt for a subtask, returning only the result.

> Local-Harness（Godot 版）的独立插件。不随主程序发布，由主程序
> 「设置 → 插件管理」从 GitHub 下载并自动部署到 `user://plugins/subagent/`。

## 安装

1. 打开 Local-Harness → 设置 → 插件管理 → 刷新列表
2. 找到「子智能体」点「安装」
3. 装好后在侧栏底部点同名按钮，里面是这个插件自己的设置页

手动安装：把本仓库下载解压到 `%LOCALAPPDATA%\Godot\app_userdata\Local-Harness\plugins\subagent\`

## 工具

- `subagent_ask` —— 把一段子任务交给新的模型实例去做（独立上下文，不污染当前对话）。适合拆分复杂任务、做评审。（会产生操作）
  - `task`: string，子任务描述
  - `system`: string，可选，子智能体的角色设定
  - `max_tokens`: int，可选，默认 512

## 命令

（没有命令）

## 设置项

- **子智能体回复上限**（`max_tokens`，默认 `512`）

## 权限

每个工具都能在插件设置页里单独开关。关掉之后它不会出现在模型的工具清单里，
就算模型硬要调用也会被主程序拒绝。协议里用 `level` 标了风险等级：

- `read` 只读：不会改动任何东西
- `act` 会产生操作：会读写文件、联网或占用设备
- `danger` 高危：会操作你的系统

## 怎么用

装好后直接在对话里提需求，例如：“把一段子任务交给新的模型实例去做（独立上下文，不污染当前对话）。适合拆分复杂任务、做评审。”

模型会输出一行 ```tool 协议块，宿主解析后执行，再把结果喂回模型。
也可以直接用斜杠命令，不经过模型。

## 许可

GPL-3.0（与主程序一致）。完整协议文本见仓库根目录的 [LICENSE](LICENSE)。

---

# Sub-agent

Spawn a separate model instance with its own system prompt for a subtask, returning only the result.

> An independent plugin for **Local-Harness (Godot edition)**. It is not bundled with the
> app; the app downloads it from this repository into `user://plugins/subagent/` and hot-loads it.

## Install

1. Local-Harness → Settings → Plugins → Refresh
2. Find "Sub-agent" and click Install
3. Open it from the button at the bottom of the sidebar for its own settings page

Manual: unzip this repo into `%LOCALAPPDATA%\Godot\app_userdata\Local-Harness\plugins\subagent\`

## Tools

- `subagent_ask` — 把一段子任务交给新的模型实例去做（独立上下文，不污染当前对话）。适合拆分复杂任务、做评审。 (has side effects)
  - `task`: string，子任务描述
  - `system`: string，可选，子智能体的角色设定
  - `max_tokens`: int，可选，默认 512

## Commands

(no commands)

## Settings

- **子智能体回复上限** (`max_tokens`, default `512`) 

## Permissions

Every tool can be toggled individually on the plugin settings page. A disabled tool is
removed from the model's tool list and rejected by the host even if the model still calls it.
`level` in the manifest marks the risk:

- `read` — no side effects
- `act` — reads/writes, network or devices
- `danger` — controls your system

## Usage

Just ask in the chat, e.g. “把一段子任务交给新的模型实例去做（独立上下文，不污染当前对话）。适合拆分复杂任务、做评审。”

The model emits a ```tool block, the host executes it and feeds the result back.
You can also use the slash commands above, which skip the model entirely.

## License

GPL-3.0 (same as the host app). Full text: [LICENSE](LICENSE).
