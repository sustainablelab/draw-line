#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Summary my GDScript code in a Markdown file.
"""
import sys

print(f"Running '{__file__}' with Python {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}\n")

import pathlib
# ---------------------------------------------
# | Render a plain text file of section names |
# ---------------------------------------------

# A section name is bracketed with || like this:
#     | Section name |

def is_level1_name(line:str) -> bool:
    if line.startswith("#"):
        if "| " in line and " |" in line:
            return True

def is_level2_name(line:str) -> bool:
    if line.startswith("#"):
        if "[ " in line and " ]" in line:
            return True

def is_level3_name(line:str) -> bool:
    if line.startswith("#"):
        if "< " in line and " >" in line:
            return True

def is_gdscript_function(line:str) -> bool:
    if line.startswith("func "):
        return True

def is_doc_comment(line:str) -> bool:
    if line.strip().startswith("##"):
        return True

def is_start_of_func_docstring(line:str) -> bool:
    if "\\brief" in line:
        return True

def is_get_node(line:str) -> bool:
    if "get_node(" in line:
        return True

def get_toc(code_filepath: pathlib.Path) -> list:
    toc = []
    line_num = 0
    with code_filepath.open() as f:
        for line in f:
            line_num += 1
            if is_level1_name(line): # box: | name |
                name = f"{line.split('|')[1].strip()}"
                text = f"{line_num} : {name}"
                link = name.lower().replace(" ","-")
                level1 = f"- [{text}](Main.md#{link})"
                toc.append(level1)
    return toc

# TODO: gotta rename this to show it is more than section names
def get_section_names(code_filepath: pathlib.Path) -> list:
    """Return lines from code file formatted for markdown.

    Section names.

    There are three section levels:

        | name |
        [ name ]
        < name >

    Copy section names. Show as markdown levels ##, ###, and ####.

    Functions.

    Copy the entire function signature. Show as a code block.

    Doc comments.

    Copy doc comments (##). Show as regular text.
    """
    section_names = []
    line_num = 0
    part_of_multiline_func = False
    part_of_func_docstring = False
    with code_filepath.open() as f:
        for line in f:
            line_num += 1
            if not is_doc_comment(line):
                part_of_func_docstring = False
            if part_of_multiline_func:
                section_names.append(f"        {line.strip()}\n")
                if ")" in line:
                    part_of_multiline_func = False
            else:
                if is_level1_name(line): # box: | name |
                    level1 = f"## {line.split('|')[1].strip()}"
                    section_names.append(level1)
                elif is_level2_name(line): # belt: ====[ name ]====
                    level2 = f"### {line.split('[ ')[1].split(' ]')[0]}"
                    section_names.append(level2)
                elif is_level3_name(line): # arrow: ---< name >---
                    name = f"{line.split('< ')[1].split(' >')[0]}"
                    level3 = f"#### {name}"
                    section_names.append(level3)
                elif is_gdscript_function(line): # func my_func(var_t : var) -> ret_t:
                    if not ")" in line:
                        part_of_multiline_func = True
                        line_as_code_block = f"\n    {line_num} : {line.strip()}"
                    else:
                        line_as_code_block = f"\n    {line_num} : {line.strip()}\n"
                    section_names.append(line_as_code_block)
                    # Pick up multiline function signatures
                elif is_start_of_func_docstring(line): # starts with ## \brief
                    line_as_docstring = "**" + line.strip("## ").strip("\\brief").strip() + "**"
                    section_names.append(f"> {line_as_docstring}")
                    part_of_func_docstring = True
                elif is_doc_comment(line): # doc comments start with ##
                    if part_of_func_docstring:
                        if line.strip() != "##":
                            line_as_docstring = "*" + line.strip("## ").strip() + "*"
                            # line_as_docstring = f"> {line.strip('## ').strip()}"
                            section_names.append(f"> {line_as_docstring}")
                        else:
                            section_names.append(f">")
                    else:
                        line = line.lstrip()
                        if line != "##":
                            line_as_plain_text = line.strip("##").strip()
                        else:
                            # Do not strip newline if doc comment is blank.
                            line_as_plain_text = line.strip("##")
                        section_names.append(line_as_plain_text)
                        # section_names.append(line)
                elif is_get_node(line): # get_node("Node1/Node2')
                    node_name = line.split('(')[1].split(')')[0].strip('"')
                    node_name_as_code_block = f"    {node_name}"
                    section_names.append(node_name_as_code_block)

    return section_names

def is_global(line:str) -> bool:
    return line.startswith("var") or line.startswith("onready var")

def is_global_var(line:str) -> bool:
    return (
        is_global(line)
        ) and (
        "get_node(" not in line
        ) and (
        "preload(" not in line
        )

def is_scene_tree_node(line:str) -> bool:
    return (
        line.startswith("onready var")
        ) and (
        "get_node(" in line or "preload" in line
        )

def is_comment(line:str) -> bool:
    return (line.strip().startswith("#"))

def is_blank(line:str) -> bool:
    return(line == "\n")

def num_globals(code_filepath: pathlib.Path) -> int:
    nlines = 0
    with code_filepath.open() as f:
        for line in f:
            # Ignore scene tree node global variables
            if is_global_var(line):
                nlines += 1
    return nlines

def get_length(code_filepath: pathlib.Path) -> int:
    nlines = 0
    with code_filepath.open() as f:
        for line in f:
            if not is_comment(line) and not is_blank(line):
                nlines += 1
    return nlines

def create_main_summary(code_filepath: pathlib.Path) -> str:
    length = get_length(code_filepath)
    toc_text = "\n".join(get_toc(code_filepath))
    section_names = get_section_names(code_filepath)
    section_names.insert(
        # After section Globals
        section_names.index('## Globals') + 1,
        # Insert all the globals
        collect_globals(code_filepath)
        )
    section_name_text = "\n".join(section_names)
    # Which line of code is _ready() on?
    ready_line_num = 0
    for name in section_names:
        if "_ready(" in name:
            ready_line_num = name.split(":")[0].strip()
    # Which line of code is _process() on?
    process_line_num = 0
    for name in section_names:
        if "_process(" in name:
            process_line_num = name.split(":")[0].strip()
    return f"""## Summary

    {code_filepath.name}: {length} lines

Read Main.gd by starting at the `_ready()` callback on line
{ready_line_num}.

All drawing happens in the `_process()` callback on line
{process_line_num}.

## Table of Contents

{toc_text}

{section_name_text}
"""

def create_class_summary(code_filepath: pathlib.Path) -> str:
    return f"""bob
"""

def collect_globals(code_filepath: pathlib.Path) -> str:
    global_vars = []
    global_nodes = []
    with code_filepath.open() as f:
        for line in f:
            if is_global_var(line):
                global_vars.append(line)
            elif is_scene_tree_node(line):
                global_nodes.append(line)
    global_var_text = "".join(global_vars)
    global_node_text = "".join(global_nodes)
    return f"""
Global variables:

```
{global_var_text}```

*Scene tree node* global variables:

```
{global_node_text}```
"""

if __name__ == '__main__':

    # ----------------------------------
    # | Get the path to my source code |
    # ----------------------------------
    # ▾ dev-scripts/
    #     summarize-my-code.py <-- I AM HERE
    # ▸ src/
    #     Main.gd <-- I WANT TO LOOK AT THIS
    project_root = pathlib.Path(__file__).absolute().parent.parent
    src = pathlib.Path()
    src = src.joinpath(project_root, "src")
    assert src.exists()

    # -------------------------------
    # | Make the path to my summary |
    # -------------------------------
    # ▾ src/
    #   ▾ dev-view-src/
    #       Main.md
    my_summary = src.joinpath("dev-view-src/Main.md")
    assert my_summary.parent.exists()

    # ------------------------------
    # | Summarize the source files |
    # ------------------------------
    with my_summary.open("w", encoding="utf-8") as o:
        o.write(f"""# File Summary

   type |  GDScript file  |   LOC  | global | details
------- | --------------- | ------ | ------ | -------
""")
        my_code_files = list(src.glob("*.gd"))
        # Determine file type and details from first line of each file
        file_types = []
        details = []
        for my_code in my_code_files:
            with my_code.open() as f:
                line = "\n"
                while is_blank(line) or is_comment(line):
                    line = next(f)
                line = line.strip()
                if line.startswith("class_name"):
                    file_types.append("class")
                    details.append(f"defines `{line}`")
                elif line.startswith("extends"):
                    # Check for class_name on next line
                    next_line = next(f).strip()
                    if next_line.startswith("class_name"):
                        file_types.append("class")
                        details.append(f"defines `{next_line}`, `{line}`")
                    else:
                        file_types.append("script")
                    if str(my_code.name) == 'Main.gd':
                        details.append(f"{line} <--- THIS IS THE MAIN SCRIPT")
                    else:
                        details.append(line)
                else:
                    file_types.append("unknown")
                    details.append(f"first line of code: {line}")
        lengths = [get_length(f) for f in my_code_files]
        nglobals = [num_globals(f) for f in my_code_files]
        # Sort files by type
        #                0             1          2       3        4
        all_f = list(zip(my_code_files,file_types,lengths,nglobals,details))
        class_f = []
        script_f = []
        unknown_f = []
        for f in all_f:
            if f[1] == 'class':
                class_f.append(f)
            elif f[1] == 'script':
                script_f.append(f)
            elif f[1] == 'unknown':
                unknown_f.append(f)
        # Within each type:
        # sort by lines of code -- nlines is tuple index 2
        # and reverse the sort to get the longest file first
        class_f.sort(key = lambda t: t[2], reverse=True)
        script_f.sort(key = lambda t: t[2], reverse=True)
        unknown_f.sort(key = lambda t: t[2], reverse=True)
        # Combine them back together
        all_f = class_f + script_f + unknown_f
        for f,t,l,n,d in all_f:
            o.write(f"{t:>7} | {str(f.name):>15} | {l:>6} | {n:>6} | {d}\n")

        # ------------------------
        # | Write up for Main.gd |
        # ------------------------
        o.write("\n\n")
        my_main_code = src.joinpath("Main.gd")
        o.write(create_main_summary(my_main_code))
        o.write("\n")

        # --------------------------------------------------
        # | Write up for custom classes defined in scripts |
        # --------------------------------------------------
        # TODO: figure these script names out from the file
        # summary!
        my_class_code = src.joinpath("PlotInfo.gd")
        o.write(create_class_summary(my_class_code))

