extends MarginContainer


# ---< DEVELOPER >---
onready var HudLeft: Label = get_node("Dev/HudLeft")
onready var HudRight: Label = get_node("Dev/HudRight")

# ---< APPLICATION USER >---
onready var global_lines := Node2D.new() # Parent node to hold all lines

onready var App:         VBoxContainer   = get_node("App")
onready var PlotArea:    MarginContainer = get_node("App/PlotArea")
onready var Placeholder: ReferenceRect   = get_node("App/PlotArea/Placeholder")
onready var KeyPress:    Label           = get_node("App/KeyPress")

# ---< LIBRARIES >---
onready var myu : Node = preload("res://src/MyUtilities.tscn").instance()


func _ready() -> void:
	## Randomize the seed for Godot's random number generator.
	randomize()

	## Say hello
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

	## Use PlotArea to push KeyPress to screen bottom
	PlotArea.size_flags_vertical = SIZE_EXPAND_FILL

	## Use Placeholder to visualize PlotArea
	Placeholder.editor_only = false

	# ---< DEBUG >---
	# Print the final Scene Tree
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

	## Write text to HUD text overlay
	## Write values in HudLeft text overlay
	HudLeft.Main = myu.report_size_and_position(self)
	HudLeft.App = myu.report_size_and_position(App)
	HudLeft.PlotArea = myu.report_size_and_position(PlotArea)
	HudLeft.Placeholder = myu.report_size_and_position(Placeholder)
	HudLeft.KeyPress = myu.report_size_and_position(KeyPress)
	HudLeft.Hud = myu.report_size_and_position(HudLeft)
	HudLeft.text = "{Main}\n{App}\n{PlotArea}\n{Placeholder}\n{KeyPress}\n{HudLeft}".format({
		"Main":HudLeft.Main,
		"App":HudLeft.App,
		"PlotArea":HudLeft.PlotArea,
		"Placeholder":HudLeft.Placeholder,
		"KeyPress":HudLeft.KeyPress,
		"HudLeft":HudLeft.Hud
		})
	## Write values in HudRight text overlay
	HudRight.Mouse = get_global_mouse_position()
	HudRight.text = "GLOBAL MOUSE: {Mouse}".format({
		"Mouse":HudRight.Mouse
		})

	## Free all lines
	global_lines.free()

	## Make new lines
	global_lines = Node2D.new()
	PlotArea.add_child(global_lines)

	var lines : Array = []
	for i in range(2):
		lines.append(new_line())
		global_lines.add_child(lines[i])
		lines[i].default_color = Color8(
			randi()%0xFF+0x80, # red
			randi()%0x80, # green
			randi()%0xFF+0x80  # blue
			)
		for _point in range(4):
			lines[i].add_point(Vector2(randi()%242+100,randi()%142+100))


func new_line() -> Line2D:
	var line = Line2D.new()
	line.width = 2
	return line
