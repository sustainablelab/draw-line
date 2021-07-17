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
## Add lines (Line2D nodes) as children of `_art` Nodes to
## simplify memory management. Free `_art` to free all Line2D
## artwork.
var global_data_art := Node2D.new() # Parent node to hold all data Line2D nodes
var global_grid_art := Node2D.new() # Parent node to hold all grid Line2D nodes
var global_pan_offset := Vector2(0,0) # Plot panning in Axis coordinates
var n_xticks := 10 # TEMP
var n_yticks := 10 # TEMP

# ---< Scene Tree >---
onready var App:          VBoxContainer   = get_node("App")
onready var Plot_area:    MarginContainer = get_node("App/Plot_area")
onready var Plot_bound:   ReferenceRect   = get_node("App/Plot_area/Plot_bound")
onready var PlotParts:    GridContainer   = get_node("App/Plot_area/PlotParts")
onready var UpLeft_area:  MarginContainer = get_node("App/Plot_area/PlotParts/UpLeft_area")
onready var UpLeft_bound: ReferenceRect   = get_node("App/Plot_area/PlotParts/UpLeft_area/UpLeft_bound")
onready var Title_area:   MarginContainer = get_node("App/Plot_area/PlotParts/Title_area")
onready var Title:        Label           = get_node("App/Plot_area/PlotParts/Title_area/Title")
onready var Title_bound:  ReferenceRect   = get_node("App/Plot_area/PlotParts/Title_area/Title_bound")
onready var Y1Axis_area:  MarginContainer = get_node("App/Plot_area/PlotParts/Y1Axis_area")
onready var Y1Axis_bound: ReferenceRect   = get_node("App/Plot_area/PlotParts/Y1Axis_area/Y1Axis_bound")
onready var Y2Axis_area:  MarginContainer = get_node("App/Plot_area/PlotParts/Y2Axis_area")
onready var Y2Axis_bound: ReferenceRect   = get_node("App/Plot_area/PlotParts/Y2Axis_area/Y2Axis_bound")
onready var Data_area:    MarginContainer = get_node("App/Plot_area/PlotParts/Data_area")
onready var Data_bound:   ReferenceRect   = get_node("App/Plot_area/PlotParts/Data_area/Data_bound")
onready var XAxis_area:   MarginContainer = get_node("App/Plot_area/PlotParts/XAxis_area")
onready var XAxis_bound:  ReferenceRect   = get_node("App/Plot_area/PlotParts/XAxis_area/XAxis_bound")
onready var Origin_area:  MarginContainer = get_node("App/Plot_area/PlotParts/Origin_area")
onready var Origin_bound: ReferenceRect   = get_node("App/Plot_area/PlotParts/Origin_area/Origin_bound")
onready var KeyPress:     Label           = get_node("App/KeyPress")


