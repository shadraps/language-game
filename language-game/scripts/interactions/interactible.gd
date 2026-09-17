extends Node2D

@onready var area_2d: Area2D = $Area2D

@onready var panel_container: PanelContainer = $CanvasLayer/PanelContainer

var enabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_display()

func _on_area_2d_area_entered(area: Area2D) -> void:
	enabled = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	enabled = false
	
func update_display() -> void:
	panel_container.visible = enabled
	
	if enabled:
		panel_container.offset_transform_position = position
