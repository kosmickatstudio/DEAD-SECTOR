extends Node2D
const Player=preload("res://scripts/player.gd")
const Enemy=preload("res://scripts/enemy.gd")
var player
var objective="Find the transmitter room"
var evidence=false
var transmitter=false
var objective_label:Label
var ammo_label:Label
var health_bar:ProgressBar
var hint:Label
func _ready():
	add_to_group("mission"); build_world(); spawn_player(); spawn_enemies(); build_hud(); queue_redraw()
func build_world():
	for x in [55,1145]: make_wall(Vector2(x,900),Vector2(40,1680))
	for y in [55,1780]: make_wall(Vector2(600,y),Vector2(1120,40))
	for d in [[Vector2(255,415),Vector2(330,34)],[Vector2(945,415),Vector2(330,34)],[Vector2(240,750),Vector2(34,390)],[Vector2(960,750),Vector2(34,390)],[Vector2(360,1370),Vector2(250,34)],[Vector2(840,1370),Vector2(250,34)]]: make_wall(d[0],d[1])
	for p in [[Vector2(600,245),"console"],[Vector2(315,610),"evidence"],[Vector2(1010,620),"supply"],[Vector2(170,1090),"supply"],[Vector2(600,1635),"exit"]]: make_prop(p[0],p[1])
func make_wall(pos,size):
	var b=StaticBody2D.new(); b.position=pos; b.collision_layer=1
	var s=CollisionShape2D.new(); var r=RectangleShape2D.new(); r.size=size; s.shape=r; b.add_child(s); add_child(b)
func make_prop(pos,kind):
	var a=Area2D.new(); a.position=pos; a.set_meta("kind",kind); add_child(a)
func spawn_player():
	player=Player.new(); player.position=Vector2(600,1510); player.collision_layer=2; player.collision_mask=1
	var s=CollisionShape2D.new(); var c=CapsuleShape2D.new(); c.radius=20; c.height=54; s.shape=c; player.add_child(s)
	player.health_changed.connect(on_health); player.ammo_changed.connect(on_ammo); player.interaction_requested.connect(on_interact); add_child(player)
func spawn_enemies():
	spawn_enemy("Hollow",Vector2(600,1120),52,76,10); spawn_enemy("Hollow",Vector2(460,960),52,80,10); spawn_enemy("Listener",Vector2(820,810),48,92,8); spawn_enemy("Crawler",Vector2(330,1160),40,108,9); spawn_enemy("Brute",Vector2(960,1210),150,46,18)
func spawn_enemy(kind,pos,hp,speed,dmg):
	var e=Enemy.new(); e.add_to_group("infected"); e.position=pos; e.collision_layer=4; e.collision_mask=2; e.setup(kind,hp,speed,dmg); e.target=player
	var s=CollisionShape2D.new(); var c=CapsuleShape2D.new(); c.radius=34 if kind=="Brute" else 22; c.height=82 if kind=="Brute" else 58; s.shape=c; e.add_child(s); add_child(e)
func build_hud():
	var layer=CanvasLayer.new(); layer.layer=30; add_child(layer)
	var root=Control.new(); root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); layer.add_child(root)
	var head=ColorRect.new(); head.position=Vector2(18,18); head.size=Vector2(684,92); head.color=Color(0.025,0.027,0.032,0.94); root.add_child(head)
	var title=Label.new(); title.position=Vector2(34,27); title.text="DEAD SECTOR  //  MISSION 01"; title.add_theme_font_size_override("font_size",20); root.add_child(title)
	objective_label=Label.new(); objective_label.position=Vector2(34,58); objective_label.text=objective; objective_label.add_theme_font_size_override("font_size",15); root.add_child(objective_label)
	var panel=ColorRect.new(); panel.position=Vector2(18,1040); panel.size=Vector2(684,112); panel.color=Color(0.02,0.022,0.026,0.96); root.add_child(panel)
	health_bar=ProgressBar.new(); health_bar.position=Vector2(34,1060); health_bar.size=Vector2(300,20); health_bar.max_value=100; health_bar.value=100; health_bar.show_percentage=false; root.add_child(health_bar)
	ammo_label=Label.new(); ammo_label.position=Vector2(360,1050); ammo_label.text="08 / 40"; ammo_label.add_theme_font_size_override("font_size",28); root.add_child(ammo_label)
	hint=Label.new(); hint.position=Vector2(34,1090); hint.text="WASD MOVE  •  FIRE HEADSHOT  •  E INTERACT  •  R RELOAD  •  F MELEE"; hint.add_theme_font_size_override("font_size",12); root.add_child(hint)
	make_button(root,"FIRE",Vector2(515,850),Vector2(170,92),func(): Input.action_press("fire")); make_button(root,"RELOAD",Vector2(510,955),Vector2(175,58),func(): player.reload_weapon()); make_button(root,"MELEE",Vector2(320,955),Vector2(170,58),func(): player.melee())
