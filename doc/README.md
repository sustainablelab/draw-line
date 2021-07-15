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
	myu.log_to_stdout(filename, "Enter scene tree")
```

Why do it this way? There are only two options.

- I cannot attach `MyUtilities.gd` to node `Main`
    - a node can only have one script attached to it
    - `Main` already has `Main.gd` attached
- I cannot "include" `MyUtilities.gd` in `Main.gd`
    - there is no "import" or "include" mechanism
- The other option for splitting up code across files is to make
  a script that defines a new class
- Godot sees the script in my `src` folder and "picks up" the new
  class under the hood
- then I make an instance of the class
- so it's just like making an instance of `MyUtilities.tscn`

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

The lines are drawn to specific screen coordinates. They are not
clipped and they do not reposition or rescale as the window
resizes. Next I address all of that, making the line drawings
act like they are part of the GUI.

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

## Overlay text

Create a `RichTextLabel` node named `HUD` and make it a child of
`Main`. It does not matter if it is before or after `App` in the
Scene Tree.

Experimenting with `RichTextLabel` and `TextEdit`, it seems
`RichTextLabel` overlays without changing the background color
while `TextEdit` lightens my dark background. The `TextEdit`
class is so complicated that I can't figure out which color
affects the background.

# Scrap paper

**Scene Tree** for `plot-gui`:

```scene-tree
Godot Engine v3.2.3.stable.official - https://godotengine.org
OpenGL ES 2.0 Renderer: NVIDIA GeForce GTX 1080/PCIe/SSE2
OpenGL ES 2.0 Batching: ON
 
@LOG(HudHelp.gd): _ready()
@LOG(Clipper.gd): _ready()
@LOG(Figure.gd): _ready()
@LOG(HudDebug.gd): _ready()
@LOG(Main.gd): _ready()
@LOG(MyUtilities.gd): _ready(), run tests? False
 ┖╴Main
    ┠╴Bgnd
    ┃  ┖╴Color
    ┠╴ScreenTop
    ┃  ┠╴HudHelp
    ┃  ┃  ┖╴@@2
    ┃  ┠╴Figure
    ┃  ┃  ┠╴Mouse
    ┃  ┃  ┖╴FigColumns
    ┃  ┃     ┠╴Y1
    ┃  ┃     ┠╴MouseY
    ┃  ┃     ┠╴TickY1Shadow
    ┃  ┃     ┠╴FigMiddle
    ┃  ┃     ┃  ┠╴Title
    ┃  ┃     ┃  ┃  ┖╴@@3
    ┃  ┃     ┃  ┠╴PlotArea
    ┃  ┃     ┃  ┃  ┠╴BobNotClipped
    ┃  ┃     ┃  ┃  ┠╴Y1AxisName
    ┃  ┃     ┃  ┃  ┠╴Y2AxisName
    ┃  ┃     ┃  ┃  ┠╴Clipper
    ┃  ┃     ┃  ┃  ┃  ┠╴BobClipped
    ┃  ┃     ┃  ┃  ┃  ┖╴@@11
    ┃  ┃     ┃  ┃  ┠╴@@9
    ┃  ┃     ┃  ┃  ┖╴@@10
    ┃  ┃     ┃  ┠╴TickXShadow
    ┃  ┃     ┃  ┠╴MouseX
    ┃  ┃     ┃  ┖╴XAxisName
    ┃  ┃     ┖╴Y2
    ┃  ┖╴RightText
    ┃     ┠╴FileNameLabel
    ┃     ┠╴FileName
    ┃     ┠╴FileHeaderLabel
    ┃     ┖╴FileHeader
    ┠╴ScreenBottom
    ┃  ┠╴Messages
    ┃  ┃  ┠╴Status
    ┃  ┃  ┃  ┖╴@@4
    ┃  ┃  ┖╴Cmdline
    ┃  ┃     ┠╴@@5
    ┃  ┃     ┖╴@@7
    ┃  ┃        ┖╴@@6
    ┃  ┖╴KeyPress
    ┠╴HudHelpShadow
    ┠╴HudDebug
    ┃  ┖╴@@8
    ┠╴MyUtilities
    ┖╴@@12
```
