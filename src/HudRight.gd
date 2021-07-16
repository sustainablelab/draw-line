extends Label


var Mouse : String = "---"

func _ready():
	valign = Label.VALIGN_TOP
	size_flags_horizontal = Label.SIZE_SHRINK_CENTER
	size_flags_vertical = Label.SIZE_EXPAND
