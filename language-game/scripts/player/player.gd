class_name Player extends CharacterBody2D

@onready var state_machine: PlayerStateMachine = $StateMachine

var direction: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine.Initialize(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	

func _physics_process(delta: float) -> void:
	move_and_slide()
