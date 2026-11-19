extends Node

## GLOBAL VARIABLES

@onready var scenes: Node2D = $Scenes

@onready var crashsite: Node2D = $Scenes/Crashsite
@onready var abuela_house: Node2D = $Scenes/AbuelaHouse

# player variables
var player: Player
var camera: Camera2D

## CONSTANTS

const DEBUG := true

## BUILTIN METHODS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# enabling visibility
	for scene in scenes.get_children():
		scene.visible = true
	
	# setting start scene
	_set_scene(crashsite)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## HELPER METHODS

func _set_scene_active(scene_node: Node2D, active: bool) -> void:
	scene_node.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	scene_node.visible = active
	
	player = scene_node.get_node("Player") 
	camera = player.get_node("Camera2D")
	_dprint("Player: ", player)
	_dprint("Camera: ", camera)
	camera.make_current()

func _set_scene(scene_node) -> void:
	for scene in scenes.get_children():
		_set_scene_active(scene, false)
		
	_set_scene_active(scene_node, true)
	
func _dprint(...args: Array) -> void:
	if DEBUG:
		print.callv(args)
