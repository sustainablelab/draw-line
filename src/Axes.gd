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
## Make copies with copy_from():
##
## ```
## var destAxes := Axes.new(Axis.new(), Axis.new(), pan_offset)
## destAxes.copy_from(srcAxes)
## ```
##
var x : Axis
var y : Axis
var pan_offset : Vector2

func _init(xAxis : Axis, yAxis : Axis, panOffset : Vector2) -> void:
	x = xAxis
	y = yAxis
	pan_offset = panOffset

func copy_from(axes : Axes) -> void:
	# Use Axis.copy_from to copy the x axis and y axis
	x.copy_from(axes.x)
	y.copy_from(axes.y)
	# Vector2 is a built-in type, so assignment acts as a copy
	pan_offset = axes.pan_offset
