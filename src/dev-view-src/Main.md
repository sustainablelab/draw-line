# File Summary

   type |  GDScript file  |   LOC  | details
------- | --------------- | ------ | -------
  class |         Axes.gd |     12 | defines `class_name Axes`
  class |         Axis.gd |      6 | defines `class_name Axis`
 script |         Main.gd |    251 | extends MarginContainer <--- THIS IS THE MAIN SCRIPT
 script |  MyUtilities.gd |     24 | extends Node
 script |      HudLeft.gd |     20 | extends Label
 script |     KeyPress.gd |     10 | extends Label
 script |     HudRight.gd |      7 | extends Label


## Summary

    Main.gd: 251 lines

Read Main.gd by starting at the `_ready()` callback on line
65.

All drawing happens in the `_process()` callback on line
242.

## Table of Contents

- [4 : Globals](Main.md#globals)
- [59 : Setup](Main.md#setup)
- [236 : Draw](Main.md#draw)
- [278 : User Input](Main.md#user-input)
- [307 : KeyPress Functions](Main.md#keypress-functions)
- [332 : Draw functions](Main.md#draw-functions)

## Globals
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
    App/Plot_area/PlotParts/Data_area
    App/Plot_area/PlotParts/Data_area/Data_bound
    App/Plot_area/PlotParts/XAxis_area
    App/Plot_area/PlotParts/XAxis_area/XAxis_bound
    App/Plot_area/PlotParts/Origin_area
    App/Plot_area/PlotParts/Origin_area/Origin_bound
    App/KeyPress
## Setup

\brief Application Setup

    65 : func _ready() -> void:
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

- *Y1Axis*: the Y-axis to the left of the data

- *Data*: draw plot lines here

- *Origin*: dead space in the lower-left corner of the plot area

- *XAxis*: the X-axis

**Node Data_area**

`Data_area` shall expand horizontally and vertically to
claim maximum space for plot artwork.
`Data_bound` shows the bounds of `Data_area`.

**Node Title_area**

`Title_bound` shows the bounds of `Title_area`.

**Node Y1Axis_area**

`Y1Axis_area` sets the width of the Y-Axis.
`Y1Axis_bound` shows the bounds of `Y1Axis_area`.

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

Start with all Developer art (bounding boxes) invisible. F3
toggles visibility.
## Draw

\brief Application Loop

    242 : func _process(_delta) -> void:
Write text to HUD text overlay.
Title the plot.
Make the X- and Y-axis **grid line** artwork.
Define the axes:
X and Y ranges and an offset into those ranges.
Make the X- and Y-axis **tick label** artwork.
Make the data and the data line artwork.
## User Input

\brief Handle keyboard input

    284 : func _input(event) -> void:
Esc quits.
F2 toggles HUD text overlay.
F3 toggles bounding boxes.
## KeyPress Functions

\brief Quit when user presses Esc

    313 : func keypress_esc() -> void:

\brief Toggle bounding boxes when user presses F3

    321 : func keypress_F3() -> void:
## Draw functions

\brief Create a line with default width

    338 : func new_line() -> Line2D:

\brief Create a grid line

    347 : func new_grid_line() -> Line2D:
Make grid lines skinny.
Make grid lines dark green and transparent.

\brief Label the grid lines

\param axes: The axes for the current "view" of the data.

    365 : func make_grid_labels(axes : Axes) -> void:

\brief Make the grid line artwork

    407 : func make_grid_lines() -> void:
Make a new line.
Draw a line for each tick on the XAxis.
Make a new line.
Draw a line for each tick on the XAxis.

\brief Define X and Y axes

Each Axis has a `first` value and a `directed_length`.
Axes are an X Axis and a Y Axis together with an (x,y) offset
into the axes. The offset adds to the `first` value. The
`directed_length is unchanged, so all values are offset by the
offset.

    458 : func make_axes() -> Axes:
Make the axes.

\brief Make the data and the data line artwork

    473 : func make_data_lines() -> void:
Make a new line.
Randomize its color.
Randomize the points in the line.

\brief Display mouse coordinates in HudRight

    496 : func HudRight_write_text() -> void:

\brief Report size and position of Nodes in HudLeft

    511 : func HudLeft_write_text() -> void:

bob