# ---------
# | Setup |
# ---------

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

	## `App` divides the screen into two rows: `Plot_area` and
	## `KeyPress`.

	##
	## **Show key presses at the bottom of the screen**
	##

	##
	## **Node Plot_area**
	##

	## `Plot_area` shall expand and fill vertically. Intent is to
	## push `KeyPress` to the screen bottom.
	Plot_area.size_flags_vertical = SIZE_EXPAND_FILL

	## `Plot_bound` shows the bounds of `Plot_area`.
	Plot_bound.editor_only = false
	Plot_bound.border_color = Color8(0xFF, 0x80, 0x80, 0x80)

	##
	## **Node PlotParts**
	##

	## `PlotParts` is a `GridContainer`. Godot determines the
	## number of rows in the `GridContainer` by dividing the
	## number of children in `PlotParts` by `PlotParts.columns`.

	# Rows in GridContainer PlotParts is num children / columns 
	PlotParts.columns = 3

	##
	## **Children of `PlotParts`**
	##
	## - *UpLeft*: dead space in the upper-left corner of the plot area
	##
	## - *Title*: plot title above the data
	##
	## - *UpRight*: dead space in the upper-right corner of the plot area
	##
	## - *Y1Axis*: the Y-axis to the left of the data
	##
	## - *Data*: draw plot lines here
	##
	## - *Y2Axis*: the Y-axis to the right of the data
	##
	## - *Origin*: dead space in the lower-left corner of the plot area
	##
	## - *XAxis*: the X-axis
	##
	## - *DownRight*: dead space in the lower-right corner of the plot area

	##
	## **Node Data_area**
	##

	## `Data_area` shall expand horizontally and vertically to
	## claim maximum space for plot artwork.
	Data_area.size_flags_horizontal = SIZE_EXPAND_FILL
	Data_area.size_flags_vertical = SIZE_EXPAND_FILL

	## `Data_bound` shows the bounds of `Data_area`.
	Data_bound.editor_only = false
	Data_bound.border_color = Color8(0x80, 0xFF, 0x80, 0x80)

	##
	## **Node Title_area**
	##

	## `Title_bound` shows the bounds of `Title_area`.
	Title_bound.editor_only = false
	Title_bound.border_color = Color8(0x40, 0x80, 0xFF, 0x80)

	##
	## **Node Y1Axis_area**
	##

	## `Y1Axis_area` sets the width of the Y-Axis to the left of the data.
	Y1Axis_area.rect_min_size = Vector2(50,0)

	## `Y1Axis_bound` shows the bounds of `Y1Axis_area`.
	Y1Axis_bound.editor_only = false
	Y1Axis_bound.border_color = Color8(0x40, 0x80, 0xFF, 0x80)

	##
	## **Node Y2Axis_area**
	##

	## `Y2Axis_area` sets the width of the Y-Axis to right of the data.
	Y2Axis_area.rect_min_size = Vector2(50,0)

	## `Y2Axis_bound` shows the bounds of `Y2Axis_area`.
	Y2Axis_bound.editor_only = false
	Y2Axis_bound.border_color = Color8(0x40, 0x80, 0xFF, 0x80)

	##
	## **Node XAxis_area**
	##

	## `XAxis_area` sets the height of the X-Axis.
	XAxis_area.rect_min_size = Vector2(0,20)
	XAxis_area.size_flags_horizontal = SIZE_EXPAND_FILL

	## `XAxis_bound` shows the bounds of the `XAxis_area`.
	XAxis_bound.editor_only = false
	XAxis_bound.border_color = Color8(0x40, 0x80, 0xFF, 0x80)

	##
	## **Node Origin_area**
	##

	## `Origin_area` is required by `PlotParts` for setting the
	## number of rows. `Origin_area` blocks off the dead space
	## under the Y axis and left of the X axis.
	Origin_area.rect_min_size = Vector2(
		Y1Axis_area.rect_min_size.x,
		XAxis_area.rect_min_size.y
		)

	## `Origin_bound` shows the bounds of `Origin_area`.
	Origin_bound.editor_only = false
	Origin_bound.border_color = Color8(0xFF, 0xFF, 0xFF, 0x80)

	##
	## **Node UpLeft_area**
	##

	## `UpLeft_area` is required by `PlotParts` for setting the
	## number of rows. `UpLeft_area` blocks off dead space above
	## the Y axis and left of the plot title.
	UpLeft_area.rect_min_size = Vector2(
		Y1Axis_area.rect_min_size.x,
		Title_area.rect_size.y
		)

	## `UpLeft_bound` shows the bounds of `UpLeft_area`.
	UpLeft_bound.editor_only = false
	UpLeft_bound.border_color = Color8(0xFF, 0xFF, 0xFF, 0x80)

	##
	## **Node Dev**
	##

	## Start with all Developer art (bounding boxes) invisible. F3
	## toggles visibility.
	Dev.visible = false

	# ---< DEBUG >---
	# Print the final Scene Tree
	print_tree()


# --------
# | Draw |
# --------

##
## \brief Application Loop
##
func _process(_delta) -> void:

	## Write text to HUD text overlay.
	HudLeft_write_text()
	HudRight_write_text()

	## Title the plot.
	Title.text = "PUT PLOT TITLE IN Title.text"

	# ---< Draw lines >---

	# Free all lines
	global_data_art.free()
	global_grid_art.free()

	# Create base memory for lines
	global_data_art = Node2D.new()
	global_grid_art = Node2D.new()
	Data_area.add_child(global_data_art)
	Data_area.add_child(global_grid_art)

	## Make the X- and Y-axis **grid line** artwork.
	make_grid_lines()

	## Define the axes:
	## X and Y ranges and an offset into those ranges.
	var axes : Axes = make_axes()

	## Make the X- and Y-axis **tick label** artwork.
	make_grid_labels(axes)

	## Make the data and the data line artwork.
	make_data_lines()


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
			## Esc quits.
			if key == "Escape":
				keypress_esc()
			## F2 toggles HUD text overlay.
			elif key == "F2":
				Dev.visible = not Dev.visible
			## F3 toggles bounding boxes.
			elif key == "F3":
				keypress_F3()

		# Key released
		if not event.pressed:
			KeyPress.text = ""


# ----------------------
# | KeyPress Functions |
# ----------------------

##
## \brief Quit when user presses Esc
##
func keypress_esc() -> void:
	myu.log_to_stdout(filename, "User quit with Esc")
	get_tree().quit()


##
## \brief Toggle bounding boxes when user presses F3
##
func keypress_F3() -> void:
	Plot_bound.editor_only   = not Plot_bound.editor_only
	UpLeft_bound.editor_only = not UpLeft_bound.editor_only
	Title_bound.editor_only  = not Title_bound.editor_only
	Y1Axis_bound.editor_only = not Y1Axis_bound.editor_only
	Data_bound.editor_only   = not Data_bound.editor_only
	XAxis_bound.editor_only  = not XAxis_bound.editor_only
	Origin_bound.editor_only = not Origin_bound.editor_only


