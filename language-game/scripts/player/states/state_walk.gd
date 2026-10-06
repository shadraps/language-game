class_name StateWalk extends State

@export var move_speed: float = 500.0

@onready var idle: StateIdle = $"../Idle"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"


# What happens when player enters this state
func Enter() -> void:
	animation_player.play("alien_guy_walk")
	pass
	
# What happens when player exits this staet
func Exit() -> void:
	pass
	
func Process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		return idle
		
	player.velocity = player.direction * move_speed
	
	return null
	
func Physics(_delta: float) -> State:
	return null
	
func HandleInput(_event: InputEvent) -> State:
	return null
