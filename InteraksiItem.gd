extends Area3D

# --- Variabel Logic ---
# @export biar bisa diedit di Inspector Godot tanpa buka kode
@export var warna_baru: Color = Color(1, 0, 0) # Default Merah
var warna_asli: Color

# Referensi ke model visual objek
@onready var mesh_visual = $MeshInstance3D 

func _ready():
	# Ambil warna asli saat game mulai
	# Asumsi material ada di index 0
	var material = mesh_visual.get_surface_override_material(0)
	if material:
		warna_asli = material.albedo_color

# Fungsi Logic: Berjalan saat 'Player' masuk ke area objek ini
func _on_body_entered(body):
	# Cek apakah yang masuk adalah Player (berdasarkan nama node)
	if body.name == "Player":
		print("Logic Aktif: Player menyentuh item!")
		ganti_warna(warna_baru)

# Fungsi Logic: Saat Player pergi
func _on_body_exited(body):
	if body.name == "Player":
		print("Logic Aktif: Player pergi.")
		ganti_warna(warna_asli)

# Fungsi helper untuk mengubah warna material
func ganti_warna(warna):
	var material = mesh_visual.get_surface_override_material(0)
	if material:
		# Membuat material unik agar tidak semua item berubah warna
		var material_unik = material.duplicate()
		material_unik.albedo_color = warna
		mesh_visual.set_surface_override_material(0, material_unik)

