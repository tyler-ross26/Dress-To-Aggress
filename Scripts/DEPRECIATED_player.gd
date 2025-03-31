extends CharacterBody2D

#At the heart of the player controller, this is the ENUM that defines all the current states the player can be in. This will get longer as more states are added, and this should be the first place you go to add a new state.
enum CharacterState { IDLE, WALK, JUMP, DASH, STARTUP, RECOVERY, PUNCH, HURT }
var state = CharacterState.IDLE
var left_ground_check = false

@onready
var animation_player: AnimatedSprite2D = $AnimatedSprite2D

@onready
var punch_hitbox: Hitbox = $"Punch Hitbox"

@onready
var enemy = get_parent().get_node("Enemy")
var enemy_direction = 1

var direction := 0
var facing_direction = 1
var dash_direction = 0
var dashes_left = 1

#This Frame constant defines a frame as one sixtieth of a second, for consistent timing, and it means attacks can be defined in terms of frames (3 frame startup, 5 frame active, etc) which is consistent with the typical mechanics of fighting games. 
# A surprise tool that'll help us later!
const FRAME = 1.0 / 60.0
var current_time = 0

var last_left_press_time = 0.0
var last_right_press_time = 0.0

var last_dash_time = 0.0
var dash_timer = 0.0

var health = 100

@export var DOUBLE_TAP_TIME = 0.2 # Time window for double tap detection
@export var DASH_TIME = 0.20 # Dash lasts 0.20 seconds, lengthen this for a longer dash.
@export var DASH_SPEED = 90 # Set dash speed
@export var DASH_COOLDOWN = 0.2 # Half a second cooldown between valid dashes. This prevents the player from spamming dash across the screen, without stopping.
@export var MIDAIR_DASH = true

#Note for the below data: onBlock is positive because, if an attack is blocked, the player will transition to the RECOVERY state for (recovery + onBlock) frames. 
var attack_timer = 0.0
var punch_data = {
	"startup_frames" : 4,
	"active_frames" : 2,
	"recovery_frames" : 7,
	"blockstun_frames" : 11,
	"onBlock_FA" : -3,
	"ground_hitstun": 16,
	"air_hitstun" : 16,
	"ground_knockback_force" : 100,
	"air_knockback_force" : 50,
	"forward_force": 50,
	"damage": 10,
	"startup_animation" : "jump startup",
	"active_animation" : "punch",
	"recovery_animation" : "punch recovery",
}
var punch_deceleration = 10

#Defines the player's walk speed, and jump speeds.
@export var SPEED = 20.0
@export var VERTICAL_JUMP_VELOCITY = -250.0
@export var HORIZONTAL_JUMP_VELOCITY = 50

func apply_gravity(delta):
	if not is_on_floor():
		#We multiply gravity times 0.8 to make it slightly slower, so mess with this in tandem with the vertical jump velocity to change the player's jumping speed.
		velocity += (get_gravity() * 0.8) * delta

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_input(delta)
	face_your_opponent()

#This is the first function at the heart of the character controller functionality, called every frame. It handles taking in inputs, but also establishing what inputs are valid for each state, and calling the corresponding function for that state. 
func handle_input(delta):
	
	if Input.is_action_just_pressed("DEBUG_hurt_player"):
		get_hit_with(punch_data)
	
	current_time = Time.get_ticks_msec() / 1000.0  # Time in seconds
	
	if Input.is_action_just_pressed("player_left"):
		direction = -1
	elif Input.is_action_just_pressed("player_right"):
		direction = 1
	elif (state != CharacterState.DASH) and (direction == 1 and not Input.is_action_pressed("player_right")) or (direction == -1 and not Input.is_action_pressed("player_left")):
		direction = 0
	
	#This handles checking for the dash input, completely outside of the defined states below.
	if state == CharacterState.IDLE or state == CharacterState.WALK:
		if Input.is_action_just_pressed("player_left"):
			if current_time - last_left_press_time <= DOUBLE_TAP_TIME:
				if dashes_left == 1 and (current_time - last_dash_time >= DASH_COOLDOWN): #check that dash is off cooldown
					if (not is_on_floor() and MIDAIR_DASH) or (is_on_floor()):
						start_dash(-1)
				dash_direction = -1
			last_left_press_time = current_time
		
		if Input.is_action_just_pressed("player_right"):
			if current_time - last_right_press_time <= DOUBLE_TAP_TIME:
				if dashes_left == 1 and (current_time - last_dash_time >= DASH_COOLDOWN):
					if (not is_on_floor() and MIDAIR_DASH) or (is_on_floor()):
						start_dash(1)
				dash_direction = 1
			last_right_press_time = current_time
	
	#To add a new state, just add a new match case for that specific state, and similarly include the animation to be played and a call for that state's function. 
	match state:
		
		CharacterState.IDLE:
			animation_player.play("idle")
			idle_state(direction)
			
		CharacterState.WALK:
			if facing_direction == 1:
				if direction == 1:
					animation_player.play("walk forward")
				else:
					animation_player.play("walk backward")
			elif facing_direction == -1:
				if direction == 1:
					animation_player.play("walk backward")
				else:
					animation_player.play("walk forward")
			walk_state(direction)
		
		CharacterState.JUMP:
			animation_player.play("jump")
			jump_state(direction, delta)
		
		CharacterState.DASH:
			if dash_direction == 1:
				if facing_direction == -1: animation_player.play("dash left")
				else: animation_player.play("dash right")
			else:
				if facing_direction == -1: animation_player.play("dash right")
				else: animation_player.play("dash left")
				
			dash_state(delta)
		
		CharacterState.STARTUP:
			#Noting this to remember later. Freezing the player's horizontal velocity during startup might be a problem. 
			velocity.x = 0
		
		CharacterState.PUNCH:
			animation_player.play(punch_data["active_animation"])
			punch_state(delta)
		
		CharacterState.RECOVERY:
			velocity.x = move_toward(velocity.x, 0, punch_deceleration)
			disable_hitboxes()
		
		CharacterState.HURT:
			disable_hitboxes()
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, 25)
		
	
	move_and_slide()

