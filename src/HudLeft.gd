extends Label


var Main:         String
var App:          String
var Plot_area:    String
var PlotParts:    String
var UpLeft_area:  String
var Title_area:   String
var Title:        String
var Y1Axis_area: String
var Y2Axis_area: String
var Data_area:    String
var Origin_area: String
var XAxis_area:  String
var KeyPress:     String
var HudLeft:      String
var HudRight:     String


func _ready():
	valign = Label.VALIGN_TOP
	size_flags_horizontal = Label.SIZE_SHRINK_CENTER
	size_flags_vertical = Label.SIZE_EXPAND
