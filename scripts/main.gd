extends Node2D

# DEAD SECTOR vertical slice: Mission 01 - The Broadcast
# This is the first Godot foundation pass. It deliberately avoids placeholder
# circles/grid aesthetics and establishes the authored visual language in code.

const VIEW := Vector2(720, 1280)
const WORLD_RECT := Rect2(44, 150, 632, 920)
const PLAYER_SPEED := 190.0
const BULLET_SPEED := 720.0
const MAG_SIZE := 8
const MAX_HP := 100.0

var player := Vector2(360, 720)
var player_hp := MAX_HP
var facing := Vector2.UP
var ammo := MAG_SIZE
var reserve := 40
var reload_timer := 0.0
var muzzle_flash := 0.0
var damage_flash := 0.0
var objective := "Reach the broadcast room"
var objective_progress := 0
var mission_time := 0.0
var interact_hint := "E  INTERACT"
var status_text := "RADIO STATIC DETECTED"
var reticle := Vector2(360, 520)
var enemies := []
var bullets := []
var pickups := []
var props := []

func _ready() -> void:
	_build_encounter()
	queue_redraw()

func _build_encounter() -> void:
	enemies = [
		{"pos": Vector2(182, 465), "hp": 36.0, "max_hp": 36.0, "speed": 34.0, "kind": "HOLLOW", "state": "idle"},
		{"pos": Vector2(545, 532), "hp": 44.0, "max_hp": 44.0, "speed": 27.0, "kind": "HOLLOW", "state": "idle"},
		{"pos": Vector2(278, 890), "hp": 50.0, "max_hp": 50.0, "speed": 25.0, "kind": "LISTENER", "state": "idle"},
		{"pos": Vector2(570, 858), "hp": 62.0, "max_hp": 62.0, "speed": 22.0, "kind": "BRUTE", "state": "idle"}
	]
	pickups = [
		{"pos": Vector2(130, 965), "type": "AMMO", "taken": false},
		{"pos": Vector2(604, 318), "type": "MEDKIT", "taken": false}
	]
	props = [
		{"rect": Rect2(82, 260, 128, 76), "type": "desk"},
		{"rect": Rect2(490, 245, 150, 88), "type": "broadcast"},
		{"rect": Rect2(94, 760, 110, 96), "type": "crate"},
		{"rect": Rect2(468, 690, 128, 104), "type": "crate"}
	]

func _process(delta: float) -> void:
	mission_time += delta
	_reload_tick(delta)
	_update_player(delta)
	_update_enemies(delta)
	_update_bullets(delta)
	_update_pickups()
	muzzle_flash = maxf(0.0, muzzle_flash - delta)
	damage_flash = maxf(0.0, damage_flash - delta)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		reticle = (event.position * (VIEW / get_viewport_rect().size)).clamp(WORLD_RECT.position + Vector2(8, 8), WORLD_RECT.end - Vector2(8, 8))
	if event.is_action_pressed("fire"):
		_fire()
	if event.is_action_pressed("reload"):
		_begin_reload()
	if event.is_action_pressed("melee"):
		_melee()
	if event.is_action_pressed("interact"):
		_interact()

func _update_player(delta: float) -> void:
	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vec.length() > 0.1:
		input_vec = input_vec.normalized()
		player += input_vec * PLAYER_SPEED * delta
		facing = input_vec
	player.x = clampf(player.x, WORLD_RECT.position.x + 24.0, WORLD_RECT.end.x - 24.0)
	player.y = clampf(player.y, WORLD_RECT.position.y + 34.0, WORLD_RECT.end.y - 30.0)
	if reload_timer <= 0.0 and Input.is_action_just_pressed("fire"):
		_fire()

func _update_enemies(delta: float) -> void:
	for e in enemies:
		if e.hp <= 0.0:
			continue
		var to_player: Vector2 = player - e.pos
		var dist := to_player.length()
		if dist < 330.0:
			e.state = "hunt"
			if dist > 64.0:
				e.pos += to_player.normalized() * e.speed * delta
			if dist < 58.0:
				_take_damage(8.0 * delta)

func _update_bullets(delta: float) -> void:
	for i in range(bullets.size() - 1, -1, -1):
		var b = bullets[i]
		b.pos += b.dir * BULLET_SPEED * delta
		b.life -= delta
		var removed := b.life <= 0.0 or not WORLD_RECT.grow(20).has_point(b.pos)
		if not removed:
			for e in enemies:
				if e.hp > 0.0 and e.pos.distance_to(b.pos) < 22.0:
					# Head-height timing: aiming within the upper 30% of the body is a critical hit.
					var critical := b.target_y < e.pos.y - 7.0
					e.hp -= 54.0 if critical else 20.0
					status_text = "HEADSHOT // %s" % e.kind if critical else "HIT // %s" % e.kind
					removed = true
					break
		if removed:
			bullets.remove_at(i)

