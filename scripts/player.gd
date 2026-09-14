class_name DeadSectorPlayer
extends CharacterBody2D

signal health_changed(value, max_value)
signal ammo_changed(mag, reserve)
signal shot_fired
signal interaction_requested

@export var move_speed := 205.0
@export var max_health := 100.0
@export var magazine_size := 8

var health := 100.0
var ammo := 8
var reserve := 40
var reload_timer := 0.0
var melee_timer := 0.0
var invulnerable_timer := 0.0
var recoil := 0.0
var aim_world := Vector2.ZERO
var camera: Camera2D
var last_move := Vector2.DOWN

func _ready() -> void:
	z_index = 10
	health = max_health
	ammo = magazine_size
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1200
	camera.limit_bottom = 1900
	add_child(camera)
	queue_redraw()
	health_changed.emit(health, max_health)
	ammo_changed.emit(ammo, reserve)

func _physics_process(delta: float) -> void:
	reload_timer = max(0.0, reload_timer - delta)
	melee_timer = max(0.0, melee_timer - delta)
	invulnerable_timer = max(0.0, invulnerable_timer - delta)
	recoil = move_toward(recoil, 0.0, delta * 7.0)
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir.length() > 0.1:
		last_move = input_dir.normalized()
	velocity = input_dir.normalized() * move_speed if input_dir.length() > 0.1 else Vector2.ZERO
	move_and_slide()
	global_position.x = clamp(global_position.x, 75.0, 1125.0)
	global_position.y = clamp(global_position.y, 150.0, 1710.0)
	if get_viewport().get_mouse_position() != Vector2.ZERO:
		aim_world = get_global_mouse_position()
	if Input.is_action_pressed("fire"):
		fire()
	if Input.is_action_just_pressed("reload"):
		reload_weapon()
	if Input.is_action_just_pressed("melee"):
		melee()
	if Input.is_action_just_pressed("interact"):
		interaction_requested.emit()
	queue_redraw()

func fire() -> void:
	if reload_timer > 0.0 or ammo <= 0:
		return
	ammo -= 1
	recoil = 1.0
	ammo_changed.emit(ammo, reserve)
	shot_fired.emit()
	var target := get_world_2d().direct_space_state
	var direction := (aim_world - global_position).normalized()
	var query := PhysicsRayQueryParameters2D.create(global_position + direction * 15.0, global_position + direction * 900.0)
	query.exclude = [self]
	query.collision_mask = 4
	var hit := target.intersect_ray(query)
	if not hit.is_empty():
		var collider = hit.get("collider")
		if collider and collider.has_method("take_damage"):
			var critical := false
			if collider.has_method("get_head_point"):
				critical = hit.get("position").distance_to(collider.get_head_point()) < 18.0
			collider.take_damage(34.0, critical)

func reload_weapon() -> void:
	if ammo >= magazine_size or reserve <= 0 or reload_timer > 0.0:
		return
	reload_timer = 0.9
	call_deferred("_finish_reload")

func _finish_reload() -> void:
	if reload_timer <= 0.0:
		return
	await get_tree().create_timer(reload_timer).timeout
	var needed := magazine_size - ammo
	var loaded := min(needed, reserve)
	ammo += loaded
	reserve -= loaded
	reload_timer = 0.0
	ammo_changed.emit(ammo, reserve)

func melee() -> void:
	if melee_timer > 0.0:
		return
	melee_timer = 0.55
	for node in get_tree().get_nodes_in_group("infected"):
		if not is_instance_valid(node):
			continue
		if global_position.distance_to(node.global_position) < 72.0:
			node.take_damage(24.0, false)

func take_damage(amount: float) -> void:
	if invulnerable_timer > 0.0:
		return
	invulnerable_timer = 0.45
	health = max(0.0, health - amount)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		get_tree().call_group("mission", "player_died")

func heal(amount: float) -> void:
	health = min(max_health, health + amount)
	health_changed.emit(health, max_health)

func add_ammo(amount: int) -> void:
	reserve += amount
	ammo_changed.emit(ammo, reserve)

func _draw() -> void:
	# Grounded shadow.
	var shadow := PackedVector2Array()
	for i in 0..24:
		var a := TAU * float(i) / 24.0
		shadow.append(Vector2(cos(a)*34.0, 18.0 + sin(a)*10.0))
	draw_colored_polygon(shadow, Color(0.01,0.01,0.02,0.52))
	# Boots and legs.
	draw_line(Vector2(-10,10),Vector2(-13,38),Color("#171a1e"),8)
	draw_line(Vector2(10,10),Vector2(13,38),Color("#171a1e"),8)
	draw_line(Vector2(-15,39),Vector2(-5,39),Color("#3b2c27"),6)
	draw_line(Vector2(5,39),Vector2(15,39),Color("#3b2c27"),6)
	# Utility jacket and red rescue scarf.
	draw_colored_polygon(PackedVector2Array([Vector2(-22,-23),Vector2(18,-23),Vector2(24,16),Vector2(8,27),Vector2(-8,27),Vector2(-25,12)]),Color("#3f5960"))
	draw_line(Vector2(-20,-12),Vector2(-32,10),Color("#596e74"),8)
	draw_line(Vector2(19,-10),Vector2(30,6),Color("#596e74"),8)
	draw_line(Vector2(-7,-22),Vector2(7,-22),Color("#a9453a"),5)
	# Head and hair.
	draw_circle(Vector2(0,-42), 18, Color("#a9745a"))
	draw_colored_polygon(PackedVector2Array([Vector2(-18,-44),Vector2(-9,-61),Vector2(9,-61),Vector2(18,-45),Vector2(9,-51),Vector2(-7,-49)]),Color("#242529"))
	draw_circle(Vector2(-6,-40),1.8,Color("#172025"))
	draw_circle(Vector2(6,-40),1.8,Color("#172025"))
	draw_line(Vector2(-5,-32),Vector2(5,-32),Color("#6a4138"),1.7)
	# Radio and shoulder patch.
	draw_rect(Rect2(-19,-9,7,11),Color("#172024"))
	draw_circle(Vector2(14,-16),4,Color("#d7c1a3"))
	# Weapon pointed toward aim.
	var aim := (aim_world-global_position).normalized() if aim_world != Vector2.ZERO else Vector2.RIGHT
	var gun_start := Vector2(15,-5)
	draw_line(gun_start, gun_start + aim*39.0, Color("#17191c"), 7)
	draw_line(gun_start + aim*34.0, gun_start + aim*49.0, Color("#8b7161"), 3)
