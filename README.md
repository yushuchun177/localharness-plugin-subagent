# 子智能体 / Sub-agent

另起一个独立的模型实例，带着自己的系统提示去处理子任务，只把结果交回来。

Spawn a separate model instance with its own system prompt for a subtask, returning only the result.

Local-Harness（Godot 版）的独立插件。**不随主程序发布**，由主程序「设置 → 插件管理」从 GitHub 下载并自动部署到 `user://plugins/subagent/`。

## 工具

- `subagent_ask` —— 把一段子任务交给新的模型实例去做（独立上下文，不污染当前对话）。适合拆分复杂任务、做评审。
  - `task`: string，子任务描述
  - `system`: string，可选，子智能体的角色设定
  - `max_tokens`: int，可选，默认 512

## 安装

1. Local-Harness → 设置 → 插件管理 → 刷新列表
2. 找到「子智能体」点安装
3. 装完直接在对话里让模型调用（插件会出现在系统提示的工具清单里）

手动安装：把仓库解压到 `%LOCALAPPDATA%\Godot\app_userdata\Local-Harness\plugins\subagent\`。

## 结构

```
manifest.json   清单：id / 版本 / 工具定义
main.gd         extends Node，实现 run(tool, args) -> {ok, output}
```

## 许可

GPL-3.0（与主程序一致）。完整协议文本见仓库根目录的 `LICENSE` 文件。