# ------------------
# | Draw functions |
# ------------------

##
## \brief Create a line with default width
##
func new_line() -> Line2D:
	var line = Line2D.new()
	line.width = 5
	return line


##
## \brief Create a grid line
##
func new_grid_line() -> Line2D:
	var line = Line2D.new()
	## Make grid lines skinny.
	line.width = 1
	## Make grid lines dark green and transparent.
	line.default_color = Color8(
		0x40, # red
		0x80, # green
		0x40, # blue
		0x80  # alpha
		)
	return line

##
## \brief Label the grid lines
##
## \param axes: The axes for the current "view" of the data.
##
func make_grid_labels(axes : Axes) -> void:
	var x_labels : Array = []
	var y_labels : Array = []
	var axis_size := Vector2( # TEMP
		Data_area.rect_size.x,
		Data_area.rect_size.y
		)
	# x_labels all have the same TOP coordinate
	var xlabel_top : float = axis_size.y + 5 # see ystart
	# y_labels all have the same LEFT coordinate
	var ylabel_left : float = -5 # see xstart
	# tick step (axis value step-size between ticks)
	var xtick_step : float = axes.x.directed_length/(n_xticks-1)
	var xtick_pitch : float = axis_size.x/(n_xticks-1)
	var ytick_step : float = axes.y.directed_length/(n_yticks-1)
	var ytick_pitch : float = axis_size.y/(n_yticks-1)
	# Make X labels
	for i in range(n_xticks):
		# Make a new label
		x_labels.append(Label.new())
		global_grid_art.add_child(x_labels[i])
		# Calculate the value to show in the label
		var xA : float = axes.x.first + i*xtick_step
		# Show ints as ints, show floats with one decimal place
		if xA - int(xA) == 0:
			x_labels[i].text = String(xA).pad_decimals(0)
		else:
			x_labels[i].text = String(xA).pad_decimals(1)
		# Position the label based on its width.
		# Guess the width based on the number of characters and
		# the font height.
		var label_font_height : float = x_labels[i].get_line_height()
		var label_char_count : int = x_labels[i].get_total_character_count()
		var label_half_width : float = label_char_count*label_font_height/4
		var xlabel_left : float = i*xtick_pitch - label_half_width
		x_labels[i].rect_position = Vector2(xlabel_left, xlabel_top)
	for i in range(n_yticks):
		# Make a new label
		y_labels.append(Label.new())
		global_grid_art.add_child(y_labels[i])
		# Calculate the value to show in the label
		var yA : float = axes.y.first + i*ytick_step
		# Show ints as ints, show floats with one decimal place
		if yA - int(yA) == 0:
			y_labels[i].text = String(yA).pad_decimals(0)
		else:
			y_labels[i].text = String(yA).pad_decimals(1)
		var label_font_height : float = y_labels[i].get_line_height()
		var ylabel_top : float = axis_size.y - i*ytick_pitch - label_font_height/2
		var label_char_count : int = y_labels[i].get_total_character_count()
		var label_width : float = label_char_count*label_font_height/2
		y_labels[i].rect_position = Vector2(ylabel_left - label_width, ylabel_top)



##
## \brief Make the grid line artwork
##
func make_grid_lines() -> void:
	var x_divisions : Array = []
	var y_divisions : Array = []
	# Name top-left corner of data area (xO,yO)
	var xO : float = 0 # Data_area.rect_position.x
	var yO : float = 0 # Data_area.rect_position.y
	var axis_size := Vector2( # TEMP
		Data_area.rect_size.x,
		Data_area.rect_size.y
		)
	# tick pitch (screen space between ticks)
	var xtick_pitch : float = axis_size.x/(n_xticks-1)
	var ytick_pitch : float = axis_size.y/(n_yticks-1)
	# X divisions start 5 pixels below `XAxis` and go to top of `Data_area`
	var ystart : float = -5
	var ystop : float = axis_size.y
	# Y divisions start 5 pixels left of `YAxis` and go to right end of `Data_area`
	var xstart : float = -5
	var xstop : float = axis_size.x
	# Make X divisions
	for i in range(n_xticks):
		## Make a new line.
		x_divisions.append(new_grid_line())
		global_grid_art.add_child(x_divisions[i])
		## Draw a line for each tick on the XAxis.
		# Describe x-location of grid line in Grid coordinates
		var xG : float = i*xtick_pitch
		# Draw points in Data_area (pixel) coordinates
		x_divisions[i].add_point(Vector2(xO + xG, (yO - ystart) + axis_size.y))
		x_divisions[i].add_point(Vector2(xO + xG, (yO - ystop)  + axis_size.y))
	# Make Y divisions
	for i in range(n_yticks):
		## Make a new line.
		y_divisions.append(new_grid_line())
		global_grid_art.add_child(y_divisions[i])
		## Draw a line for each tick on the XAxis.
		# Describe y-location of grid line in Grid coordinates
		var yG : float = i*ytick_pitch
		# Draw points in Data_area (pixel) coordinates
		y_divisions[i].add_point(Vector2(xO + xstart, yO + yG))
		y_divisions[i].add_point(Vector2(xO + xstop, yO + yG))

