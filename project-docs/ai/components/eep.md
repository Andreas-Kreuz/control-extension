# EEP (external programm)

Role:

- stand-alone app outside the scope of this project
- host program with embedded Lua 5.3
- source of raw EEP state
- provides variables, getters, setters, and callbacks to Lua

Boundary:

- exposes the EEP API to the Lua side
- is not part of the control extension itself

Rule:

- EEP is the source system; control extension layers must adapt around it, not redefine it
