extends Node
## 子智能体插件 · local-harness
## 工具：subagent_ask(task, system?, max_tokens?)
##
## 做法：另起一个 llama-server（另一个端口、独立上下文），一次性问完就把进程杀掉。
## 好处：子任务不占主对话的上下文，也不会被主对话的提示词带偏。
## 注意：会额外吃一份内存（同一个模型再加载一次），小模型没问题，3B 以上要小心。

const PORT := 18766
const START_TIMEOUT := 120.0


func _app() -> Node:
	var ml := Engine.get_main_loop()
	return ml.root.get_node_or_null("/root/App") if ml != null else null



func _pref(key: String, def_value):
	# 直接读设置文件：在后台线程里也能用（不能碰场景树）
	var f := FileAccess.open("user://plugin_settings.json", FileAccess.READ)
	if f == null:
		return def_value
	var obj = JSON.parse_string(f.get_as_text())
	if not (obj is Dictionary):
		return def_value
	var vals: Dictionary = obj.get("values", {})
	var mine: Dictionary = vals.get("subagent", {})
	return mine.get(key, def_value)

func run(tool: String, args: Dictionary) -> Dictionary:
	if tool != "subagent_ask":
		return {"ok": false, "output": "未知工具：%s" % tool}
	var task := str(args.get("task", "")).strip_edges()
	if task == "":
		return {"ok": false, "output": "task 不能为空"}
	var a := _app()
	if a == null:
		return {"ok": false, "output": "取不到主程序状态"}
	var model := str(a.current_model)
	var backends: Dictionary = a.backends
	var backend := str(a.effective_backend())
	var exe := str(backends.get(backend, ""))
	if exe == "" or model == "":
		return {"ok": false, "output": "没有可用的模型或后端"}
	var ngl: int = int(a.cfg.get("gpu_layers", -1)) if backend != "cpu" else 0
	if ngl < 0:
		ngl = 999
	var max_tokens: int = int(args.get("max_tokens", int(_pref("max_tokens", 512))))

	var pid := _spawn(exe, [
		"-m", model,
		"-c", "2048",
		"-t", "4",
		"-ngl", str(ngl),
		"--host", "127.0.0.1",
		"--port", str(PORT),
		"--no-warmup",
	])
	if pid <= 0:
		return {"ok": false, "output": "子智能体进程启动失败"}

	var ok := _wait_health()
	if not ok:
		_kill(pid)
		return {"ok": false, "output": "子智能体在 %.0f 秒内没起来（可能是内存不够）" % START_TIMEOUT}

	var messages: Array = []
	var sys := str(args.get("system", "")).strip_edges()
	if sys != "":
		messages.append({"role": "system", "content": sys})
	messages.append({"role": "user", "content": task})
	var body := JSON.stringify({
		"messages": messages,
		"stream": false,
		"temperature": 0.3,
		"max_tokens": max_tokens,
	})
	var reply := _post_chat(body)
	_kill(pid)
	if reply == "":
		return {"ok": false, "output": "子智能体没有返回内容"}
	return {"ok": true, "output": reply}


func _spawn(exe: String, args: Array) -> int:
	return OS.create_process(exe, PackedStringArray(args), false)


func _kill(pid: int) -> void:
	if pid > 0:
		OS.kill(pid)
		OS.delay_msec(120)


func _wait_health() -> bool:
	var t0 := Time.get_ticks_msec()
	while (Time.get_ticks_msec() - t0) / 1000.0 < START_TIMEOUT:
		var out: Array = []
		var code := OS.execute("curl.exe", PackedStringArray([
			"-s", "-o", "NUL", "-w", "%{http_code}", "-m", "2",
			"http://127.0.0.1:%d/health" % PORT]), out, true)
		if code == 0 and out.size() > 0 and str(out[0]).strip_edges() == "200":
			return true
		OS.delay_msec(500)
	return false


func _post_chat(body: String) -> String:
	var req_path := OS.get_temp_dir().path_join("lh_subagent_req_%d.json" % randi())
	var out_path := OS.get_temp_dir().path_join("lh_subagent_out_%d.json" % randi())
	var f := FileAccess.open(req_path, FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(body)
	f.close()

	var out: Array = []
	var url := "http://127.0.0.1:%d/v1/chat/completions" % PORT
	var code := OS.execute("curl.exe", PackedStringArray([
		"-s", "-m", "180", "-H", "Content-Type: application/json",
		"--data-binary", "@" + req_path, "-o", out_path, url]), out, true)
	var text := ""
	if FileAccess.file_exists(out_path):
		var of := FileAccess.open(out_path, FileAccess.READ)
		if of:
			text = of.get_as_text()
		DirAccess.remove_absolute(out_path)
	DirAccess.remove_absolute(req_path)
	if code != 0 or text.strip_edges() == "":
		return ""
	var obj = JSON.parse_string(text)
	if obj is Dictionary and obj.has("choices"):
		var ch: Array = obj["choices"]
		if ch.size() > 0 and ch[0] is Dictionary:
			var msg: Dictionary = ch[0].get("message", {})
			var content = msg.get("content", "")
			if typeof(content) == TYPE_STRING:
				return str(content).strip_edges()
	return ""
