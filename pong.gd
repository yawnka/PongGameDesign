extends Node2D

# Variables
var screen_size
var pad_size
var balls = []  # Array to store all active balls
var ball_speed = INITIAL_BALL_SPEED  # Speed of the balls
var direction = Vector2(1.0, 0.0)  # Default direction for new balls

# Constants
const INITIAL_BALL_SPEED = 80
const PAD_SPEED = 150
const SPAWN_INTERVAL = 10.0  # Time interval to spawn new balls (in seconds)

# Called when the node enters the scene tree for the first time
func _ready():
	screen_size = get_viewport_rect().size
	pad_size = get_node("left").get_texture().get_size()
	
	# Add the original ball to the balls array
	balls.append(get_node("ball"))
	
	# Set up a timer to spawn new balls
	var spawn_timer = Timer.new()
	spawn_timer.set_wait_time(SPAWN_INTERVAL)
	spawn_timer.set_one_shot(false)
	spawn_timer.connect("timeout", Callable(self, "_spawn_new_ball"))
	add_child(spawn_timer)
	spawn_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta):
	# Update each ball's position
	for ball in balls:
		var ball_pos = ball.get_position()
		var left_rect = Rect2(get_node("left").get_position() - pad_size * 0.5, pad_size)
		var right_rect = Rect2(get_node("right").get_position() - pad_size * 0.5, pad_size)
		
		# Move the ball
		ball_pos += ball.direction * ball.speed * delta
		
		# Bounce off top/bottom
		if (ball_pos.y < 0 and ball.direction.y < 0) or (ball_pos.y > screen_size.y and ball.direction.y > 0):
			ball.direction.y = -ball.direction.y
		
		# Bounce off paddles
		if (left_rect.has_point(ball_pos) and ball.direction.x < 0) or (right_rect.has_point(ball_pos) and ball.direction.x > 0):
			ball.direction.x = -ball.direction.x
			ball.direction.y = randf() * 2.0 - 1
			ball.direction = ball.direction.normalized()
			ball.speed *= 1.1
		
		# Reset if ball goes out of bounds
		if ball_pos.x < 0 or ball_pos.x > screen_size.x:
			_reset_game()
			return
		
		# Update ball position
		ball.set_position(ball_pos)
	
	# Move paddles
	var left_pos = get_node("left").get_position()
	if left_pos.y > 0 and Input.is_action_pressed("left_move_up"):
		left_pos.y -= PAD_SPEED * delta
	if left_pos.y < screen_size.y and Input.is_action_pressed("left_move_down"):
		left_pos.y += PAD_SPEED * delta
	get_node("left").set_position(left_pos)
	
	var right_pos = get_node("right").get_position()
	if right_pos.y > 0 and Input.is_action_pressed("right_move_up"):
		right_pos.y -= PAD_SPEED * delta
	if right_pos.y < screen_size.y and Input.is_action_pressed("right_move_down"):
		right_pos.y += PAD_SPEED * delta
	get_node("right").set_position(right_pos)

# Function to spawn a new ball
func _spawn_new_ball():
	var original_ball = get_node("ball")  # Reference the original ball
	var new_ball = original_ball.duplicate()  # Create a duplicate
	new_ball.set_position(screen_size * 0.5)  # Center the new ball
	new_ball.direction = Vector2(randf() * 2.0 - 1, randf() * 2.0 - 1).normalized()  # Randomize direction
	new_ball.speed = INITIAL_BALL_SPEED  # Reset speed for the new ball
	add_child(new_ball)  # Add the new ball to the scene tree
	balls.append(new_ball)  # Track the new ball

# Function to reset the game when a player loses
func _reset_game():
	for ball in balls:
		if ball != get_node("ball"):
			ball.queue_free()  # Remove additional balls
	balls.clear()
	
	var initial_ball = get_node("ball")
	initial_ball.set_position(screen_size * 0.5)
	initial_ball.direction = Vector2(-1, 0)
	initial_ball.speed = INITIAL_BALL_SPEED
	balls.append(initial_ball)
