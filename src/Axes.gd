class_name Axes
##
## \brief Define axes as an xy axis with some panning offset.
## \param x: The X-Axis
## \param y: The Y-Axis
## \param pan_offset: Use this to translate the rectangle defined
## by the x and y axis. Coordinate (`x[0]`,`y[0]`) define the axes
## origin. Use the `pan_offset` to change this origin without
## changing the directed_length of either axis.
##
## Usage:
##
## Create with new().
##
## ```
## var axes := Axes.new() 
## ```
##
## Do not free.
## This is a Reference (handled by Godot's reference counter).
##
## Assignment references the same memory.
## Make copies by copying each member individually.
##
var x : Axis
var y : Axis
var pan_offset : Vector2

##
## \brief Class constructor
##
func _init(_x : Axis, _y : Axis, _pan_offset : Vector2) -> void:
	x = _x
	y = _y
	pan_offset = _pan_offset
