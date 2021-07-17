extends Label


onready var myu : Node = preload("res://src/MyUtilities.tscn").instance()


func _ready():
	add_child(myu, true)
	align = Label.ALIGN_RIGHT
	valign = Label.VALIGN_BOTTOM
	grow_horizontal = GROW_DIRECTION_BEGIN
	grow_vertical = GROW_DIRECTION_BEGIN
	size_flags_horizontal = SIZE_SHRINK_END
	size_flags_vertical = SIZE_SHRINK_END
	myu.log_to_stdout(filename,"Enter scene tree")