##
## \brief Define X and Y axes
##
## Each Axis has a `first` value and a `directed_length`.
## Axes are an X Axis and a Y Axis together with an (x,y) offset
## into the axes. The offset adds to the `first` value. The
## `directed_length is unchanged, so all values are offset by the
## offset.
##
func make_axes() -> Axes:
	## Make the axes.
	var xAxis := Axis.new()
	var yAxis := Axis.new()
	var axes := Axes.new(xAxis, yAxis, global_pan_offset)
	# TEMP -- shall come from data
	axes.x.first = 99
	axes.x.directed_length = 100
	axes.y.first = 456
	axes.y.directed_length = 400
	return axes

##
## \brief Make the data and the data line artwork
##
func make_data_lines() -> void:
	var lines : Array = []
	for i in range(2):
		## Make a new line.
		lines.append(new_line())
		global_data_art.add_child(lines[i])
		## Randomize its color.
		lines[i].default_color = Color8(
			randi()%0xFF+0x80, # red
			randi()%0x80, # green
			randi()%0xFF+0x80  # blue
			)
		## Randomize the points in the line.
		for _point in range(4):
			lines[i].add_point( Vector2(
				randi()%int(Data_area.rect_size.x),
				randi()%int(Data_area.rect_size.y)
				))


##
## \brief Display mouse coordinates in HudRight
##
func HudRight_write_text() -> void:
	# Updates strings
	HudRight.GlobalMouse = get_global_mouse_position()
	HudRight.LocalMouse = Data_area.get_local_mouse_position()

	# Combine into one string
	HudRight.text = "GLOBAL MOUSE: {GlobalMouse}\nLOCAL MOUSE: {LocalMouse}".format({
		"GlobalMouse":HudRight.GlobalMouse,
		"LocalMouse":HudRight.LocalMouse
		})


##
## \brief Report size and position of Nodes in HudLeft
##
func HudLeft_write_text() -> void:
	# Update strings
	HudLeft.Main = myu.report_size_and_position(self)
	HudLeft.App = myu.report_size_and_position(App)
	HudLeft.Plot_area = myu.report_size_and_position(Plot_area)
	HudLeft.PlotParts = myu.report_size_and_position(PlotParts)
	HudLeft.UpLeft_area = myu.report_size_and_position(UpLeft_area)
	HudLeft.Title_area = myu.report_size_and_position(Title_area)
	HudLeft.Title = myu.report_size_and_position(Title)
	HudLeft.Y1Axis_area = myu.report_size_and_position(Y1Axis_area)
	HudLeft.Y2Axis_area = myu.report_size_and_position(Y2Axis_area)
	HudLeft.Data_area = myu.report_size_and_position(Data_area)
	HudLeft.Origin_area = myu.report_size_and_position(Origin_area)
	HudLeft.XAxis_area  = myu.report_size_and_position(XAxis_area)
	HudLeft.KeyPress = myu.report_size_and_position(KeyPress)
	HudLeft.HudLeft = myu.report_size_and_position(HudLeft)
	HudLeft.HudRight = myu.report_size_and_position(HudRight)

	# Combine into one string
	HudLeft.text = """{Main}
{App}
{Plot_area}
{PlotParts}
{UpLeft_area}
{Title_area}
{Title}
{Y1Axis_area}
{Y2Axis_area}
{Data_area}
{Origin_area}
{XAxis_area}
{KeyPress}
{HudLeft}
{HudRight}""".format({
		"Main":HudLeft.Main,
		"App":HudLeft.App,
		"Plot_area":HudLeft.Plot_area,
		"PlotParts":HudLeft.PlotParts,
		"UpLeft_area":HudLeft.UpLeft_area,
		"Title_area":HudLeft.Title_area,
		"Title":HudLeft.Title,
		"Y1Axis_area":HudLeft.Y1Axis_area,
		"Y2Axis_area":HudLeft.Y2Axis_area,
		"Data_area":HudLeft.Data_area,
		"Origin_area":HudLeft.Origin_area,
		"XAxis_area":HudLeft.XAxis_area,
		"KeyPress":HudLeft.KeyPress,
		"HudLeft":HudLeft.HudLeft,
		"HudRight":HudLeft.HudRight
		})
