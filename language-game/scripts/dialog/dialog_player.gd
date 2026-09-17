extends CanvasLayer

@export_file var scene_text_file

var scene_text = {}
var selected_text = []
var in_progress = false

@onready var container: PanelContainer = $PanelContainer
@onready var speaker: Label = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Speaker
@onready var dialog: Label = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Dialog

func _ready():
	container.visible = false
	scene_text = load_scene_text()
	SignalBus.connect("display_dialog", on_display_dialog)

func load_scene_text() -> Dictionary:
	var file = FileAccess.open(scene_text_file, FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		return json.data
	else:
		print("JSON Parse Error: ", json.get_error_message())
		return {}
	
func show_text():
	dialog.text = selected_text.pop_front()
	speaker.text = "You:"
	
func next_line():
	if selected_text.size() > 0:
		show_text()
	else:
		finish()
		
func finish():
	dialog.text = ""
	container.visible = false
	in_progress = false
	get_tree().paused = false
	
func on_display_dialog(text_key):
	if in_progress:
		next_line()
	else:
		get_tree().paused = true
		container.visible = true
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		show_text()
		