func _update_pickups() -> void:
	for p in pickups:
		if p.taken:
			continue
		if player.distance_to(p.pos) < 34.0:
			if p.type == "AMMO":
				reserve += 16
				status_text = "+16 RESERVE AMMO"
			else:
				player_hp = minf(MAX_HP, player_hp + 35.0)
				status_text = "MEDICAL GEL +35"
			p.taken = true

func _fire() -> void:
	if reload_timer > 0.0:
		return
	if ammo <= 0:
		status_text = "MAGAZINE EMPTY // R TO RELOAD"
		return
	var direction := (reticle - player).normalized()
	if direction.length() < 0.1:
		direction = facing
	ammo -= 1
	muzzle_flash = 0.07
	bullets.append({"pos": player + direction * 24.0, "dir": direction, "life": 1.2, "target_y": reticle.y})
	status_text = "FIRE"

func _begin_reload() -> void:
	if reload_timer > 0.0 or ammo >= MAG_SIZE or reserve <= 0:
		return
	reload_timer = 0.9
	status_text = "RELOADING"

func _reload_tick(delta: float) -> void:
	if reload_timer <= 0.0:
		return
	reload_timer -= delta
	if reload_timer <= 0.0:
		var needed := MAG_SIZE - ammo
		var loaded := mini(needed, reserve)
		ammo += loaded
		reserve -= loaded
		status_text = "MAGAZINE READY"

func _melee() -> void:
	for e in enemies:
		if e.hp > 0.0 and e.pos.distance_to(player) < 72.0:
			e.hp -= 32.0
			status_text = "EMERGENCY BATON // CRUSH"
			return
	status_text = "BATON SWING"

func _interact() -> void:
	var nearest := 9999.0
	for p in props:
		var c: Vector2 = p.rect.get_center()
		nearest = minf(nearest, player.distance_to(c))
	if nearest < 110.0:
		objective_progress = 1
		objective = "Broadcast room unlocked. Find the transmitter."
		status_text = "TRANSMITTER ACCESS // SIGNAL 01"
	else:
		status_text = "NOTHING USEFUL HERE"

func _take_damage(amount: float) -> void:
	player_hp = maxf(0.0, player_hp - amount)
	damage_flash = 0.1
	if player_hp <= 0.0:
		player_hp = MAX_HP
		player = Vector2(360, 720)
		status_text = "LAST CHECKPOINT // THE CITY REMEMBERS"

func _draw() -> void:
	# Atmospheric foundation
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color("#080a0f"))
	draw_rect(Rect2(0, 0, 720, 122), Color("#11151d"))
	draw_rect(Rect2(0, 122, 720, 3), Color("#7f1f2b"))

	# Camera-like framing and illustrated street floor
	draw_rect(WORLD_RECT, Color("#171c22"))
	_draw_floor()
	_draw_walls()
	_draw_props()
	_draw_pickups()
	_draw_enemies()
	_draw_player()
	_draw_bullets()
	_draw_reticle()
	_draw_ui()

	if damage_flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.55, 0.05, 0.05, 0.12))

func _draw_floor() -> void:
	for y in range(174, 1055, 48):
		var shade := 0.045 if (y / 48) % 2 == 0 else 0.025
		draw_rect(Rect2(56, y, 608, 46), Color(0.12 + shade, 0.14 + shade, 0.16 + shade, 1.0))
	for x in range(74, 650, 72):
		draw_line(Vector2(x, 172), Vector2(x - 44, 1068), Color("#222932"), 1.0)
	for y in range(190, 1040, 96):
		draw_line(Vector2(54, y), Vector2(666, y), Color("#252b33"), 1.0)
	# wet reflection pools
	draw_ellipse(Vector2(356, 1000), Vector2(210, 18), Color(0.18,0.24,0.30,0.22))
	draw_ellipse(Vector2(185, 602), Vector2(82, 12), Color(0.20,0.25,0.29,0.18))

func _draw_walls() -> void:
	draw_rect(Rect2(44, 150, 632, 22), Color("#0b0e13"))
	draw_rect(Rect2(44, 1050, 632, 20), Color("#090c11"))
	draw_rect(Rect2(44, 150, 18, 920), Color("#0d1016"))
	draw_rect(Rect2(658, 150, 18, 920), Color("#0d1016"))
	# security door and light panels
	draw_rect(Rect2(308, 148, 104, 24), Color("#27313a"))
	draw_line(Vector2(332, 151), Vector2(332, 171), Color("#b6504e"), 2.0)
	draw_line(Vector2(388, 151), Vector2(388, 171), Color("#b6504e"), 2.0)

