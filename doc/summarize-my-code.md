[Back to top-level README](../README.md#ToC)

# Summarize my code

Generate the summary:

```
cd src
make
```

Open the summary:

```
vim dev-view-src/Main.md
```

## ToC

- [Go to summary Main.md](../src/dev-view-src/Main.md)
- [What is going on here](summarize-my-code.md#what-is-going-on-here)
- [What the summarizing script looks for](summarize-my-code.md#what-the-summarizing-script-looks-for)

## What is going on here

### What make does

There is a Makefile in the `src` folder. The Makefile is just two
lines:

```make
code-summary:
	python.exe ../dev-scripts/summarize-my-code.py
```

Enter the `src` folder and run `make -n` (the `-n` flag shows
what `make` will do without actually doing it):

```bash
mike@DESKTOP-H26981V ~/godot-games/draw-line/src
$ make -n
python.exe ../dev-scripts/summarize-my-code.py
```

### What am I summarizing

The game is written in `GDScript`, the Godot scripting language.

My Python script summarizes my GDScript code in a Markdown file.
By following some conventions in my GDScript, I automate making a
summary from the comments in my GDScript.

### Why am I summarizing

The summary is useful to quickly see "what" is in the code. The
script files themselves are kind of long. Even with good syntax
folding, it's a little hard to get a sense of what's in there.

## What the summarizing script looks for

The Python script opens the `.gd` file (`GDScript`) and looks for
a bunch of stuff.

### Look for section names

Look for comment that contain section names.

- comment lines start with `#`
    - if the line has "`| `" and "` |`" it is a **level 1 name**
    - if the line has "`[ `" and "` ]`" it is a **level 2 name**
    - if the line has "`< `" and "` >`" it is a **level 3 name**
- *Example:*

```gdscript
# -----------
# | Globals | <--------------- THIS LINE HAS A LEVEL 1 NAME
# -----------
# =====[ Dev ]===== <--------- THIS LINE HAS A LEVEL 2 NAME
# ---< Scene Tree >--- <------ THIS LINE HAS A LEVEL 3 NAME
```

- **level 1** section names show up in the table of contents:

```markdown
## Table of Contents

`- [4 : Globals](Main.md#globals)
```

- And that link in the table of contents goes to a section of
  the summary that is a Markdown `##` level:

```markdown
## Globals

Global variables:
```

- **level 2** section names show up in the summary as
  Markdown `###` level and **level3** names as `####` level:

```markdown
### Dev
#### Scene Tree
    Dev
    Dev/HudLeft
    Dev/HudRight
```

### Look for comments I want in my documentation

Look for comments that contain text I want to print in my
summary.

- comment lines that I want to print start with `##`
- *Example:*

```gdscript
# =====[ Libraries ]=====

## Utility functions are in `MyUtilities.gd`. To call a utility
## function:
##
##     `myu.function_name()`
```

- the above turns into this Markdown:

```markdown
### Libraries
Utility functions are in `MyUtilities.gd`. To call a utility
function:

`myu.function_name()`
```

### Look for functions and their docstrings

- look for function definitions
    - function definitions start with "`func `"
    - comment lines that start with `## \brief` are docstrings
      for function definitions
- *Example:*

```gdscript
##
## \brief Application Setup
##
func _ready() -> void:
    ## Randomize the seed for Godot's random number generator.
```

- the above turns into this Markdown:

```markdown
> **Application Setup**
>

    67 : func _ready() -> void:

Randomize the seed for Godot's random number generator.
Say hello.
```

### Look for scene tree

- look for calls to `get_node("Node1/Node2")`
    - these are the nodes the script assigns variables to (to
      make it easy to access the node within the script)
    - I can figure out the Scene Tree from the `get_node` calls
- the `Main` scene is divided into `App` and `Dev` child nodes
- I label `Scene Tree` sections in my code for each
- *Example: Here are the `get_node` calls for `App`*

```gdscript
# ---< Scene Tree >---
onready var App:          VBoxContainer   = get_node("App")
onready var Plot_area:    MarginContainer = get_node("App/Plot_area")
onready var Plot_bound:   ReferenceRect   = get_node("App/Plot_area/Plot_bound")
onready var PlotParts:    GridContainer   = get_node("App/Plot_area/PlotParts")
onready var UpLeft_area:  MarginContainer = get_node("App/Plot_area/PlotParts/UpLeft_area")
...
```

- Here is how that shows up in my documentation:

```markdown
#### Scene Tree
App
App/Plot_area
App/Plot_area/Plot_bound
App/Plot_area/PlotParts
App/Plot_area/PlotParts/UpLeft_area
...
```

- Same goes for the `Dev` scene:

```gdscript
# ---< Scene Tree >---
onready var Dev:      HBoxContainer = get_node("Dev")
onready var HudLeft:  Label         = get_node("Dev/HudLeft")
onready var HudRight: Label         = get_node("Dev/HudRight")
```

- and in the documentation:

```markdown
#### Scene Tree
    Dev
    Dev/HudLeft
    Dev/HudRight
```

- these correspond to the scene tree visualization in the Godot editor:

![scene tree in Godot
editor](img/scene-tree-in-godot-editor.PNG)

*Note: The `Main` scene is the root node because the above code is in
`Main.gd` and `Main.gd` is the script attached to `Main.tscn`.*
