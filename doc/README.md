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


func _ready() -> void:

    ## Add child that holds all lines for easy free
    add_child(global_lines)
```

The lines are children of `global_lines`. All children are freed
when I free `global_lines`. After I free, I have to make a new
instance and add it to the scene tree again, so why bother adding
it to the scene tree in `_ready()`? The only reason to add this
to the scene tree in `_ready()` is so that `_process()` has
something to free, kicking off the free-then-create cycle.

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

The lines are drawn to specific screen coordinates. They are not
clipped and they do not reposition or rescale as the window
resizes. Next I address all of that, making the line drawings
act like they are part of the GUI.

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
