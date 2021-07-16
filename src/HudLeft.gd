extends Label


var Main:        String = "---"
var App:         String = "---"
var PlotArea:    String = "---"
var Placeholder: String = "---"
var KeyPress:    String = "---"
var Hud:         String = "---"


func _ready():
	valign = Label.VALIGN_TOP
	size_flags_horizontal = Label.SIZE_SHRINK_CENTER
	size_flags_vertical = Label.SIZE_EXPAND
