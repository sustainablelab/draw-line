class_name Axis
##
## \brief Define an axis by its first value and its directed length.
##
## \param first: The value at the axis origin.
## \param directed_length: The length of the axis. Length cannot
## be zero. Positive length means last > first. Negative length
## means first > last.
##
## Usage:
##
## Create with new().
##
## ```
## var axis := Axis.new() 
## ```
##
## Do not free.
## This is a Reference (handled by Godot's reference counter).
##
## Assignment references the same memory.
## Make copies with copy_from():
##
## ```
## var destAxis := Axis.new()
## destAxis.copy_from(srcAxis)
## ```
##
var first : float
var directed_length : float

func copy_from(axis : Axis) -> void:
	first = axis.first
	directed_length = axis.directed_length
