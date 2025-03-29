extends BaseCharacterController

var pressing_left = false
var pressing_right = false
var pressing_jump = false
var punch_pressed = false
var kick_pressed = false
var pose_pressed = false

enum Enemy_Range { POSE, PUNCH, KICK, FAR}
var range = Enemy_Range.POSE
var enemy_state = CharacterState.IDLE
var attacking = true
var current_enemy_attack = CharacterState.IDLE
var enemy_blocking = false

var pose_range = 11
var punch_range = 18
var kick_range = 32

var kick_time = 0.35
var punch_time = 0.15


func release_inputs():
	pressing_left = false
	pressing_right = false
	pressing_jump = false
	punch_pressed = false
	kick_pressed = false
	pose_pressed = false

func _ready():
	player_type = 0
	enemy_name = "Player"
	super._ready()

func handle_input(delta):
	horizontal_distance = abs(position.x - enemy.position.x)
	vertical_distance = enemy.global_position.y - global_position.y
	
	if Input.is_action_pressed("DEBUG_hurt_player"):
		dash_towards()
	
	if horizontal_distance > kick_range + 2:
		walk_closer()
	elif horizontal_distance < kick_range - 2:
		walk_away()
	else:
		release_inputs()
	
	if enemy_state == CharacterState.JUMP and horizontal_distance < kick_range - 2 and vertical_distance < 30:
		kick()
	
	if horizontal_distance <= pose_range:
		if is_on_floor(): use_pose()
	
	if (Input.is_action_just_pressed(enemy.punch_input) and horizontal_distance <= punch_range):
		block(punch_time)
	
	elif (Input.is_action_just_pressed(enemy.kick_input) and horizontal_distance <= kick_range):
		block(kick_time) 
	
	if not disabled:
		if pressing_left:
			direction = -1
		elif pressing_right:
			direction = 1
		elif (state != CharacterState.DASH) and (direction == 1 and not pressing_right) or (direction == -1 and not pressing_left):
			direction = 0
			block_legal = false
	
	find_range()
	find_state()
	check_enemy_attack()
	handle_states(direction, delta)

func walk_closer():
	
	block_legal = false
	
	if facing_direction == 1:
		pressing_left = false
		pressing_right = true
	elif facing_direction == -1:
		pressing_right = false
		pressing_left = true

func walk_away():
	block_legal = true
	
	if facing_direction == 1:
		pressing_left = true
		pressing_right = false
	elif facing_direction == -1:
		pressing_right = true
		pressing_left = false

func jump_forward():
	pressing_left = false
	pressing_right = false
	walk_closer()
	pressing_jump = true
	await get_tree().create_timer(0.1).timeout
	pressing_jump = false
	pressing_left = false
	pressing_right = false

func jump_away():
	walk_away()
	pressing_jump = true
	await get_tree().create_timer(0.2).timeout
	pressing_jump = false
	pressing_left = false
	pressing_right = false

func dash_away():
	
	if (dash_available == false): return
	if disabled: return
	
	if state == CharacterState.IDLE or state == CharacterState.WALK or state == CharacterState.JUMP:
		if dashes_left == 1 and (current_time - last_dash_time >= DASH_COOLDOWN): #check that dash is off cooldown
			if (not is_on_floor() and MIDAIR_DASH) or (is_on_floor()):
				start_dash(facing_direction * -1)
		dash_direction = facing_direction * -1

func dash_towards():
	
	if (dash_available == false): return
	if disabled: return
	
	if state == CharacterState.IDLE or state == CharacterState.WALK or state == CharacterState.JUMP:
		if dashes_left == 1 and (current_time - last_dash_time >= DASH_COOLDOWN): #check that dash is off cooldown
			if (not is_on_floor() and MIDAIR_DASH) or (is_on_floor()):
				start_dash(facing_direction)
		dash_direction = facing_direction

func find_range():
	if horizontal_distance <= pose_range:
		set_range(Enemy_Range.POSE)
	elif horizontal_distance <= punch_range:
		set_range(Enemy_Range.PUNCH)
	elif horizontal_distance <= kick_range:
		set_range(Enemy_Range.KICK)
	else:
		set_range(Enemy_Range.FAR)

func find_state():
	if "state" in enemy:
		enemy_state = enemy.state

func set_range(new_range):
	if dead: return
	
	range = new_range
	#print(str(player_type) + ": Enemy Range Updated: " + Enemy_Range.keys()[range])

func check_enemy_attack():
	if enemy_state == CharacterState.PUNCH or enemy_state == CharacterState.KICK or enemy_state == CharacterState.POSE:
		attacking = true
		current_enemy_attack = enemy_state
		if horizontal_distance <= kick_range: 
			pass
	else:
		attacking = false
		current_enemy_attack = null

func block(time):
	walk_away()
	await get_tree().create_timer(time).timeout
	pressing_left = false
	pressing_right = false

func punch():
	punch_pressed = true
	await get_tree().create_timer(0.2).timeout
	punch_pressed = false

func kick():
	kick_pressed = true
	await get_tree().create_timer(0.2).timeout
	kick_pressed = false

func jump():
	pressing_jump = true
	await get_tree().create_timer(0.1).timeout
	pressing_jump = false

func use_pose():
	pose_pressed = true
	await get_tree().create_timer(0.2).timeout
	pose_pressed = false


#Everything from here down is functions from the parent class, overridden so that the CPU controller isn't checking for player inputs.
func walk_state(direction):
	if direction == 0:
		change_state(CharacterState.IDLE)
	elif pressing_jump and is_on_floor():
		start_action(4, func(): start_jump(direction), "jump startup")
	else:
		velocity.x = direction * SPEED
		check_for_attack()
		check_for_pose()

func check_for_attack():
	if disabled == true: 
		return
	
	if punch_pressed:
		stop_all_timers()
		start_action(punch_data["startup_frames"], func(): 
			if state == CharacterState.STARTUP:
				start_punch()
			, punch_data["startup_animation"])
	
	if kick_pressed:
		stop_all_timers()
		start_action(kick_data["startup_frames"], func(): 
			if state == CharacterState.STARTUP:
				start_kick()
			, kick_data["startup_animation"])

func check_for_pose():
	if disabled: return
	
	if pose_pressed:
		stop_all_timers()
		start_pose()

func check_for_jump():
	if pressing_jump:
		start_action(4, func(): start_jump(0), "jump startup")
