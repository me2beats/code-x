tool
extends EditorPlugin

onready var newline_respect_indent = preload("extensions/newline_respect_indent.gd").new()
onready var paste_respect_indent = preload("extensions/paste_respect_indent.gd").new()

func _ready():
	newline_respect_indent.init(self)
	paste_respect_indent.init(self)

func _input(event):
	if event is InputEventKey:
		newline_respect_indent.key_input(event)
		paste_respect_indent.key_input(event)


func _exit_tree():
	pass
#	jojo
	
	




