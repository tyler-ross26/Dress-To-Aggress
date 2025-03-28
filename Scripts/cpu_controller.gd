extends BaseCharacterController

var pressing_left = false
var pressing_right = false
var pressing_jump = false
var punch_pressed = false
var kick_pressed = false
var pose_pressed = false

enum Enemy_Range { POSE, PUNCH, KICK, FAR}
var range = Enemy_Range.POSE

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
	if Input.is_action_pressed("DEBUG_hurt_player"):
		while range != Enemy_Range.KICK:
			walk_closer()
	else:
		release_inputs()
	
	print(Enemy_Range.keys()[range])
	
	if not disabled:
		if pressing_left:
			direction = -1
		elif pressing_right:
			direction = 1
		elif (state != CharacterState.DASH) and (direction == 1 and not pressing_right) or (direction == -1 and not pressing_left):
			direction = 0
			block_legal = false
	
	find_range()
	handle_states(direction, delta)

func walk_closer():
	block_legal = false
	
	if facing_direction == 1:
		pressing_right = true
	elif facing_direction == -1:
		pressing_left = true

func walk_away():
	block_legal = true
	
	if facing_direction == 1:
		pressing_left = true
	elif facing_direction == -1:
		pressing_right = true

func jump_forward():
	walk_closer()
	pressing_jump = true

func jump_backward():
	walk_away()
	pressing_jump = true

func use_pose():
	pose_pressed = true

func dash_away():
	
	if (dash_available == false): return
	if disabled: return
	
	if state == CharacterState.IDLE or state == CharacterState.WALK or state == CharacterState.JUMP:
		if dashes_left == 1 and (current_time - last_dash_time >= DASH_COOLDOWN): #check that dash is off cooldown
			if (not is_on_floor() and MIDAIR_DASH) or (is_on_floor()):
				start_dash(-1)
		dash_direction = -1

func dash_towards():
	
	if (dash_available == false): return
	if disabled: return
	
	if state == CharacterState.IDLE or state == CharacterState.WALK or state == CharacterState.JUMP:
		if dashes_left == 1 and (current_time - last_dash_time >= DASH_COOLDOWN): #check that dash is off cooldown
			if (not is_on_floor() and MIDAIR_DASH) or (is_on_floor()):
				start_dash(1)
		dash_direction = 1

func find_range():
	if horizontal_distance <= 11:
		set_range(Enemy_Range.POSE)
	elif horizontal_distance <= 16:
		set_range(Enemy_Range.PUNCH)
	elif horizontal_distance <= 32:
		set_range(Enemy_Range.KICK)
	else:
		set_range(Enemy_Range.FAR)

func set_range(new_range):
	if dead: return
	
	range = new_range
	#print(str(player_type) + ": Enemy Range Updated: " + Enemy_Range.keys()[range])

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
