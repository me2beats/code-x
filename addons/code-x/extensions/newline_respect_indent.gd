#tool
const Utils = preload("../utils.gd")

var plugin:EditorPlugin
var scr_ed:ScriptEditor


func init(plugin:EditorPlugin):
	self.plugin = plugin
	scr_ed = plugin.get_editor_interface().get_script_editor()



func key_input(event):
	if Input.is_key_pressed(KEY_ENTER):
		var cur_text_ed:TextEdit = Utils.get_current_text_ed(scr_ed)
		if not cur_text_ed:return
		if not cur_text_ed.has_focus(): return

		if cur_text_ed.is_selection_active(): return # selection shall not pass
		
		var col_idx = cur_text_ed.cursor_get_column()
		var line_idx:int = cur_text_ed.cursor_get_line()
		
		var line:String = cur_text_ed.get_line(line_idx)
		if not line.begins_with("#"): return # line should start with # (commented out)

		if not line.length() == col_idx: return # caret should be only at the end of the line (maybe not needed tho)
		
		if line.length() == 1: return
		
		var indent_char:String # could be Tab/Space
		
		match line[1]:
			"	":
				indent_char = "	"
			" ":
				indent_char = " "
			_:
				return

		var indent = 0


		for i in range(1, line.length()):
			var chr = line[i]
			if !chr == indent_char: break
			indent+=1



		cur_text_ed.insert_text_at_cursor("\n"+indent_char.repeat(indent))
		cur_text_ed.accept_event()
