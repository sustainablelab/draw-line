extends MarginContainer

# -----------
# | Globals |
# -----------

# =====[ Libraries ]=====

## Utility functions are in `MyUtilities.gd`. To call a utility
## function:
##
##     `myu.function_name()`
onready var myu : Node = preload("res://src/MyUtilities.tscn").instance()

# =====[ Dev ]=====

# ---< Scene Tree >---
onready var Dev:      HBoxContainer = get_node("Dev")
onready var HudLeft:  Label         = get_node("Dev/HudLeft")
onready var HudRight: Label         = get_node("Dev/HudRight")

# =====[ App ]=====

# ---< Plot artwork >---
## **Free** and **remake** plot artwork on every iteration of
## `_process()`.
##
## Add lines (Line2D nodes) as children of Node `global_lines` to
## simplify memory management. Free `global_lines` to free all
## plot lines.
onready var global_lines := Node2D.new() # Parent node to hold all lines

# ---< Scene Tree >---
onready var App:            VBoxContainer   = get_node("App")
onready var PlotArea:       MarginContainer = get_node("App/PlotArea")
onready var PlotArea_bound: ReferenceRect   = get_node("App/PlotArea/PlotArea_bound")
onready var PlotParts:      GridContainer   = get_node("App/PlotArea/PlotParts")
onready var UpLeft_bound:   ReferenceRect   = get_node("App/PlotArea/PlotParts/UpLeft_bound")
onready var Title:          Label           = get_node("App/PlotArea/PlotParts/TitleArea/Title")
onready var Y1Axis_bound:   ReferenceRect   = get_node("App/PlotArea/PlotParts/Y1Axis_bound")
onready var Data:           MarginContainer = get_node("App/PlotArea/PlotParts/Data")
onready var Data_bound:     ReferenceRect   = get_node("App/PlotArea/PlotParts/Data/Data_bound")
onready var XAxis_bound:    ReferenceRect   = get_node("App/PlotArea/PlotParts/XAxis_bound")
onready var Origin_bound:	ReferenceRect   = get_node("App/PlotArea/PlotParts/Origin_bound")
onready var KeyPress:       Label           = get_node("App/KeyPress")


# ---------------
# | Application |
# ---------------

##
## \brief Application Setup
##
func _ready() -> void:
	## Randomize the seed for Godot's random number generator.
	randomize()

	## Say hello.
	myu.log_to_stdout(filename, "Enter scene tree")

	##
	## **Screen Layout**
	##

	## Put a dark background in the Window.
	var bgnd_layer := CanvasLayer.new()
	bgnd_layer.layer = -1
	var bgnd_color := ColorRect.new()
	bgnd_color.anchor_right = ANCHOR_END
	bgnd_color.anchor_bottom = ANCHOR_END
	bgnd_color.color = Color8(0x14,0x14,0x13)
	bgnd_layer.add_child(bgnd_color, true)
	add_child(bgnd_layer, true)

	## The layout shall fill the window and shall auto-resize when
	## the user resizes the window.
	anchor_right = ANCHOR_END
	anchor_bottom = ANCHOR_END

	##
	## **Node Main**
	##

	## `Main` is divided into an `App` layer and a `Dev` overlay layer.

	##
	## **Node App**
	##

	## `App` divides the screen into two rows: `PlotArea` and
	## `KeyPress`.

	##
	## **Show key presses at the bottom of the screen**
	##

	##
	## **Node PlotArea**
	##

	## `PlotArea` expands and fills vertically, pushing `KeyPress`
	## to the screen bottom.
	PlotArea.size_flags_vertical = SIZE_EXPAND_FILL

	## `PlotArea_bound` shows the bounds of `PlotArea`.
	PlotArea_bound.editor_only = false
	PlotArea_bound.border_color = Color8(0xFF, 0x80, 0x80, 0x80)

	##
	## **Node PlotParts**
	##

	## `PlotParts` is a `GridContainer`. Godot determines the
	## number of rows in the `GridContainer` by dividing the
	## number of children in `PlotParts` by `PlotParts.columns`.

	# Rows in GridContainer PlotParts is num children / columns 
	PlotParts.columns = 2

	## - `UpLeft_bound` shows the dead space in the upper-left
	## corner of the plot area.
	##
	## - `Title` is the plot title, above the data.
	##
	## - `Y1Axis_bound` shows the space for the Y-axis to the
	## left of the data.
	##
	## - `Data_bound` shows the space for the plot lines.
	##
	## - `XAxis_bound` shows the space for the X-axis.
	##
	## - `Origin_bound` shows the dead space in the lower-left
	## corner of the plot area.

	##
	## **Node Data**
	##

	## `Data` shall expand horizontally and vertically to claim
	## maximum space for plot artwork.
	Data.size_flags_horizontal = SIZE_EXPAND_FILL
	Data.size_flags_vertical = SIZE_EXPAND_FILL

	## `Data_bound` shows the bounds of `Data`.
	Data_bound.editor_only = false
	Data_bound.border_color = Color8(0x80, 0xFF, 0x80, 0x80)


	## Use Y1Axis_bound to visualize space for the Y1 axis
	Y1Axis_bound.rect_min_size = Vector2(100,0)
	Y1Axis_bound.editor_only = false
	Y1Axis_bound.border_color = Color8(0x40, 0x80, 0xFF, 0x80)

	## Use XAxis_bound to visualize space for the X axis
	XAxis_bound.rect_min_size = Vector2(0,20)
	XAxis_bound.editor_only = false
	XAxis_bound.border_color = Color8(0x40, 0x80, 0xFF, 0x80)
	XAxis_bound.size_flags_horizontal = SIZE_EXPAND_FILL

	## Use Origin_bound to block off dead space under the Y1Axis
	Origin_bound.rect_min_size = Vector2(
		Y1Axis_bound.rect_min_size.x,
		XAxis_bound.rect_min_size.y
		)
	Origin_bound.editor_only = false
	Origin_bound.border_color = Color8(0xFF, 0xFF, 0xFF, 0x80)

	## Use UpLeft_bound to block off dead space under the Y1Axis
	UpLeft_bound.rect_min_size = Vector2(
		Y1Axis_bound.rect_min_size.x,
		Title.rect_size.y
		)
	UpLeft_bound.editor_only = false
	UpLeft_bound.border_color = Color8(0xFF, 0xFF, 0xFF, 0x80)

	Dev.visible = false

	# ---< DEBUG >---
	# Print the final Scene Tree
	print_tree()


