class_name DoorInteractible extends Interactible

## PUBLIC VARIABLES

# export variables
@export_file var teleport_scene
@export var player_spawn_pos := Vector2.ZERO

# signals
signal interacted(dialogName: String)

## EVENT LISTENERS

func _on_interact() -> void:
	interacted.emit(teleport_scene, player_spawn_pos)
