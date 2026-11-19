extends Node

## GLOBAL VARIABLES

@export_file var crash_scene
@export_file var abuela_house

## BUILTIN METHODS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_scene(abuela_house)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## HELPER METHODS

func _set_scene(scene_file) -> void:
	get_tree().change_scene_to_file(scene_file)
