extends Node

## \brief Print a log msg to stdout
##
## Example: "@LOG(res://src/Main.tscn): Enter scene tree"
## 
## \param scene: Always pass member variable `filename`
## \param msg: The string to print
func log_to_stdout(scene : String, msg : String) -> void:
	print("@LOG({filename}): {msg}".format({
		"filename":scene,
		"msg":msg
		}))