#Every function below handles the actual logic for each state -- idle_state is called during the idle state, walk_state during the walk state, and so forth. As you could guess, each of those functions then define what can actually be done, and what inputs or conditions transfer us from state to state. 
func idle_state(direction):	
	if is_on_floor():
		dashes_left = 1
		
		if direction: 
			change_state(CharacterState.WALK)
		else:
			if Input.is_action_pressed("player_jump"):
				start_action(4, func(): start_jump(0), "jump startup")
				
			check_for_attack()
			disable_hitboxes()
			
			velocity.x = move_toward(velocity.x, 0, 20)

func walk_state(direction):
	if direction == 0:
		change_state(CharacterState.IDLE)
	elif Input.is_action_pressed("player_jump") and is_on_floor():
		start_action(4, func(): start_jump(direction), "jump startup")
	else:
		velocity.x = direction * SPEED
		check_for_attack()

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
	check_for_attack()
	
	if dash_timer > 0:
		dash_timer -= delta
	else:
		last_dash_time = current_time
		change_state(CharacterState.IDLE)

#This is where the code goes for the moment the punch is active. LATER ON, add the sound effect in this function.
func start_punch():
	attack_timer = punch_data["active_frames"] * FRAME
	velocity.x = punch_data["forward_force"] * facing_direction
	enable_punch_hitbox()
	
	change_state(CharacterState.PUNCH)

func punch_state(delta):
	velocity.x = move_toward(velocity.x, 0, punch_deceleration)
	
	if attack_timer > 0:
		attack_timer -= delta
	else:
		start_recovery(punch_data["recovery_frames"], punch_data["recovery_animation"])

func start_recovery(frames, animation):
	change_state(CharacterState.RECOVERY)
	
	animation_player.play(animation)
	var wait_time = frames * FRAME
	var timer = get_tree().create_timer(wait_time)
	timer.timeout.connect(func(): change_state(CharacterState.IDLE))

func get_hit_with(attack_data):
	change_state(CharacterState.HURT)
	
	animation_player.play("hurt")
	velocity.y = 0
	velocity.x = 0
	
	reduce_health(attack_data["damage"])
	
	#Stop all timers
	for child in get_parent().get_children():
		if child is Timer:
			child.stop()
	
	var wait_time = 0.0
	
	if is_on_floor():
		velocity.x = -1 * (facing_direction) * attack_data["ground_knockback_force"]
		wait_time = FRAME * attack_data["ground_hitstun"]
	else:
		velocity.y = -1 * attack_data["air_knockback_force"]
		velocity.x = -1 * (facing_direction) * attack_data["air_knockback_force"]
		
		wait_time = FRAME * attack_data["air_hitstun"]
	
	var timer = get_tree().create_timer(wait_time)
	timer.timeout.connect(func(): change_state(CharacterState.IDLE))

func start_action(frames, continuation, animation):
	change_state(CharacterState.STARTUP)
	
	animation_player.play(animation)
	
	var wait_time = frames * FRAME
	var timer = get_tree().create_timer(wait_time)
	#print("Creating a timer for " + str(wait_time))
	timer.timeout.connect(continuation)

#Mostly for debug. Updates the character state and prints it to the console. 
func change_state(new_state):
	state = new_state
	print("Character State Updated: " + CharacterState.keys()[state])

func check_for_attack():
	if Input.is_action_pressed("player_punch"):
		start_action(punch_data["startup_frames"], func(): start_punch(), punch_data["startup_animation"])

func attack_hit(target):
	print("I'm jaking it")
	print(target)
	
	if target.has_method("get_hit_with"):
		match state:
			CharacterState.PUNCH:
				print("Hitting " + str(target) + " with the almighty punch!")
				target.get_hit_with(punch_data)

func reduce_health(damage):
	health -= damage
	print(health)
	print("Ouch! I've been hurt!")
	
	if health == 0:
		#Handle the death logic here.
		print("Welp. I'm dead.")
	
	#This is where the code would go for playing a hurt sound effect -- IF I HAD ONE!!
	
	#This is ALSO where we'd call on the UI to reduce the health -- IF I HAD ONE!!

func enable_punch_hitbox():
	punch_hitbox.visible = true
	punch_hitbox.set_process(true)
	punch_hitbox.collision_layer = 2
	punch_hitbox.collision_mask = 1

func disable_hitboxes():
	punch_hitbox.visible = false
	punch_hitbox.set_process(false)
	punch_hitbox.collision_layer = 0
	punch_hitbox.collision_mask = 0

func face_your_opponent():
	enemy_direction = sign(enemy.global_position.x - global_position.x)
	
	if enemy_direction != 0 and enemy_direction != facing_direction:
		print("My opponent's on the other side. Flipping!")
		scale.x *= -1
		facing_direction *= -1
