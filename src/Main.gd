extends VBoxContainer


onready var global_lines := Node2D.new() # Parent node to hold all lines

onready var KeyPress = get_node("KeyPress")
onready var Placeholder = get_node("Placeholder")

onready var myu : Node = preload("res://src/MyUtilities.tscn").instance()


func _ready() -> void:
	myu.log_to_stdout(filename, "Enter scene tree")

	## Dark black background
	var bgnd_layer := CanvasLayer.new()
	bgnd_layer.layer = -1
	var bgnd_color := ColorRect.new()
	bgnd_color.anchor_right = ANCHOR_END
	bgnd_color.anchor_bottom = ANCHOR_END
	bgnd_color.color = Color8(0x14,0x14,0x13)
	bgnd_layer.add_child(bgnd_color, true)
	add_child(bgnd_layer, true)

	## Make this application fill the window and auto-resize
	anchor_right = ANCHOR_END
	anchor_bottom = ANCHOR_END

	## Use Placeholder to push KeyPress to screen bottom
	Placeholder.editor_only = false
	Placeholder.size_flags_vertical = SIZE_EXPAND_FILL

	## Add child that holds all lines for easy free
	add_child(global_lines)

	print_tree()

func _input(event) -> void:
	if event is InputEventKey:

		## Key just pressed
		if event.pressed and not event.echo:
			var key : String = OS.get_scancode_string(event.scancode)
			KeyPress.text = key
			if key == "Escape":
				keypress_esc()

		## Key released
		if not event.pressed:
			KeyPress.text = ""


func keypress_esc() -> void:
	myu.log_to_stdout(filename, "User quit with Esc")
	get_tree().quit()


## Testing I can draw lines
func _process(_delta) -> void:

	## Free all lines
	global_lines.free()

	## Make new lines
	global_lines = Node2D.new()
	add_child(global_lines)

	var line1 : Line2D
	var line2 : Line2D

	line1 = Line2D.new()
	line1.default_color = Color8(0x80,0x80,0xCC)
	line1.width = 1
	global_lines.add_child(line1)
	line2 = Line2D.new()
	line2.default_color = Color8(0xCC,0x80,0xCC)
	line2.width = 1
	global_lines.add_child(line2)

	## Draw new points
	line1.add_point(Vector2(randi()%142+100,randi()%42+100))
	line1.add_point(Vector2(randi()%142+200,randi()%42+200))
	line2.add_point(Vector2(randi()%142+100,randi()%42+100))
	line2.add_point(Vector2(randi()%142+200,randi()%42+200))

