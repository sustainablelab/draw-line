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
## Make copies by copying each member individually.
##
var first : float
var directed_length : float

##
## \brief Class constructor
##
func _init(_first : float, _directed_length : float) -> void:
	first = _first
	directed_length = _directed_length
