class_name DialogInteractible
extends Interactible

signal interacted(dialogName: String)

@export var dialogName: String

func _on_interact() -> void:
	interacted.emit(dialogName)
