extends CharacterBody3D

# --- Variabel Logic Pergerakan ---
const KEPALSUAN_GRAVITASI = 9.8   # Kekuatan jatuh
const KECEPATAN_JALAN = 5.0      # Seberapa cepat karakter bergerak
const KEKUATAN_LOMPAT = 4.5       # Seberapa tinggi lompatan

# Variabel internal untuk sinkronisasi physics
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Fungsi yang berjalan setiap frame physics (sinkron)
func _physics_process(delta):
	# 1. Tambahkan Gravitasi (Logic dasar physics)
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Handle Lompat (Input Client)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = KEKUATAN_LOMPAT

	# 3. Handle Input Arah (W, A, S, D secara default di Godot)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * KECEPATAN_JALAN
		velocity.z = direction.z * KECEPATAN_JALAN
	else:
		# Gesekan (Friction) biar gak licin
		velocity.x = move_toward(velocity.x, 0, KECEPATAN_JALAN)
		velocity.z = move_toward(velocity.z, 0, KECEPATAN_JALAN)

	# 4. Terapkan Pergerakan ke Engine
	move_and_slide()
