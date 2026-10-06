class_name StateIdle extends State

@onready var walk: StateWalk = $"../Walk"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

# What happens when player enters this state
func Enter() -> void:
	animation_player.play("alien_guy_idle")
	pass
	
# What happens when player exits this staet
func Exit() -> void:
	pass
	
func Process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null
	
func Physics(_delta: float) -> State:
	return null
	
func HandleInput(_event: InputEvent) -> State:
	return null
