extends VBoxContainer
## 子智能体 —— 这个页面是插件自己提供的界面。
## 界面全部由插件自己拼，主程序只提供积木。

func build(plugin_id: String) -> void:
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	add_child(PluginUI.section("子智能体"))
	add_child(PluginUI.hint("它会另起一个模型实例做子任务，只把结果交回来。代价是额外占一份内存（3B 约 2 GB）。"))
	add_child(PluginUI.slider_row(plugin_id, "max_tokens", "子任务最多写多长", 128, 2048, 128, "token", 512, ""))
	add_child(PluginUI.overview(plugin_id))
	add_child(PluginUI.permissions_section(plugin_id))
	add_child(PluginUI.doc_section(plugin_id))