func _draw_props() -> void:
	for p in props:
		var r: Rect2 = p.rect
		if p.type == "desk":
			draw_rect(r, Color("#3a2923"), true)
			draw_rect(r.grow(-6), Color("#6a4933"), true)
			draw_rect(Rect2(r.position + Vector2(8, r.size.y - 12), Vector2(r.size.x - 16, 5)), Color("#201713"))
			draw_circle(r.position + Vector2(r.size.x - 22, 18), 5, Color("#d5c183"))
		elif p.type == "broadcast":
			draw_rect(r, Color("#202a33"), true)
			draw_rect(r.grow(-8), Color("#0d1318"), true)
			draw_rect(Rect2(r.position + Vector2(12, 14), Vector2(r.size.x - 24, 6)), Color("#7d2832"))
			for n in range(4):
				draw_line(Vector2(r.position.x + 22 + n * 24, r.position.y + 38), Vector2(r.position.x + 34 + n * 24, r.position.y + 26), Color("#56626c"), 2)
		elif p.type == "crate":
			draw_rect(r, Color("#433326"), true)
			draw_rect(r.grow(-5), Color("#6b4b31"), true)
			draw_line(r.position + Vector2(8,8), r.end - Vector2(8,8), Color("#2f241d"), 4)
			draw_line(Vector2(r.end.x - 8, r.position.y + 8), Vector2(r.position.x + 8, r.end.y - 8), Color("#2f241d"), 4)

func _draw_pickups() -> void:
	for p in pickups:
		if p.taken:
			continue
		var c: Vector2 = p.pos
		draw_circle(c, 18, Color(0.18,0.22,0.26,0.90))
		if p.type == "AMMO":
			draw_rect(Rect2(c - Vector2(9,7), Vector2(18,14)), Color("#c7a95b"))
			draw_line(c + Vector2(-5, -4), c + Vector2(5,-4), Color("#fff0b4"), 2)
		else:
			draw_rect(Rect2(c - Vector2(10,6), Vector2(20,12)), Color("#b85b55"))
			draw_line(c, c + Vector2(0,-10), Color("#f1d9cf"), 2)

func _draw_player() -> void:
	# Mara Voss, illustrated sprite language: tactical jacket, harness, sidearm.
	var shadow := Vector2(5, 14)
	draw_ellipse(player + shadow, Vector2(28, 11), Color(0,0,0,0.45))
	draw_circle(player + Vector2(0,-24), 13, Color("#b77963"))
	draw_colored_polygon(PackedVector2Array([
		player + Vector2(-18,-10), player + Vector2(18,-10), player + Vector2(24,25),
		player + Vector2(8,36), player + Vector2(-10,36), player + Vector2(-24,24)
	]), Color("#303b43"))
	draw_line(player + Vector2(-18,4), player + Vector2(-30,24), Color("#20282f"), 7)
	draw_line(player + Vector2(18,4), player + Vector2(30,24), Color("#20282f"), 7)
	draw_line(player + Vector2(-9,34), player + Vector2(-13,55), Color("#161c21"), 8)
	draw_line(player + Vector2(9,34), player + Vector2(14,55), Color("#161c21"), 8)
	draw_line(player + Vector2(0,-1), player + facing.normalized() * 26, Color("#8b9aa4"), 4)
	draw_circle(player + Vector2(0,-31), 4, Color("#d9b098"))
	# red emergency-response patch
	draw_rect(Rect2(player + Vector2(-8,2), Vector2(16,7)), Color("#8a2933"))

func _draw_enemies() -> void:
	for e in enemies:
		if e.hp <= 0.0:
			_draw_dead_enemy(e)
			continue
		var p: Vector2 = e.pos
		draw_ellipse(p + Vector2(0,16), Vector2(25,10), Color(0,0,0,0.45))
		var body := Color("#4a5150") if e.kind == "HOLLOW" else Color("#38453e") if e.kind == "LISTENER" else Color("#5b4740")
		draw_circle(p + Vector2(0,-17), 11, Color("#8c6a59"))
		draw_colored_polygon(PackedVector2Array([p+Vector2(-18,-5),p+Vector2(18,-5),p+Vector2(23,27),p+Vector2(-23,27)]), body)
		draw_line(p+Vector2(-8,26), p+Vector2(-12,46), Color("#25292a"), 8)
		draw_line(p+Vector2(8,26), p+Vector2(12,46), Color("#25292a"), 8)
		draw_line(p+Vector2(-14,3), p+Vector2(-28,19), body.darkened(0.25), 7)
		draw_line(p+Vector2(14,3), p+Vector2(27,14), body.darkened(0.25), 7)
		# head vulnerability marker, intentionally subtle until the reticle aligns.
		if reticle.distance_to(p + Vector2(0,-17)) < 28.0:
			draw_circle(p + Vector2(0,-17), 16, Color(0.75,0.13,0.15,0.16))
		_draw_enemy_bar(p, e.hp / e.max_hp)

