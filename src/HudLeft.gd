extends Label


var Main:           String
var App:            String
var PlotArea:       String
var PlotArea_bound: String
var PlotParts:      String
var UpLeft_bound:   String
var Title:          String
var Y1Axis_bound:   String
var Data:           String
var Data_bound:     String
var Origin_bound:   String
var XAxis_bound:    String
var KeyPress:       String
var HudLeft:        String
var HudRight:       String


func _ready():
	valign = Label.VALIGN_TOP
	size_flags_horizontal = Label.SIZE_SHRINK_CENTER
	size_flags_vertical = Label.SIZE_EXPAND

	
