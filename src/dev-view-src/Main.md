# File Summary

   type |  GDScript file  | nlines | details
------- | --------------- | ------ | -------
 script |         Main.gd |    323 | extends MarginContainer <--- THIS IS THE MAIN SCRIPT
 script |  MyUtilities.gd |     52 | extends Node
 script |      HudLeft.gd |     25 | extends Label
 script |     KeyPress.gd |     15 | extends Label
 script |     HudRight.gd |     10 | extends Label


## Summary

    Main.gd: 323 lines

Read Main.gd by starting at the `_ready()` callback on line
58.

All drawing happens in the `_process()` callback on line
197.

## Table of Contents

- [4 : Globals](Main.md#globals)
- [52 : Application](Main.md#application)
- [293 : User Input](Main.md#user-input)

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

Add lines (Line2D nodes) as children of Node `global_lines` to
simplify memory management. Free `global_lines` to free all
plot lines.
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
    App/Plot_area/PlotParts/Y1Axis_bound
    App/Plot_area/PlotParts/Data_area
    App/Plot_area/PlotParts/Data_area/Data_bound
    App/Plot_area/PlotParts/XAxis_bound
    App/Plot_area/PlotParts/Origin_bound
    App/KeyPress
## Application

\brief Application Setup

    58 : func _ready() -> void:
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

`Data_area` shall expand horizontally and vertically to claim
maximum space for plot artwork.
`Data_bound` shows the bounds of `Data_area`.
`Title_bound` shows the bounds of `Title_area`.
Use Y1Axis_bound to visualize space for the Y1 axis

\brief Application Loop

    197 : func _process(_delta) -> void:
Write text to HUD text overlay.
Title the plot.
Draw lines.
Make a new line.
Randomize its color.
Randomize the points in the line.

\brief Create a line with default width

    286 : func new_line() -> Line2D:
## User Input

\brief Handle keyboard input

    299 : func _input(event) -> void:

\brief Quit when user presses Esc

    321 : func keypress_esc() -> void:

bob
