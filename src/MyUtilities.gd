extends Node


##
## \brief Print a log msg to stdout
##
## Example: "@LOG(res://src/Main.tscn): Enter scene tree"
## 
## \param scene: Always pass member variable `filename`
## \param msg: The string to print
##
func log_to_stdout(scene : String, msg : String) -> void:
	print("@LOG({filename}): {msg}".format({
		"filename":scene,
		"msg":msg
		}))


##
## \brief Report the size and position of a Control Node
##
## Example: "NODE: Main    SIZE: (800, 300)    POSITION: (0, 0)"
##
## \param control: The Control node to report on.
##
## \return String for display in the HUD text overlay
##
func report_size_and_position(control : Control) -> String:

	## Get the name of this control node
	var path = NodePath(control.get_path())
	var name : String = path.get_name(path.get_name_count()-1)

	## Get the global size and position of this control node
	var rect = control.get_global_rect()

	### Report its size and position
	var size: String
	var pos:  String
	var msg:  String

	size = String(rect.size)
	pos = String(rect.position)
	msg = "NODE: {n}{gap1}SIZE: {s}{gap2}POSITION: {p}{gap3}".format({
		"n":name,
		"gap1":" ".repeat(15 - name.length()),
		"s":size,
		"gap2":" ".repeat(13 - size.length()),
		"p":pos,
		"gap3":" ".repeat(13 - pos.length())
		})
	return msg
