class_name DialogPlayer extends CanvasLayer
## Main controller for loading dialog from input JSON file and 

@export_file var dialog_file

@onready var container: Container = $HBoxContainer
@onready var speaker: Label = $HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Speaker
@onready var dialog: Label = $HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Dialog

@onready var options_container: VBoxContainer = $HBoxContainer/ScrollContainer/OptionsContainer
@onready var sample_button: Button = $HBoxContainer/ScrollContainer/OptionsContainer/SampleButton

const CLOSE_TEXT = "Close" # button text when closing dialog at very end
const CLOSE_SIGNAL = "END_DIALOG" # signal sent between functions internally to indicate end of dialog
const DEBUG = false

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
	
func load_dialog_file(_dialog_file) -> void:
	dialog_file = _dialog_file
	_load_scene_text()
	
#### SIGNAL LISTENING ####

func on_interacted(dialog_name: String) -> void:
	start_dialog(dialog_name)
	
func _on_option_pressed(choice: String, jump_path: Array = []) -> void:
	_dprint(jump_path)
	# checking if end of dialog
	if choice == CLOSE_SIGNAL:
		_close_dialog()
		return
		
	# jump to different dialog
	var next_dialog: Dictionary
	if jump_path.size() > 0:
		
		# iterating through dialog to find
		next_dialog = dialog_data[jump_path[0]]
		_dprint(next_dialog)
		for c in jump_path:
			_dprint("test: ", c, jump_path[0])
			if c == jump_path[0]:
				continue
				
			assert(next_dialog.responses.has(c), "There was no choice by name " + c)
			next_dialog = next_dialog.responses[c]
			_dprint(next_dialog)
		
	else:
		# checking for next dialog
		assert(current_dialog != null, "current_dialog must not be null")
		assert(current_dialog.responses.has(choice), "The choice " + choice + " was not found in the current dialog")
		next_dialog = current_dialog.responses[choice]
	
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
		_dprint("made choice button: ", choice)
		var button = _generate_option_button(choice)
		button.pressed.connect(
			_on_option_pressed.bind(choice),
			CONNECT_ONE_SHOT
		)
		
	# end button if no options, and checking for jump
	if dialog_object.jump.size() > 0:
		_dprint("made jump button")
		var button = _generate_option_button("Continue")
		button.pressed.connect(
			_on_option_pressed.bind("", dialog_object.jump),
			CONNECT_ONE_SHOT
		)
	elif len(options.keys()) == 0:
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
	var file = FileAccess.open(dialog_file, FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		dialog_data = json.data
	else:
		_dprint("JSON Parse Error: ", json.get_error_message())
		dialog_data = {}
		
func _initialize() -> void:
	container.visible = false
	sample_button.visible = false
	if dialog_file != null:
		_load_scene_text()

func _dprint(...args: Array) -> void:
	if DEBUG:
		print.callv(args)
