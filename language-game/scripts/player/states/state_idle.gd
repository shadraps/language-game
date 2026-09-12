class_name StateIdle extends State

@onready var walk: StateWalk = $"../Walk"

# What happens when player enters this state
func Enter() -> void:
	# TODO update animation
	print("start idle animation")
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
