# File Summary

   type |  GDScript file  |   LOC  | global | details
------- | --------------- | ------ | ------ | -------
  class |         Axes.gd |      8 |      3 | defines `class_name Axes`
  class |         Axis.gd |      6 |      2 | defines `class_name Axis`
 script |         Main.gd |    344 |      5 | extends MarginContainer <--- THIS IS THE MAIN SCRIPT
 script |  MyUtilities.gd |     31 |      0 | extends Node
 script |      HudLeft.gd |     20 |     15 | extends Label
 script |     KeyPress.gd |     11 |      0 | extends Label
 script |     HudRight.gd |      9 |      4 | extends Label


## Summary

    Main.gd: 344 lines

Read Main.gd by starting at the `_ready()` callback on line
67.

All drawing happens in the `_process()` callback on line
267.

## Table of Contents

- [4 : Globals](Main.md#globals)
- [61 : Setup](Main.md#setup)
- [261 : Draw](Main.md#draw)
- [354 : User Input](Main.md#user-input)
- [386 : KeyPress Functions](Main.md#keypress-functions)
- [412 : Draw functions](Main.md#draw-functions)

## Globals

Global variables:

```
var global_data_art := Node2D.new() # Parent node to hold all data Line2D nodes
var global_grid_art := Node2D.new() # Parent node to hold all grid Line2D nodes
var global_pan_offset := Vector2(0,0) # Plot panning in Axis coordinates
var n_xticks := 10 # TEMP
var n_yticks := 10 # TEMP
```

*Scene tree node* global variables:

```
onready var myu : Node = preload("res://src/MyUtilities.tscn").instance()
onready var Dev:      HBoxContainer = get_node("Dev")
onready var HudLeft:  Label         = get_node("Dev/HudLeft")
onready var HudRight: Label         = get_node("Dev/HudRight")
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
```

### Libraries
Utility functions are in `MyUtilities.gd`. To call a utility
function:

`myu.function_name()`
### Dev
#### Scene Tree
    Dev
    Dev/HudLeft
    Dev/HudRight
### App
#### Plot artwork
**Free** and **remake** plot artwork on every iteration of
`_process()`.

Add lines (Line2D nodes) as children of `_art` Nodes to
simplify memory management. Free `_art` to free all Line2D
artwork.
#### Scene Tree
    App
    App/Plot_area
    App/Plot_area/Plot_bound
    App/Plot_area/PlotParts
    App/Plot_area/PlotParts/UpLeft_area
    App/Plot_area/PlotParts/UpLeft_area/UpLeft_bound
    App/Plot_area/PlotParts/Title_area
    App/Plot_area/PlotParts/Title_area/Title
    App/Plot_area/PlotParts/Title_area/Title_bound
    App/Plot_area/PlotParts/Y1Axis_area
    App/Plot_area/PlotParts/Y1Axis_area/Y1Axis_bound
    App/Plot_area/PlotParts/Y2Axis_area
    App/Plot_area/PlotParts/Y2Axis_area/Y2Axis_bound
    App/Plot_area/PlotParts/Data_area
    App/Plot_area/PlotParts/Data_area/Data_bound
    App/Plot_area/PlotParts/XAxis_area
    App/Plot_area/PlotParts/XAxis_area/XAxis_bound
    App/Plot_area/PlotParts/Origin_area
    App/Plot_area/PlotParts/Origin_area/Origin_bound
    App/KeyPress
## Setup

> **Application Setup**
>

    67 : func _ready() -> void:

Randomize the seed for Godot's random number generator.
Say hello.

**Screen Layout**

Put a dark background in the Window.
The layout shall fill the window and shall auto-resize when
the user resizes the window.

**Node Main**

`Main` is divided into an `App` layer and a `Dev` overlay layer.

**Node App**

`App` divides the screen into two rows: `Plot_area` and
`KeyPress`.

**Show key presses at the bottom of the screen**


**Node Plot_area**

`Plot_area` shall expand and fill vertically. Intent is to
push `KeyPress` to the screen bottom.
`Plot_bound` shows the bounds of `Plot_area`.

**Node PlotParts**

`PlotParts` is a `GridContainer`. Godot determines the
number of rows in the `GridContainer` by dividing the
number of children in `PlotParts` by `PlotParts.columns`.

**Children of `PlotParts`**

- *UpLeft*: dead space in the upper-left corner of the plot area

- *Title*: plot title above the data

- *UpRight*: dead space in the upper-right corner of the plot area

- *Y1Axis*: the Y-axis to the left of the data

- *Data*: draw plot lines here

- *Y2Axis*: the Y-axis to the right of the data

- *Origin*: dead space in the lower-left corner of the plot area

- *XAxis*: the X-axis

- *DownRight*: dead space in the lower-right corner of the plot area

**Node Data_area**

`Data_area` shall expand horizontally and vertically to
claim maximum space for plot artwork.
`Data_bound` shows the bounds of `Data_area`.

**Node Title_area**

`Title_bound` shows the bounds of `Title_area`.

**Node Y1Axis_area**

`Y1Axis_area` sets the width of the Y-Axis to the left of the data.
`Y1Axis_bound` shows the bounds of `Y1Axis_area`.

**Node Y2Axis_area**

`Y2Axis_area` sets the width of the Y-Axis to right of the data.
`Y2Axis_bound` shows the bounds of `Y2Axis_area`.

**Node XAxis_area**

`XAxis_area` sets the height of the X-Axis.
`XAxis_bound` shows the bounds of the `XAxis_area`.

**Node Origin_area**

`Origin_area` is required by `PlotParts` for setting the
number of rows. `Origin_area` blocks off the dead space
under the Y axis and left of the X axis.
`Origin_bound` shows the bounds of `Origin_area`.

**Node UpLeft_area**

`UpLeft_area` is required by `PlotParts` for setting the
number of rows. `UpLeft_area` blocks off dead space above
the Y axis and left of the plot title.
`UpLeft_bound` shows the bounds of `UpLeft_area`.

**Node Dev**

## Draw

> **Application Loop**
>

    267 : func _process(_delta) -> void:


**Draw plot artwork**

Title the plot.
Free all old plot artwork by freeing the scene tree nodes.
Allocate scene tree nodes for new plot artwork.
Make the X- and Y-axis **grid line** artwork.
Define the axes:
Axes are X and Y ranges
and the x,y offset into those ranges.
Make the data and the data line artwork.
Make the X- and Y-axis **tick label** artwork.
Write text to HUD text overlay.

> **Find the linear transformation matrix from screen to data**
>
> *Given a pixel in the plot, transform it to the data value*
> *implied by the plot axes.*
>
> *\param axes: The current X and Y axes on the screen.*
> *\param rect_size: The size of the area where data is plotted.*
>
> *\return Transform2D matrix*
>

    338 : func transform_screen_to_data(axes : Axes, rect_size : Vector2) -> Transform2D:

## User Input

> **Handle keyboard input**
>

    360 : func _input(event) -> void:

Esc quits.
F1 toggles bounding boxes.
F2 toggles HudLeft text overlay.
F3 toggles HudRight text overlay.
## KeyPress Functions

> **Quit when user presses Esc**
>

    392 : func keypress_esc() -> void:


> **Toggle bounding boxes when user presses F1**
>

    400 : func keypress_F1() -> void:

## Draw functions

> **Create a line with default width**
>

    418 : func new_line() -> Line2D:


> **Create a grid line**
>

    432 : func new_grid_line() -> Line2D:

Make grid lines skinny.
Make grid lines dark green and transparent.

> **Label the grid lines**
>
> *\param axes: The axes for the current "view" of the data.*
>

    451 : func make_grid_labels(axes : Axes) -> void:


> **Make the grid line artwork**
>

    508 : func make_grid_lines() -> void:

Make a new line.
Draw a line for each tick on the XAxis.
Make a new line.
Draw a line for each tick on the XAxis.

> **Define X and Y axes**
>
> *Each Axis has a `first` value and a `directed_length`.*
> *Axes are an X Axis and a Y Axis together with an (x,y) offset*
> *into the axes. The offset adds to the `first` value. The*
> *`directed_length is unchanged, so all values are offset by the*
> *offset.*
>

    560 : func make_axes() -> Axes:

Make the axes.

> **Make the data and the data line artwork**
>
> *This is for testing the interface without any data.*
>

    580 : func make_dancing_lines() -> void:

Make a new line.
Randomize its color.
Randomize the points in the line.

> **Make fake data**
>
> *This is for testing the interface with made up data.*
>

    605 : func fake_data() -> PoolVector2Array:


    618 : func data_nearest_to_mouse(data_mouse : Vector2, data : PoolVector2Array) -> Vector2:


> **Display mouse coordinates in HudRight**
>

    635 : func HudRight_write_text(xfmToData : Transform2D, data : PoolVector2Array) -> void:


> **Report size and position of Nodes in HudLeft**
>

    667 : func HudLeft_write_text() -> void:


bob