func _draw_enemy_bar(pos: Vector2, ratio: float) -> void:
	draw_rect(Rect2(pos + Vector2(-22,-48), Vector2(44,4)), Color("#111317"))
	draw_rect(Rect2(pos + Vector2(-22,-48), Vector2(44 * clampf(ratio,0,1),4)), Color("#a13740"))

func _draw_dead_enemy(e: Dictionary) -> void:
	draw_ellipse(e.pos, Vector2(28, 10), Color(0.06,0.05,0.05,0.75))
	draw_line(e.pos + Vector2(-12,-2), e.pos + Vector2(13,9), Color("#313332"), 9)
	draw_line(e.pos + Vector2(-14,8), e.pos + Vector2(10,-4), Color("#262727"), 7)

func _draw_bullets() -> void:
	for b in bullets:
		draw_line(b.pos - b.dir * 10.0, b.pos, Color("#f0d28b"), 3)

func _draw_reticle() -> void:
	var lock := false
	for e in enemies:
		if e.hp > 0.0 and reticle.distance_to(e.pos + Vector2(0,-17)) < 28.0:
			lock = true
	var c := Color("#e4bd75") if lock else Color("#a5b0b7")
	draw_circle(reticle, 17, Color(0.05,0.06,0.07,0.22))
	draw_arc(reticle, 18, -0.9, 2.3, 18, c, 2.0)
	draw_arc(reticle, 18, 2.4, 5.6, 18, c, 2.0)
	draw_line(reticle + Vector2(-24,0), reticle + Vector2(-7,0), c, 2)
	draw_line(reticle + Vector2(7,0), reticle + Vector2(24,0), c, 2)
	draw_line(reticle + Vector2(0,-24), reticle + Vector2(0,-7), c, 2)
	draw_line(reticle + Vector2(0,7), reticle + Vector2(0,24), c, 2)

func _draw_ui() -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(28, 45), "DEAD SECTOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("#e8e2d7"))
	draw_string(font, Vector2(30, 77), "MISSION 01  //  THE BROADCAST", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#87919a"))
	draw_string(font, Vector2(30, 111), "DAY 01  •  02:17", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#65717b"))

	# health / ammunition panel
	draw_rect(Rect2(26, 1110, 668, 138), Color(0.035,0.045,0.055,0.94), true)
	draw_line(Vector2(26,1110), Vector2(694,1110), Color("#7f1f2b"), 2)
	draw_string(font, Vector2(44, 1140), "MARA VOSS", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#d3d6d8"))
	draw_string(font, Vector2(44, 1165), "EMERGENCY RESPONSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#7a858c"))
	draw_rect(Rect2(44, 1180, 214, 10), Color("#242a30"))
	draw_rect(Rect2(44, 1180, 214 * (player_hp / MAX_HP), 10), Color("#8d3340"))
	draw_string(font, Vector2(44, 1212), "HP %03d" % int(player_hp), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#b7bdc1"))
	draw_string(font, Vector2(315, 1147), "%02d / %02d" % [ammo, reserve], HORIZONTAL_ALIGNMENT_LEFT, -1, 31, Color("#e6e0d2"))
	draw_string(font, Vector2(318, 1170), "PISTOL AMMO", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#737f88"))
	draw_string(font, Vector2(318, 1205), "F  BATON    R  RELOAD    E  INTERACT", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#929ba1"))

	# objective card
	draw_rect(Rect2(28, 132, 664, 70), Color(0.055,0.065,0.075,0.92), true)
	draw_string(font, Vector2(45, 158), "OBJECTIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#a74a4f"))
	draw_string(font, Vector2(45, 184), objective, HORIZONTAL_ALIGNMENT_LEFT, 610, 16, Color("#d6d8d8"))
	# event strip
	draw_rect(Rect2(28, 1020, 270, 34), Color(0.055,0.065,0.075,0.92), true)
	draw_string(font, Vector2(42, 1043), status_text, HORIZONTAL_ALIGNMENT_LEFT, 240, 11, Color("#b5bbc0"))

func draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(32):
		var a := TAU * float(i) / 32.0
		points.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(points, color)
