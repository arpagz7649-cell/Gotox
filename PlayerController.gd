extends CharacterBody3D

# --- SIGNAL SYSTEM (Untuk interaksi ke sistem luar/website) ---
signal on_player_death(pos)
signal on_data_synced(status)

# --- ENUMERATION (State Machine agar logic tidak tabrakan) ---
enum PlayerState { IDLE, WALKING, SPRINTING, JUMPING, FALLING, DEAD }

# --- EXPORT VARIABLES (Agar bisa diatur di Inspector Godot) ---
@export_group("Physics Configuration")
@export var MOUSE_SENSITIVITY: float = 0.002
@export var LUA_MODULE_PATH: String = "res://scripts/lua/CoreEntityModule.lua"

# --- PRIVATE VARIABLES ---
var _current_state: PlayerState = PlayerState.IDLE
var _lua_bridge: Object # Referensi ke plugin Lua
var _entity_data: Dictionary = {}
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Node References
@onready var camera = $Camera3D
@onready var mesh = $CharacterMesh

func _ready() -> void:
	initialize_lua_bridge()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func initialize_lua_bridge() -> void:
	# Memulai inisialisasi modul Luau yang ribet tadi
	# Ini logic "Handshake" antara Godot dan Lua
	print("System: Initializing Luau Core Interface...")
	_lua_bridge = Lua.new()
	
	var lua_file = FileAccess.get_file_as_string(LUA_MODULE_PATH)
	if lua_file:
		_lua_bridge.do_string(lua_file)
		# Membuat instance object di Lua (Metatable logic)
		_entity_data = _lua_bridge.call_function("EntityController.new", [get_name(), 001])
		on_data_synced.emit(true)
	else:
		push_error("CRITICAL: Luau Logic Module not found!")

func _unhandled_input(event: InputEvent) -> void:
	# Logic Kamera Pro: FPS Style dengan Clamp
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -deg_to_rad(85), deg_to_rad(85))

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_movement_logic(delta)
	move_and_slide()
	update_state_machine()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

func handle_movement_logic(_delta: float) -> void:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# MEMANGGIL LOGIC LUAU (Penerapan Bridge yang panjang)
	# Kita mengirim input mentah ke Lua, Lua mengembalikan Vector kecepatan
	var speed_multiplier = 1.0
	if Input.is_action_pressed("sprint"):
		speed_multiplier = 2.0
		_current_state = PlayerState.SPRINTING
	
	var lua_calculated_velocity = _lua_bridge.call_function(
		"EntityController:CalculateVelocity", 
		[_entity_data, Vector3(input_dir.x, 0, input_dir.y), speed_multiplier]
	)
	
	# Transformasi koordinat dari Lokal ke Global agar arah jalan sesuai hadap kamera
	var direction = (transform.basis * Vector3(lua_calculated_velocity.x, 0, lua_calculated_velocity.z)).normalized()
	
	if direction:
		velocity.x = direction.x * lua_calculated_velocity.length()
		velocity.z = direction.z * lua_calculated_velocity.length()
	else:
		velocity.x = move_toward(velocity.x, 0, 1.0)
		velocity.z = move_toward(velocity.z, 0, 1.0)

func update_state_machine() -> void:
	# Logic untuk menentukan animasi atau status di website nanti
	if is_on_floor():
		if velocity.length() > 0.1:
			_current_state = PlayerState.WALKING
		else:
			_current_state = PlayerState.IDLE
	else:
		_current_state = PlayerState.FALLING

func take_damage(amount: int) -> void:
	# Panggil logic Luau untuk kalkulasi HP
	var new_health = _lua_bridge.call_function("EntityController:ApplyDamage", [_entity_data, amount])
	print("Current Health from Luau: ", new_health)
	
	if new_health <= 0:
		_current_state = PlayerState.DEAD
		on_player_death.emit(global_position)
