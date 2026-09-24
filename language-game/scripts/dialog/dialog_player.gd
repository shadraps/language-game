extends CanvasLayer
## Main controller for loading dialog from input JSON file and 

@export_file var scene_text_file

@onready var container: PanelContainer = $PanelContainer
@onready var speaker: Label = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Speaker
@onready var dialog: Label = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Dialog

var dialog_data: Dictionary

#### BUILT-IN METHODS ####

func _ready() -> void:
	container.visible = false
	dialog_data = _load_scene_text()

func _process(delta: float) -> void:
	pass
	
#### PUBLIC METHODS ####

func start_dialog(dialogName: String) -> void:
	print("Play dialog ", dialogName)
	
	# finding dialog object
	var dialog_object = null
	if dialog_data.has(dialogName):
		dialog_object = dialog_data[dialogName]
	
	# Enabling display
	container.visible = true
	_display_dialog(dialog_object)
	
#### SIGNAL LISTENING ####

func on_interacted(dialogName: String) -> void:
	start_dialog(dialogName)

#### INTERNAL HELPER METHODS ####

func _display_dialog(dialog_object: Dictionary):
	speaker.text = dialog_object.speaker
	dialog.text = dialog_object.message

func _load_scene_text() -> Dictionary:
	var file = FileAccess.open(scene_text_file, FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		return json.data
	else:
		print("JSON Parse Error: ", json.get_error_message())
		return {}
