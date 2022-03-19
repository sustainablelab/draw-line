## ToC
- [Basic setup for any application](godot.md#basic-setup-for-any-application)
- [Splitting code cross files](godot.md#splitting-code-cross-files)
- [Show me key presses at lower right of screen](godot.md#show-me-key-presses-at-lower-right-of-screen)
- [Draw a line](godot.md#draw-a-line)
- [Draw lots of lines](godot.md#draw-lots-of-lines)
- [Make the lines act like they are part of the GUI](godot.md#make-the-lines-act-like-they-are-part-of-the-gui)
- [Mark the drawing area](godot.md#mark-the-drawing-area)
- [Setup Scene Tree for a text overlay](godot.md#setup-scene-tree-for-a-text-overlay)
- [Use resized signal to find out positions and sizes](godot.md#use-resized-signal-to-find-out-positions-and-sizes)
- [Overlay text](godot.md#overlay-text)
- [Use a Left and Right HUD](godot.md#use-a-left-and-right-hud)

# Goal: draw a line on the screen

## Basic setup for any application

- [x] make project
    - godot-games/draw-line
- [x] make a doc folder ignored by Godot Editor
    - draw-line/doc/.gdignore
- [x] make a root node named `Main`, type `VBoxContainer`
    - draw-line/src/Main.tscn
    - attach a new script to `Main`
    - this script is my "main" script where I put the
      `_process()` loop that draws everything
- [x] tell Godot F5 runs the Main scene

```make-Main-default
Godot Editor
-----------
Project Settings ->
    General (tab) ->
        Application -> Run -> Main Scene

Enter path to Main.tscn:
    res://src/Main.tscn
```

- [x] make a script to put me code in
    - draw-line/src/Main.gd
- [x] make another scene and script to put Utility code in
    - make scene `MyUtilties`
    - give it a dummy root node named `MyUtilities`
    - attach a new script to `MyUtilities`
        - this script holds my utilities functions

```split-code-between-scripts
▾ src/
    Main.gd
    Main.tscn
    MyUtilities.gd      <--- UTILITY SCRIPT
    MyUtilities.tscn    <--- ATTACH UTILITY SCRIPT TO ROOT NODE
```

In the calling code:

```load-scene-instance-to-use-script-as-a-lib
# In Main.gd

# Create an instance of the utilities scene
onready var myu : Node = preload("res://src/MyUtilities.tscn").instance()

# Example using a function defined in MyUtilities.gd
func _ready():
	add_child(myu, true)
	myu.log_to_stdout(filename, "Enter scene tree")
```

The reason to `add_child()` is memory management. If I make it a
child of another node, I avoid the memory leak error message when
quitting the application.

`myu` is a Node. If I do not add it to the Scene Tree, it is an
**orphaned node**. Godot does not automatically make it a child
of the root node. Godot does not automatically make it a child of
the node the caller script is attached to. Godot does not
automatically add nodes to the Scene Tree. I have to do that with
`add_child`.

I only add this node once, so it's not a big deal that it is
orphaned. And Godot runs just fine until the application exits.
When I exit, I call `get_tree().quit()`, and this frees all the
nodes on the tree. But `myu` is an **orphaned node**, and
therefore it is not freed. It is a memory leak. At this point
Godot realizes the node is orphaned and I get the error. The
error is invisible unless someone is reading the messages printed
to stderr (the terminal where Godot was launched from).

## Splitting code cross files

Why put my utility functions in a scene?

- I cannot attach `MyUtilities.gd` to node `Main`
    - a node can only have one script attached to it
    - `Main` already has `Main.gd` attached
- I cannot "include" `MyUtilities.gd` in `Main.gd`
    - there is no "import" or "include" mechanism

The only other option I'm aware of for splitting code across
files is to use another script to create a class.

- the script begins with `class_name`
- Godot sees the script in my `src` folder and "picks up" the new
  class under the hood
- then I make an instance of the class
- so it's just like making an instance of `MyUtilities.tscn`

The annoying thing about creating a class in this way is that the
script cannot reference itself. For example, I want to make a
struct, so I create a class script and put variables in it:

```GDScript
# Axis.gd
class_name Axis

var first : float
var directed_length : float

func _init(_first : float, _directed_length : float) -> void:
	first = _first
	directed_length = _directed_length
```

Instances of class `Axis` are references, so if I copy one axis
to another by assignment, I'm effectively copying the pointer to
the struct and incrementing Godot's reference counter for the
chunk of memory that holds the struct members. I am not
allocating a new chunk of memory that gets the struct member
values copied into it.

So it seems reasonable I'd want to make a `copy_from()` function
that copies values from another `Axis` instance into this
instance. And it seems reasonable I'd want that `copy_from()`
function to be a method of the `Axis` class:

```GDScript
# Axis.gd -- WRONG

func copy_from(axis : Axis) -> void:
	first = axis.first
	directed_length = axis.directed_length
```

This is likely to change in Godot v4.0, but for now, the script
that defines the `Axis` class cannot reference the `Axis` class.
Doing so results in lots of memory leak error messages.

## Show me key presses at lower right of screen

Main is a `VBoxContainer` because I like to see my key presses in
the lower-right corner of the screen. Here is the setup.

- [x] create a scene named `KeyPress.tscn` and instance it as a
  child of `Main`
    - make the root node of the KeyPress scene type `Label`
    - [x] attach script KeyPress.gd to KeyPress

```GDScript
# KeyPress.gd

extends Label


onready var myu : Node = preload("res://src/MyUtilities.tscn").instance()


func _ready():
	align = Label.ALIGN_RIGHT
	valign = Label.VALIGN_BOTTOM
	grow_horizontal = GROW_DIRECTION_BEGIN
	grow_vertical = GROW_DIRECTION_BEGIN
	size_flags_horizontal = SIZE_SHRINK_END
	size_flags_vertical = SIZE_SHRINK_END
	myu.log_to_stdout(filename,"Enter scene tree")
```

This pushes the Label to the lower right corner of the
application window and auto-adjusts as the window size is
changed. Actually, it does nothing at the moment. We need two
things to let the resizing behavior take effect.

### Size flags and anchors

First, we need something in the VBox above with size flags that
tell it to fill the rest of the window. Use `ReferenceRect` for
GUI placeholders.

- [x] add child `ReferenceRect` and name it `Placeholder`

```GDScript
# Main.gd


onready var KeyPress = get_node("KeyPress")
onready var Placeholder = get_node("Placeholder")


func _ready() -> void:

    ## Use Placeholder to push KeyPress to screen bottom
    Placeholder.editor_only = false
    Placeholder.size_flags_vertical = SIZE_EXPAND_FILL
```

`editor_only=false` makes the placeholder visible in the
application.

Second, the `Main` node needs its right and bottom anchors set to
the ends of the window:

```GDScript
# Main.gd


func _ready() -> void:

    ## Make GUI elements fill the window
    anchor_right = ANCHOR_END
    anchor_bottom = ANCHOR_END
```

At this point, the `KeyPress` text sticks to the bottom right
of the window as the window is resized and the placeholder fills
all the remaining space.

### Scene Tree so far

The Scene Tree is

```scene-tree
.
Placeholder
KeyPress
```

Finally, I set a dark black background color:

```GDScript
# Main.gd


func _ready() -> void:

	## Dark black background
	var bgnd_layer := CanvasLayer.new()
	bgnd_layer.layer = -1
	var bgnd_color := ColorRect.new()
	bgnd_color.anchor_right = ANCHOR_END
	bgnd_color.anchor_bottom = ANCHOR_END
	bgnd_color.color = Color8(0x14,0x14,0x13)
	bgnd_layer.add_child(bgnd_color, true)
	add_child(bgnd_layer, true)
```

The Scene Tree looks the same in the editor, but now
`print_tree()` yields this:

```print-tree
.
Placeholder
KeyPress
CanvasLayer
CanvasLayer/ColorRect
```

## Draw a line

For now, use a global `Line2D` and configure it in `_ready()`:

```GDScript
# Main.gd

var line : Line2D

func _ready() -> void:

    ## Testing I can draw a line
    line = Line2D.new()
    line.default_color = Color8(0x80,0x80,0xCC)
    line.width = 1
    add_child(line, true)


func _process(_delta) -> void:
    ## Clear old points
    line.points = PoolVector2Array()
    line.add_point(Vector2(100,100))
    line.add_point(Vector2(200,200))
```

That is the basic idea, but it's missing details about memory
management.

## Draw lots of lines

The previous method doesn't scale up. One global for each line?
How do I know ahead of time how many lines I need?

Instead, on *every iteration* of the `_process()` loop, I free
the existing lines and make new lines.

Make a global parent node for all lines. Add it to the Scene
Tree.

```GDScript
# Main.gd

onready var global_lines := Node2D.new() # Parent node to hold all lines
```

The lines are children of `global_lines`. All children are freed
when I free `global_lines`. After I free, I have to make a new
instance and add it to the scene tree again, so why bother
initialzing it? Every iteration of the `_process()` loop does a
free-then-create, so `_process()` needs something to free the
first time round.

Free lines and create new lines in `_process()`:

```GDScript
# Main.gd

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
    # Blue line
	line1.add_point(Vector2(randi()%100+100,randi()%100+100))
	line1.add_point(Vector2(randi()%100+200,randi()%100+200))
    # Purple line
	line2.add_point(Vector2(randi()%100+100,randi()%100+100))
	line2.add_point(Vector2(randi()%100+200,randi()%100+200))
```

The code above draws a pair of blue and purple dancing lines.

To show this approach scales up, make the number of lines and the
number of points variable:

```GDScript
# Main.gd

## Testing I can draw lines
func _process(_delta) -> void:

	## Free all lines
	global_lines.free()

	## Make new lines
	global_lines = Node2D.new()
	add_child(global_lines)

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
			lines[i].add_point(Vector2(randi()%142+100,randi()%42+100))


func new_line() -> Line2D:
	var line = Line2D.new()
	line.width = 1
	return line
```

## Make the lines act like they are part of the GUI

The lines are drawn to specific screen coordinates. They are not
clipped, they do not reposition, they do not rescale as the
window resizes, and I cannot interact with them, zooming and
panning with the mouse. Next I address all of that, making the
line drawings act like they are part of the GUI.

First, I need to add development tools to the application to get
away from printing to stdout.

## Mark the drawing area

First, I want to temporarily mark off the drawing area as a
drawing area. I call it `PlotArea`. I don't know which container
type to use yet, for now I use `MarginContainer`.

```print_tree
.
PlotArea
PlotArea/Placeholder
KeyPress
CanvasLayer
CanvasLayer/ColorRect
```

And with this new Node, the code shows my intent a little better:

```GDScript
# Main.gd


onready var Placeholder = get_node("PlotArea/Placeholder")
onready var PlotArea = get_node("PlotArea")

func _ready() -> void:

    ## Use PlotArea to push KeyPress to screen bottom
    PlotArea.size_flags_vertical = SIZE_EXPAND_FILL

    ## Use Placeholder to visualize PlotArea
    Placeholder.editor_only = false
```

There's no obvious changes. Though now, if I wanted to, I can
erase the `Placeholder` node and my `KeyPress` is still where I
want it on screen. `Placeholder` is just showing me the extents
of the drawing area; `PlotArea` is what defines the actual
drawing area.

Of course, my lines have no way of knowing I only want them in
the drawing area. Making `global_lines` a child of `PlotArea`
will at least take care of translating the lines, but whether
`global_lines` is a child of `PlotArea` or a child of `Main`
makes no difference at the moment because `PlotArea` and `Main`
have the same (0,0) origin in global coordinates.

To make line drawings act like they are part of the GUI, I need
to distinguish between *data space* and *pixel space*. I create
lines in data space and I draw them in pixel space. This is a
coordinate transform.

The easiest way to explore this coordinate transform is to put
the mouse coordinates in a HUD, displaying the coordinates at
each step of the transform.

I want to create a HUD to display mouse coordinates. First, I
need to rethink the Scene Tree for adding the HUD.

## Setup Scene Tree for a text overlay

TLDR: Make a MarginContainer node above the VBoxContainer.

The HUD is a transparent overlay of text information.

To make it *overlay* the screen, change the `Main` node to a
`MarginContainer`, create a child-node named `App`. Make `App`
the `VBoxContainer`. Move the existing nodes into `App`:

```print_tree
.   <-------------- Main is now a MarginContainer
App      <--------- App is the new VBoxContainer
App/PlotArea      <--------- Make this a child of App
App/PlotArea/Placeholder <-- Make this a child of App
App/KeyPress      <--------- Make this a child of App
CanvasLayer
CanvasLayer/ColorRect
```

Crucially, the new `VBoxContainer` does not need a script or any
manual changes in the Godot Inspector.

Most previous work stay the same:

- Remember the `CanvasLayer` that sets the background color? This
  node type is not affected by containers, so it is OK to
  continue as-is: `Main.gd` still makes `CanvasLayer` and
  `CanvasLayer/ColorRect` children of `Main`.
- Remember it is critical for `Main` to have its `anchor_right =
  ANCHOR_END` and `anchor_bottom = ANCHOR_END` so that the
  `VBoxContainer` fills the window and resizes when the window
  resizes? This is still true. `Main` is a `MarginContainer` now,
  but it still has the responsibility of setting anchors to fill
  the window.


```GDScript
# Main.gd

onready var App:         VBoxContainer   = get_node("App")
onready var PlotArea:    MarginContainer = get_node("App/PlotArea")
onready var Placeholder: ReferenceRect   = get_node("App/PlotArea/Placeholder")
onready var KeyPress:    Label           = get_node("App/KeyPress")
```

And here is the `_ready()`, just to show that everything else
really did stay the same:

```GDScript
# Main.gd

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
```

If I attempt to add text *without* making this change to the
Scene Tree, the text does not overlay and instead the container
puts it in a "horizontal box" on the screen.

The results of this depend on the class of the text node. The
container does not autosize space for the `RichTextLabel` class,
so the result is a thin gap shows up but no text is visible. The
`TextEdit` class is the opposite -- it occupies all the available
space.

So whichever text class I pick, the HUD text CANNOT be a child of
the VBoxContainer.

## Use resized signal to find out positions and sizes

Before I add the text overlay, I set up for reporting position
and size of all the nodes that occupy a place on the screen.
Checking size and position is another way to troubleshoot layout
mysteries. 

The container nodes resize and reposition their contents.
So checking size in the `_ready()` callback is useless. The only
way to know the actual size is to report it after a `resized`
signal is emitted.

This signal is emitted when the application starts, even if I
don't resize the window with my mouse, because Godot has to
resize the window when the application starts.

The initial ridiculous zero-width and zero-height sizes are
changed by the containers, and the signal `resized` is emitted by
each affected node.

The setup is simple. Since `resized` is a built-in signal, I
don't need to add it to any of the nodes, they are already
emitting this signal. I just need to connect it to a function in
`Main.gd` that prints the size and position to stdout.

```GDScript
# Main.gd

func _ready() -> void:

	# ---< DEBUG >---
	# Print the final Scene Tree
	print_tree()
	# Report new sizes and positions AFTER containers do their work
	var _ret # throwaway value returned by connect()
	_ret = connect("resized", self, "_on_resized")
	_ret = App.connect("resized",         self, "_on_App_resized")
	_ret = PlotArea.connect("resized",    self, "_on_PlotArea_resized")
	_ret = Placeholder.connect("resized", self, "_on_Placeholder_resized")
	_ret = KeyPress.connect("resized",    self, "_on_KeyPress_resized")


func _on_resized():
	myu.report_size_and_position(self)
func _on_App_resized():
	myu.report_size_and_position(App)
func _on_PlotArea_resized():
	myu.report_size_and_position(PlotArea)
func _on_Placeholder_resized():
	myu.report_size_and_position(Placeholder)
func _on_KeyPress_resized():
	myu.report_size_and_position(KeyPress)
```

Here is the utility function to print the size and position
message:

```GDScript
# MyUtilities.gd

## \brief Print the size and position of a Control Node to stdout
##
## Example: "@LOG(res://src/Main.tscn): Main size:(800, 300) position: (0, 0)"
##
## \param control: The Control node to report on.
func report_size_and_position(control : Control) -> void:

	## Get the name of this control node
	var path = NodePath(control.get_path())
	var name : String = path.get_name(path.get_name_count()-1)

	## Get the global size and position of this control node
	var rect = control.get_global_rect()

	### Report its size and position
	var size: String
	var pos:  String
	var msg:  String

	size = String(rect.size)
	pos = String(rect.position)
	msg = "{n} size:{s} position: {p}".format({"n":name,"s":size,"p":pos})
	log_to_stdout(filename, msg)
```

## Overlay text

Create a `Label` node named `HUD` and make it a child of
`Main`. It does not matter if it is before or after `App` in the
Scene Tree.

Experimenting with `Label`, `RichTextLabel`, and `TextEdit`, it
seems `Label` and `RichTextLabel` overlay without changing the
background color while `TextEdit` lightens my dark background.
The `TextEdit` class is so complicated that I can't figure out
which color affects the background.

By default, `Label` centers vertically and starts at the left
edge of the screen. I want my overlay text centered at the top of
the screen. Fix this with a script attached to `HUD`:

```GDScript
# HUD.gd

func _ready():
    valign = Label.VALIGN_TOP
    size_flags_horizontal = Label.SIZE_SHRINK_CENTER
    size_flags_vertical = Label.SIZE_EXPAND
```

There are automated ways to set up monitoring values in the text
overlay. See:

    https://kidscancode.org/godot_recipes/ui/debug_overlay/

For now I am keeping it simple, manually adding
information and doing basic formatting for a clean presentation.

I make a `String` variable for each Node I want to monitor. I
put these in the `HUD.gd` script to make the variable naming
straight-forward and obvious.

## Use a Left and Right HUD

I already know I want to monitor Nodes and I want to monitor the
mouse coordinates in different coordinate spaces. For now, I'll
set it up as a HudLeft and HudRight. Make an `HBoxContainer`
named `Dev` a child node of `Main` and make the `HudLeft` and
`HudRight` labels child nodes of `Dev`.

```GDScript
# Main.gd

# ---< DEVELOPER >---
onready var HudLeft: Label = get_node("Dev/HudLeft")
onready var HudRight: Label = get_node("Dev/HudRight")
```

And I make string variables for the strings in each HUD.

Node info in the left HUD:

```GDScript
# HudLeft.gd

extends Label


var Main:        String
var App:         String
var PlotArea:    String
var Placeholder: String
var KeyPress:    String
var Hud:         String


func _ready():
    valign = Label.VALIGN_TOP
    size_flags_horizontal = Label.SIZE_SHRINK_CENTER
    size_flags_vertical = Label.SIZE_EXPAND
```

Coordinate info in the right HUD:

```GDScript
# HudRight.gd

extends Label


var Mouse : String

func _ready():
    valign = Label.VALIGN_TOP
    size_flags_horizontal = Label.SIZE_SHRINK_CENTER
    size_flags_vertical = Label.SIZE_EXPAND
```

There is no longer any reason to use the `resized` signals. The
signal was useful before because I only wanted to print to stdout
when something changed. Now I have the text updating live in the
HUD, so I simply grab these values and update the text every
frame, whether the values changed or not.

```GDScript
# Main.gd

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
```

The above code block eliminates all the signal connections to
`resized` and all of the `_on_resized()` calls.

I also change the `report_size_and_position()` utility function
to return a `String` instead of printing to stdout. And now that
the text is on the screen, I format the strings to form a sort of
table. It's a simple automation that pads spaces between the
variable strings, as long as none of the strings exceed 12
characters.

```GDScript
# MyUtilities.gd

## \brief Report the size and position of a Control Node
##
## Example: "NODE: Main    SIZE: (800, 300)    POSITION: (0, 0)"
##
## \param control: The Control node to report on.
##
## \return String for display in the HUD text overlay
func report_size_and_position(control : Control) -> String:

	## Get the name of this control node
	var path = NodePath(control.get_path())
	var name : String = path.get_name(path.get_name_count()-1)

	## Get the global size and position of this control node
	var rect = control.get_global_rect()

	### Report its size and position
	var size: String
	var pos:  String
	var msg:  String

	size = String(rect.size)
	pos = String(rect.position)
	msg = "NODE: {n}{gap1}SIZE: {s}{gap2}POSITION: {p}{gap3}".format({
		"n":name,
		"gap1":" ".repeat(13 - name.length()),
		"s":size,
		"gap2":" ".repeat(13 - size.length()),
		"p":pos,
		"gap3":" ".repeat(13 - pos.length())
		})
	return msg
```


# Scrap paper

Latest scene tree:

```print-tree-pretty
 ┖╴Main
    ┠╴App
    ┃  ┠╴Plot_area
    ┃  ┃  ┠╴Plot_bound
    ┃  ┃  ┖╴PlotParts
    ┃  ┃     ┠╴UpLeft_area
    ┃  ┃     ┃  ┖╴UpLeft_bound
    ┃  ┃     ┠╴Title_area
    ┃  ┃     ┃  ┠╴Title
    ┃  ┃     ┃  ┖╴Title_bound
    ┃  ┃     ┠╴UpRight_area
    ┃  ┃     ┃  ┖╴UpRight_bound
    ┃  ┃     ┠╴Y1Axis_area
    ┃  ┃     ┃  ┖╴Y1Axis_bound
    ┃  ┃     ┠╴Data_area
    ┃  ┃     ┃  ┖╴Data_bound
    ┃  ┃     ┠╴Y2Axis_area
    ┃  ┃     ┃  ┖╴Y2Axis_bound
    ┃  ┃     ┠╴Origin_area
    ┃  ┃     ┃  ┖╴Origin_bound
    ┃  ┃     ┠╴XAxis_area
    ┃  ┃     ┃  ┖╴XAxis_bound
    ┃  ┃     ┖╴DownRight_area
    ┃  ┃        ┖╴DownRight_bound
    ┃  ┖╴KeyPress
    ┃     ┖╴MyUtilities
    ┠╴Dev
    ┃  ┠╴HudLeft
    ┃  ┖╴HudRight
    ┠╴MyUtilities
    ┖╴CanvasLayer
       ┖╴ColorRect

