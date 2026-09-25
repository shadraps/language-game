extends CanvasLayer
## Main controller for loading dialog from input JSON file and 

@export_file var scene_text_file

@onready var container: Container = $HBoxContainer
@onready var speaker: Label = $HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Speaker
@onready var dialog: Label = $HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Dialog

@onready var options_container: VBoxContainer = $HBoxContainer/ScrollContainer/OptionsContainer
@onready var sample_button: Button = $HBoxContainer/ScrollContainer/OptionsContainer/SampleButton

const CLOSE_TEXT = "Close" # button text when closing dialog at very end
const CLOSE_SIGNAL = "END_DIALOG" # signal sent between functions internally to indicate end of dialog

var dialog_data: Dictionary
var current_dialog: Dictionary

#### BUILT-IN METHODS ####

func _ready() -> void:
	_initialize()

func _process(delta: float) -> void:
	pass
	
#### PUBLIC METHODS ####

func start_dialog(dialog_name: String) -> void:
	# finding dialog object
	var dialog_object = null
	if dialog_data.has(dialog_name):
		dialog_object = dialog_data[dialog_name]
	
	# Enabling display
	container.visible = true
	_display_dialog(dialog_object)
	
#### SIGNAL LISTENING ####

func on_interacted(dialog_name: String) -> void:
	start_dialog(dialog_name)
	
func _on_option_pressed(choice: String) -> void:
	# checking if end of dialog
	if choice == CLOSE_SIGNAL:
		_close_dialog()
		return
	
	# checking for next dialog
	assert(current_dialog != null, "current_dialog must not be null")
	assert(current_dialog.responses.has(choice), "The choice " + choice + " was not found in the current dialog")
	var next_dialog = current_dialog.responses[choice]
	
	# prompting next dialog
	_display_dialog(next_dialog)

#### INTERNAL HELPER METHODS ####

func _close_dialog() -> void:
	container.visible = false

func _display_dialog(dialog_object: Dictionary) -> void:
	
	# displaying core information
	speaker.text = dialog_object.speaker
	dialog.text = dialog_object.message
	
	# clearing previous options
	for button in options_container.get_children():
		if button != sample_button:
			button.queue_free()
	
	# displaying options
	var options: Dictionary = dialog_object.responses
	for choice in options:
		var button = _generate_option_button(choice)
		button.pressed.connect(
			_on_option_pressed.bind(choice),
			CONNECT_ONE_SHOT
		)
		
	# end button if no options
	if len(options.keys()) == 0:
		var button = _generate_option_button(CLOSE_TEXT)
		button.pressed.connect(
			_on_option_pressed.bind(CLOSE_SIGNAL),
			CONNECT_ONE_SHOT
		)
	
	# updating current dialog
	current_dialog = dialog_object
	
func _generate_option_button(option_text: String) -> Button:
	var button = sample_button.duplicate()
	button.text = option_text
	
	options_container.add_child(button)
	button.visible = true
	
	return button

func _load_scene_text():
	var file = FileAccess.open(scene_text_file, FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		dialog_data = json.data
	else:
		print("JSON Parse Error: ", json.get_error_message())
		dialog_data = {}
		
func _initialize() -> void:
	container.visible = false
	sample_button.visible = false
	_load_scene_text()
	
