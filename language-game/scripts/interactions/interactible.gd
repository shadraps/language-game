class_name Interactible extends Node2D

## PUBLIC VARIABLES

# object references
@onready var area_2d: Area2D = $Area2D
@onready var panel_container: PanelContainer = $CanvasLayer/PanelContainer

# states
var enabled: bool = false

# constants
const DEBUG = true

## BUILT-IN METHODS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_display()
	
## EVENT LISTENERS

func _on_area_2d_area_entered(area: Area2D) -> void:
	enabled = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	enabled = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and enabled:
		_on_interact()
		
func _on_interact() -> void:
	print("Interact not implemented yet")
	
## PUBLIC METHODS

func update_display() -> void:
	panel_container.visible = enabled
	
	if enabled:
		panel_container.offset_transform_position = get_viewport().get_canvas_transform() * global_position
		

## PRIVATE HELPER METHODS

func _dprint(...args: Array) -> void:
	if DEBUG:
		print.callv(args)
