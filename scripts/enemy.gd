class_name DeadSectorEnemy
extends CharacterBody2D

signal defeated(enemy)

@export var enemy_type := "Hollow"
@export var max_health := 60.0
@export var move_speed := 72.0
@export var attack_damage := 10.0
@export var attack_cooldown := 1.0

var health := 60.0
var attack_timer := 0.0
var stun_timer := 0.0
var target: Node2D
var alive := true
var hit_flash := 0.0

func _ready() -> void:
	health = max_health
	z_index = 5
	queue_redraw()

func setup(kind: String, hp: float, speed: float, damage: float) -> void:
	enemy_type = kind
	max_health = hp
	move_speed = speed
	attack_damage = damage
	health = hp
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not alive:
		return
	attack_timer = max(0.0, attack_timer - delta)
	stun_timer = max(0.0, stun_timer - delta)
	hit_flash = max(0.0, hit_flash - delta)
	if is_instance_valid(target) and stun_timer <= 0.0:
		var offset := target.global_position - global_position
		var distance := offset.length()
		if distance > 42.0:
			velocity = offset.normalized() * move_speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			if attack_timer <= 0.0 and target.has_method("take_damage"):
				target.take_damage(attack_damage)
				attack_timer = attack_cooldown
	queue_redraw()

func take_damage(amount: float, critical := false) -> void:
	if not alive:
		return
	var final_damage := amount * (1.85 if critical else 1.0)
	health -= final_damage
	hit_flash = 0.10
	stun_timer = 0.16 if critical else 0.04
	if health <= 0.0:
		alive = false
		velocity = Vector2.ZERO
		defeated.emit(self)
		queue_free()
	queue_redraw()

func get_head_point() -> Vector2:
	return global_position + Vector2(0, -30)

func _draw() -> void:
	var flash := Color("#f4e4d7") if hit_flash > 0.0 else Color("#7b716e")
	if enemy_type == "Brute":
		_draw_brute(flash)
	elif enemy_type == "Crawler":
		_draw_crawler(flash)
	elif enemy_type == "Listener":
		_draw_listener(flash)
	else:
		_draw_hollow(flash)

func _draw_hollow(c: Color) -> void:
	# Shadow and grounded silhouette.
	draw_ellipse(Vector2(0, 18), Vector2(26, 11), Color(0.02,0.02,0.025,0.55))
	# Coat/body with torn hem.
	var body := PackedVector2Array([Vector2(-17,-13),Vector2(17,-13),Vector2(21,25),Vector2(8,19),Vector2(1,28),Vector2(-9,18),Vector2(-21,25)])
	draw_colored_polygon(body, c)
	draw_polyline(PackedVector2Array([Vector2(-17,-13),Vector2(17,-13),Vector2(21,25),Vector2(8,19),Vector2(1,28),Vector2(-9,18),Vector2(-21,25)]), Color("#312d32"), 3)
	# Head, neck, jaw.
	draw_circle(Vector2(0,-31), 15, Color("#4e4545"))
	draw_colored_polygon(PackedVector2Array([Vector2(-12,-27),Vector2(12,-27),Vector2(9,-14),Vector2(0,-9),Vector2(-10,-14)]), Color("#4a4042"))
	# Eyes / mouth.
	draw_circle(Vector2(-6,-34), 2.3, Color("#e4b96a"))
	draw_circle(Vector2(6,-34), 2.3, Color("#e4b96a"))
	draw_line(Vector2(-6,-35),Vector2(-10,-37),Color("#d9b2a0"),1.5)
	draw_line(Vector2(6,-35),Vector2(10,-37),Color("#d9b2a0"),1.5)
	draw_line(Vector2(-7,-24),Vector2(7,-24),Color("#211d20"),2)
	# Hands.
	draw_line(Vector2(-15,-3),Vector2(-29,10),Color("#6a5d5b"),6)
	draw_line(Vector2(15,-3),Vector2(29,9),Color("#6a5d5b"),6)
	# Chest seam and torn detail.
	draw_line(Vector2(0,-12),Vector2(0,19),Color("#494043"),2)
	draw_line(Vector2(-8,2),Vector2(-3,8),Color("#3a3337"),2)
	draw_line(Vector2(7,8),Vector2(14,3),Color("#3a3337"),2)

func _draw_brute(c: Color) -> void:
	draw_ellipse(Vector2(0,26), Vector2(38,13), Color(0.02,0.02,0.025,0.55))
	draw_circle(Vector2(0,-25), 21, Color("#3f3a3e"))
	draw_colored_polygon(PackedVector2Array([Vector2(-29,-10),Vector2(29,-10),Vector2(34,31),Vector2(16,38),Vector2(-17,38),Vector2(-35,24)]), c)
	draw_line(Vector2(-31,1),Vector2(-47,30),Color("#50474a"),13)
	draw_line(Vector2(31,1),Vector2(47,30),Color("#50474a"),13)
	draw_circle(Vector2(-8,-29), 3, Color("#e4b96a"))
	draw_circle(Vector2(8,-29), 3, Color("#e4b96a"))
	draw_line(Vector2(-9,-18),Vector2(9,-18),Color("#19161a"),4)

func _draw_crawler(c: Color) -> void:
	draw_ellipse(Vector2(0,20), Vector2(35,9), Color(0.02,0.02,0.025,0.55))
	draw_ellipse(Vector2(0,3), Vector2(26,15), c)
	draw_circle(Vector2(18,-7), 12, Color("#4c4648"))
	for side in [-1,1]:
		for i in 0..2:
			var y := -2.0 + i * 12.0
			draw_line(Vector2(side*16,y), Vector2(side*(35+i*4),y+12), Color("#5a4f50"), 5)
	draw_circle(Vector2(21,-10), 2.2, Color("#e4b96a"))
	draw_circle(Vector2(27,-7), 2.0, Color("#e4b96a"))

func _draw_listener(c: Color) -> void:
	draw_ellipse(Vector2(0,22), Vector2(24,10), Color(0.02,0.02,0.025,0.55))
	draw_colored_polygon(PackedVector2Array([Vector2(-15,-10),Vector2(15,-10),Vector2(19,25),Vector2(-18,25)]), c)
	draw_circle(Vector2(0,-27), 15, Color("#544c4e"))
	# Oversized sound-sensitive ears.
	draw_colored_polygon(PackedVector2Array([Vector2(-10,-34),Vector2(-29,-50),Vector2(-19,-22)]), Color("#625657"))
	draw_colored_polygon(PackedVector2Array([Vector2(10,-34),Vector2(29,-50),Vector2(19,-22)]), Color("#625657"))
	draw_circle(Vector2(-5,-28), 2, Color("#e4b96a"))
	draw_circle(Vector2(5,-28), 2, Color("#e4b96a"))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 0..24:
		var a := TAU * float(i) / 24.0
		pts.append(center + Vector2(cos(a)*radius.x, sin(a)*radius.y))
	draw_colored_polygon(pts, color)
