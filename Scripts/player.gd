extends CharacterBody2D

enum CharacterState { IDLE, WALK, JUMP, DASH, STARTUP }
var state = CharacterState.IDLE
var left_ground_check = false

@onready
var animation_player: AnimatedSprite2D = $AnimatedSprite2D

var direction := 0
var dash_direction = 0
var dashes_left = 1

const FRAME = 1.0 / 60.0
var current_time = 0

var last_left_press_time = 0.0
var last_right_press_time = 0.0

var last_dash_time = 0.0
var dash_timer = 0.0

@export var DOUBLE_TAP_TIME = 0.2 # Time window for double tap detection
@export var DASH_TIME = 0.20 # Dash lasts 0.15 seconds
@export var DASH_SPEED = 90 # Set dash speed
@export var DASH_COOLDOWN = 0.2 # Half a second cooldown
@export var MIDAIR_DASH = true

@export var SPEED = 20.0
@export var VERTICAL_JUMP_VELOCITY = -250.0
@export var HORIZONTAL_JUMP_VELOCITY = 50

func apply_gravity(delta):
	if not is_on_floor():
		velocity += (get_gravity() * 0.8) * delta

func _physics_process(delta: float) -> void:
	
	#print(frame_count)
	
	apply_gravity(delta)
	handle_input(delta)

func handle_input(delta):
	
	current_time = Time.get_ticks_msec() / 1000.0  # Time in seconds
	
	if Input.is_action_just_pressed("player_left"):
		direction = -1
	elif Input.is_action_just_pressed("player_right"):
		direction = 1
	elif (state != CharacterState.DASH) and (direction == 1 and not Input.is_action_pressed("player_right")) or (direction == -1 and not Input.is_action_pressed("player_left")):
		direction = 0
	
	if state != CharacterState.DASH:
		if Input.is_action_just_pressed("player_left"):
			if current_time - last_left_press_time <= DOUBLE_TAP_TIME:
				if dashes_left == 1 and (current_time - last_dash_time >= DASH_COOLDOWN): #check that dash is off cooldown
					start_dash(-1)
				dash_direction = -1
			last_left_press_time = current_time
		
		if Input.is_action_just_pressed("player_right"):
			if current_time - last_right_press_time <= DOUBLE_TAP_TIME:
				if dashes_left == 1 and (current_time - last_dash_time >= DASH_COOLDOWN): # check that dash is off cooldown
					start_dash(1)
				dash_direction = 1
			last_right_press_time = current_time
	
	match state:
		
		CharacterState.IDLE:
			animation_player.play("idle")
			idle_state(direction)
			
		CharacterState.WALK:
			if direction == 1:
				animation_player.play("walk forward")
			else:
				animation_player.play("walk backward")
			walk_state(direction)
			
		CharacterState.JUMP:
			animation_player.play("jump")
			jump_state(direction, delta)
		
		CharacterState.DASH:
			if dash_direction == 1:
				animation_player.play("dash right")
			else:
				animation_player.play("dash left")
				
			dash_state(delta)
		
		CharacterState.STARTUP:
			velocity.x = 0
	
	move_and_slide()

func idle_state(direction):	
	if is_on_floor():
		dashes_left = 1
		
		if direction: 
			change_state(CharacterState.WALK)
		else:
			if Input.is_action_pressed("player_jump"):
				start_action(4, func(): start_jump(0), "jump startup")
			velocity.x = move_toward(velocity.x, 0, 20)

func walk_state(direction):
	if direction == 0:
		change_state(CharacterState.IDLE)
	elif Input.is_action_pressed("player_jump") and is_on_floor():
		start_action(4, func(): start_jump(direction), "jump startup")
	else:
		velocity.x = direction * SPEED

func start_jump(direction):
	left_ground_check = false
		
	velocity.y = VERTICAL_JUMP_VELOCITY
	
	if direction:
		velocity.x = direction * HORIZONTAL_JUMP_VELOCITY
	else:
		velocity.x = 0
	
	change_state(CharacterState.JUMP)

func jump_state(direction, delta):
	if not left_ground_check and not is_on_floor():
		left_ground_check = true
	
	if left_ground_check and is_on_floor():
		change_state(CharacterState.IDLE)
		print("Just landed!")

func start_dash(direction):
	dash_timer = DASH_TIME
	velocity.x = direction * DASH_SPEED
	if not is_on_floor():
		dashes_left = 0
	
	change_state(CharacterState.DASH)

func dash_state(delta):
	velocity.y = 0
	
	if dash_timer > 0:
		dash_timer -= delta
	else:
		last_dash_time = current_time
		change_state(CharacterState.IDLE)

func change_state(new_state):
	state = new_state
	print("Character State Updated: " + CharacterState.keys()[state])

func start_action(frames, continuation, animation):
	change_state(CharacterState.STARTUP)
	
	animation_player.play(animation)
	
	var wait_time = frames * FRAME
	var timer = get_tree().create_timer(wait_time)
	print("Creating a timer for " + str(wait_time))
	timer.timeout.connect(continuation)
