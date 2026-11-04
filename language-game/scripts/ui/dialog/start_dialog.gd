extends Node

@onready var dialog_player: CanvasLayer = $DialogPlayer

@export var prompt_dialog: String
@export_file var dialog_file

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog_player.load_dialog_file(dialog_file)
	dialog_player.start_dialog(prompt_dialog)
