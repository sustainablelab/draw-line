[Back to top-level README](../README.md#ToC)

1. Read this doc to learn convenient ways to launch Godot and to
   launch the game from the cmdline.
2. After that, start developing!

- To get started developing:
    - jump directly to [Main.md](../src/dev-view-src/Main.md) (the
      documentation for the **main GDScript**: `Main.gd`)
    - the documentation for `Main.gd` starts with:
        - a [table summarizing the source
          files](../src/dev-view-src/Main.md#file-summary) in
          the project
            - the table shows the number of *lines of code* (**LOC**)
              for each source file (`Main.gd` is the only one
              long enough to need a summary)
        - [where to look](../src/dev-view-src/Main.md#summary) in
          `Main.gd` to get started understanding the code
- While reading the code, it is useful to refer to
  [doc/godot.md](godot.md). This is where I store all of my
  knowledge about Godot.

# Getting Started

I set up for two ways to run the game:

1. run the game from the Godot editor:
    - start up Godot editor
    - select project to edit
    - run the game with `F5`
2. run the game directly (without launching the Godot editor first)
    - launch game from cmdline
    - this is to make it easy to test the game while editing the
      code in Vim
    - it's also how I prefer to launch the game when I'm using it
      (not developing it)

This document details how to set this up.

## ToC

- [Create a PowerShell alias to launch Godot](start.md#create-a-powershell-alias-to-launch-godot)
- [Launch game directly from cmdline](start.md#launch-game-directly-from-cmdline)

## Create a PowerShell alias to launch Godot

**Goal: type `godot` at PowerShell and Godot starts up**

### Create a PowerShell Profile

Windows ships with PowerShell.

Open PowerShell with `Win + x, i`:

- hold `Win` key and press `x`
- then let go of `Win` key and press `i`

PowerShell looks for `PROFILE` when it starts. The `PROFILE` is
like a `.bashrc` on Linux/macOS -- it's where I put commands that
I want to run when I open a new PowerShell.

The commands in my `PROFILE` customize the behavior of PowerShell
to my workflow. **For example, creating aliases to programs.**

First, find out where `PROFILE` is:

```
PS C:\Users\mike> echo $PROFILE
C:\Users\mike\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

It's always in `Documents` in a subfolder named
`WindowsPowerShell`. If that folder doesn't exist, create it.

Now that the folder path exists, this command will create a new
`PROFILE`. If the file already exists, this will open the
existing file for editing:

```
PS C:\Users\mike> notepad $PROFILE
```

Create an alias to the Godot executable. It doesn't matter where
Godot is. I put my Godot installation in my Cygwin `$HOME` path:

```powershell-alias
Set-Alias -Name godot -Value "C:\cygwin64\home\mike\Godot_v3.2.3-stable_win64.exe"
```

Source the `PROFILE`:

```powershell-source-profile
PS C:\Users\mike> . $PROFILE
```

Now I can launch Godot from PowerShell:

```powershell-launch-godot
PS C:\Users\mike> godot
Godot Engine v3.2.3.stable.official - https://godotengine.org
OpenGL ES 3.0 Renderer: NVIDIA GeForce GTX 1080/PCIe/SSE2
```

### Repeat for bash

I do the same for my Cygwin `.bashrc`. Unlike `PROFILE`, the
`.bashrc` already exists in my Cygwin `$HOME` folder:

```
$ cd $HOME
$ ls .bashrc
.bashrc*
```

I add the `alias` in my `.bashrc` and I export the `alias`:

```bash
godot="/home/mike/Godot_v3.2.3-stable_win64.exe"
alias godot="$godot"
export godot
```

Source the `.bashrc`:

```
$ . .bashrc
```

Now I can launch Godot from Cygwin bash:

```bash
$ godot
Godot Engine v3.2.3.stable.official - https://godotengine.org
OpenGL ES 3.0 Renderer: NVIDIA GeForce GTX 1080/PCIe/SSE2
```

## Launch game directly from cmdline

### While developing

As long as I'm inside the project folder, the command `godot`
launches the game instead of the Godot editor. This is how I
launch the game while I'm developing and I just want to quickly
test my changes. This also makes it easier for me to see the log
messages that my game generates.

```bash
mike@DESKTOP-H26981V ~/godot-games/draw-line
$ godot
Godot Engine v3.2.3.stable.official - https://godotengine.org
OpenGL ES 3.0 Renderer: NVIDIA GeForce GTX 1080/PCIe/SSE2
 
@LOG(res://src/KeyPress.tscn): Enter scene tree
@LOG(res://src/Main.tscn): Enter scene tree
 Main
    App
      Plot_area
        ...
@LOG(res://src/Main.tscn): User quit with Esc
```

### As a user

When I want to run the game just as a user, I open a new
PowerShell and enter the name of the game, in this case
`draw-line`:

```PowerShell
PS C:\Users\mike> draw-line
```

To make the above work, I put the following in my `PROFILE`.


```powershell-alias-to-run-game
function RunDrawLine {
    C:\cygwin64\home\mike\Godot_v3.2.3-stable_win64.exe --path C:\cygwin64\home\mike\godot-games\draw-line
}

Set-Alias -Name draw-line -Value RunDrawLine
```

I make an alias *to a PowerShell function*. The function lets me
add extra info I cannot add if I was just making an alias.

I use the function to add the `--path` flag. That flag tells
Godot to launch from the `draw-line` project folder, in effect
doing exactly what I do when I manually enter a folder and run my
`godot` alias.