##
## \brief Application Loop
##
func _process(_delta) -> void:

	## Write text to HUD text overlay.
	# Write values in HudLeft text overlay
	HudLeft.Main = myu.report_size_and_position(self)
	HudLeft.App = myu.report_size_and_position(App)
	HudLeft.PlotArea = myu.report_size_and_position(PlotArea)
	HudLeft.PlotArea_bound = myu.report_size_and_position(PlotArea_bound)
	HudLeft.PlotParts = myu.report_size_and_position(PlotParts)
	HudLeft.UpLeft_bound = myu.report_size_and_position(UpLeft_bound)
	HudLeft.Title = myu.report_size_and_position(Title)
	HudLeft.Y1Axis_bound = myu.report_size_and_position(Y1Axis_bound)
	HudLeft.Data = myu.report_size_and_position(Data)
	HudLeft.Data_bound = myu.report_size_and_position(Data_bound)
	HudLeft.Origin_bound = myu.report_size_and_position(Origin_bound)
	HudLeft.XAxis_bound  = myu.report_size_and_position(XAxis_bound)
	HudLeft.KeyPress = myu.report_size_and_position(KeyPress)
	HudLeft.HudLeft = myu.report_size_and_position(HudLeft)
	HudLeft.HudRight = myu.report_size_and_position(HudRight)

	HudLeft.text = """{Main}
{App}
{PlotArea}
{PlotArea_bound}
{PlotParts}
{UpLeft_bound}
{Title}
{Y1Axis_bound}
{Data}
{Data_bound}
{Origin_bound}
{XAxis_bound}
{KeyPress}
{HudLeft}
{HudRight}""".format({
		"Main":HudLeft.Main,
		"App":HudLeft.App,
		"PlotArea":HudLeft.PlotArea,
		"PlotArea_bound":HudLeft.PlotArea_bound,
		"PlotParts":HudLeft.PlotParts,
		"UpLeft_bound":HudLeft.UpLeft_bound,
		"Title":HudLeft.Title,
		"Y1Axis_bound":HudLeft.Y1Axis_bound,
		"Data":HudLeft.Data,
		"Data_bound":HudLeft.Data_bound,
		"Origin_bound":HudLeft.Origin_bound,
		"XAxis_bound":HudLeft.XAxis_bound,
		"KeyPress":HudLeft.KeyPress,
		"HudLeft":HudLeft.HudLeft,
		"HudRight":HudLeft.HudRight
		})
	# Write values in HudRight text overlay
	HudRight.GlobalMouse = get_global_mouse_position()
	HudRight.LocalMouse = PlotArea.get_local_mouse_position()

	HudRight.text = "GLOBAL MOUSE: {GlobalMouse}\nLOCAL MOUSE: {LocalMouse}".format({
		"GlobalMouse":HudRight.GlobalMouse,
		"LocalMouse":HudRight.LocalMouse
		})

	## Title the plot.
	Title.text = "PUT PLOT TITLE IN Title.text"

	## Draw lines.

	# Free all lines
	global_lines.free()

	# Create base memory for lines
	global_lines = Node2D.new()
	PlotArea.add_child(global_lines)

	# Make the lines
	var lines : Array = []
	for i in range(2):
		## Make a new line.
		lines.append(new_line())
		global_lines.add_child(lines[i])
		## Randomize its color.
		lines[i].default_color = Color8(
			randi()%0xFF+0x80, # red
			randi()%0x80, # green
			randi()%0xFF+0x80  # blue
			)
		## Randomize the points in the line.
		for _point in range(4):
			lines[i].add_point(Vector2(randi()%242+100,randi()%142+100))


##
## \brief Create a line with default width
##
func new_line() -> Line2D:
	var line = Line2D.new()
	line.width = 5
	return line


# --------------
# | User Input |
# --------------

##
## \brief Handle keyboard input
##
func _input(event) -> void:
	if event is InputEventKey:

		# Key just pressed
		if event.pressed and not event.echo:
			var key : String = OS.get_scancode_string(event.scancode)
			KeyPress.text = key
			if key == "Escape":
				keypress_esc()
			elif key == "F2":
				Dev.visible = not Dev.visible
			elif key == "F3":
				PlotArea_bound.editor_only = not PlotArea_bound.editor_only


		# Key released
		if not event.pressed:
			KeyPress.text = ""

##
## \brief Quit when user presses Esc
##
func keypress_esc() -> void:
	myu.log_to_stdout(filename, "User quit with Esc")
	get_tree().quit()