func make_button(root,text,pos,size,cb):
	var b=Button.new(); b.position=pos; b.size=size; b.text=text; b.modulate=Color(1,1,1,0.78); b.add_theme_font_size_override("font_size",15); b.pressed.connect(cb); root.add_child(b)
func _process(_d):
	if not transmitter and player.global_position.distance_to(Vector2(600,245))<105: hint.text="E  RESTORE TRANSMITTER"
	elif not evidence and player.global_position.distance_to(Vector2(315,610))<80: hint.text="E  COLLECT EVIDENCE"
	elif transmitter and player.global_position.distance_to(Vector2(600,1635))<110: hint.text="E  EXTRACT"
	else: hint.text="WASD MOVE  •  FIRE HEADSHOT  •  E INTERACT  •  R RELOAD  •  F MELEE"
	queue_redraw()
func on_interact():
	var p=player.global_position
	if not evidence and p.distance_to(Vector2(315,610))<80: evidence=true; objective="Evidence secured. Find the transmitter"; objective_label.text=objective
	elif evidence and not transmitter and p.distance_to(Vector2(600,245))<105: transmitter=true; objective="Signal restored. Reach extraction"; objective_label.text=objective; spawn_enemy("Hollow",Vector2(600,330),55,86,10); spawn_enemy("Listener",Vector2(420,330),48,95,8)
	elif transmitter and p.distance_to(Vector2(600,1635))<110: objective="MISSION COMPLETE  //  SIGNAL ESCAPED"; objective_label.text=objective; get_tree().paused=true
func on_health(value,max_value): health_bar.max_value=max_value; health_bar.value=value
func on_ammo(mag,reserve): ammo_label.text="%02d / %02d"%[mag,reserve]
func player_died(): get_tree().reload_current_scene()
func _draw():
	draw_rect(Rect2(0,0,1200,1900),Color("#15161a"))
	for row in 0..11:
		for col in 0..7:
			var x=70.0+col*140.0+(row%2)*25.0; var y=85.0+row*140.0; var c=Color("#2a292d") if (row+col)%2==0 else Color("#252529"); draw_rect(Rect2(x,y,125,120),c); draw_line(Vector2(x,y+120),Vector2(x+125,y),Color("#353439"),1)
	draw_polygon(PackedVector2Array([Vector2(470,80),Vector2(730,80),Vector2(890,1740),Vector2(310,1740)]),PackedColorArray([Color("#202126")]))
	draw_line(Vector2(70,415),Vector2(1130,415),Color("#534f4d"),5); draw_line(Vector2(70,1370),Vector2(1130,1370),Color("#4c4845"),5)
	draw_string(ThemeDB.fallback_font,Vector2(75,360),"SERVICE CORRIDOR // EAST WING",HORIZONTAL_ALIGNMENT_LEFT,450,17,Color("#74706b")); draw_string(ThemeDB.fallback_font,Vector2(760,360),"TRANSMITTER ACCESS",HORIZONTAL_ALIGNMENT_LEFT,300,17,Color("#74706b"))
