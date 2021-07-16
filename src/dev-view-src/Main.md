# File Summary

   type |  GDScript file  | nlines | details
------- | --------------- | ------ | -------
 script |         Main.gd |    316 | extends MarginContainer <--- THIS IS THE MAIN SCRIPT
 script |  MyUtilities.gd |     52 | extends Node
 script |      HudLeft.gd |     26 | extends Label
 script |     KeyPress.gd |     15 | extends Label
 script |     HudRight.gd |     10 | extends Label


## Summary

    Main.gd: 316 lines

Read Main.gd by starting at the `_ready()` callback on line
55.

All drawing happens in the `_process()` callback on line
187.

## Table of Contents

- [4 : Globals](Main.md#globals)
- [49 : Application](Main.md#application)
- [286 : User Input](Main.md#user-input)

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
    App/PlotArea
    App/PlotArea/PlotArea_bound
    App/PlotArea/PlotParts
    App/PlotArea/PlotParts/UpLeft_bound
    App/PlotArea/PlotParts/Title
    App/PlotArea/PlotParts/Y1Axis_bound
    App/PlotArea/PlotParts/Data
    App/PlotArea/PlotParts/Data/Data_bound
    App/PlotArea/PlotParts/XAxis_bound
    App/PlotArea/PlotParts/Origin_bound
    App/KeyPress
## Application

\brief Application Setup

    55 : func _ready() -> void:
Randomize the seed for Godot's random number generator.
Say hello.

**Screen Layout**

Put a dark background in the Window.
The layout shall fill the window and shall auto-resize when
the user resizes the window.

**Node Main**

`Main` is divided into an `App` layer and a `Dev` overlay layer.

**Node App**

`App` divides the screen into two rows: `PlotArea` and
`KeyPress`.

**Show key presses at the bottom of the screen**


**Node PlotArea**

`PlotArea` expands and fills vertically, pushing `KeyPress`
to the screen bottom.
`PlotArea_bound` shows the bounds of `PlotArea`.

**Node PlotParts**

`PlotParts` is a `GridContainer`. Godot determines the
number of rows in the `GridContainer` by dividing the
number of children in `PlotParts` by `PlotParts.columns`.
- `UpLeft_bound` shows the dead space in the upper-left
corner of the plot area.

- `Title` is the plot title, above the data.

- `Y1Axis_bound` shows the space for the Y-axis to the
left of the data.

- `Data_bound` shows the space for the plot lines.

- `XAxis_bound` shows the space for the X-axis.

- `Origin_bound` shows the dead space in the lower-left
corner of the plot area.

**Node Data**

`Data` shall expand horizontally and vertically to claim
maximum space for plot artwork.
`Data_bound` shows the bounds of `Data`.
Use Y1Axis_bound to visualize space for the Y1 axis
Use XAxis_bound to visualize space for the X axis
Use Origin_bound to block off dead space under the Y1Axis
Use UpLeft_bound to block off dead space under the Y1Axis

\brief Application Loop

    187 : func _process(_delta) -> void:
Write text to HUD text overlay.
Title the plot.
Draw lines.
Make a new line.
Randomize its color.
Randomize the points in the line.

\brief Create a line with default width

    279 : func new_line() -> Line2D:
## User Input

\brief Handle keyboard input

    292 : func _input(event) -> void:

\brief Quit when user presses Esc

    314 : func keypress_esc() -> void:

bob
