extends CanvasLayer

func _ready() -> void:
	layer = 40
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	make_hold(root,"UP",Vector2(96,850),Vector2(84,62),"move_up")
	make_hold(root,"DOWN",Vector2(96,978),Vector2(84,62),"move_down")
	make_hold(root,"LEFT",Vector2(8,914),Vector2(84,62),"move_left")
	make_hold(root,"RIGHT",Vector2(184,914),Vector2(84,62),"move_right")
	make_hold(root,"FIRE",Vector2(512,850),Vector2(170,92),"fire")
	make_press(root,"MELEE",Vector2(492,954),Vector2(190,58),"melee")
	make_press(root,"RELOAD",Vector2(292,954),Vector2(174,58),"reload")
	make_press(root,"INTERACT",Vector2(292,1020),Vector2(174,42),"interact")

func make_hold(root:Control,text:String,pos:Vector2,size:Vector2,action:String)->void:
	var b:=Button.new(); b.position=pos; b.size=size; b.text=text; b.modulate=Color(1,1,1,0.28); b.add_theme_font_size_override("font_size",13)
	b.button_down.connect(func(): Input.action_press(action)); b.button_up.connect(func(): Input.action_release(action)); root.add_child(b)

func make_press(root:Control,text:String,pos:Vector2,size:Vector2,action:String)->void:
	var b:=Button.new(); b.position=pos; b.size=size; b.text=text; b.modulate=Color(1,1,1,0.28); b.add_theme_font_size_override("font_size",12); b.pressed.connect(func(): Input.action_press(action)); root.add_child(b)
