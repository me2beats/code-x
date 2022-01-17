#tool
const Utils = preload("../utils.gd")

var plugin:EditorPlugin
var scr_ed:ScriptEditor


# todo: check caret position

func init(plugin:EditorPlugin):
	self.plugin = plugin
	scr_ed = plugin.get_editor_interface().get_script_editor()



func key_input(event):
	event = event as InputEventKey 
	if event.is_pressed() and event.physical_scancode ==KEY_V and event.control:
		
		var clipboard = OS.clipboard
		if not clipboard: return

		var cur_text_ed:TextEdit = Utils.get_current_text_ed(scr_ed)
		if not cur_text_ed:return
		if not cur_text_ed.has_focus(): return

		if cur_text_ed.is_selection_active(): return # selection shall not pass


		var line_idx:int = cur_text_ed.cursor_get_line()
		
		var indent_char:String # could be Tab/Space

		var line:String = cur_text_ed.get_line(line_idx)
		if not line: return
		

		match line[0]:
			"	":
				indent_char = "	"
			" ":
				indent_char = " "
			_:
				return

		var col_idx = cur_text_ed.cursor_get_column()
		var is_caret_at_line_end:bool = line.length() == col_idx
		

		if not "\n" in clipboard:
			var clipboard_stripped = clipboard.lstrip(indent_char)
#			var clippboard_indent = clipboard.length()-clipboard.lstrip(indent_char).length()

			cur_text_ed.insert_text_at_cursor(clipboard_stripped)
			cur_text_ed.accept_event()
			return

		var line_before_caret = line.left(col_idx)
		var line_indent = line_before_caret.length()-line_before_caret.lstrip(indent_char).length()

		# get clipboard_indent
		# currently only first line (but maybe it's better to ignore lines without characters)

		var lines_to_paste = clipboard.split("\n")
		var clipboard_first_line = lines_to_paste[0]


		var clipboard_indent:int

		#get nearest line below current one, the line should contain code
		#todo: test this better!
		for _line in clipboard.split("\n"):
			var stripped = _line.lstrip(indent_char)
			if not stripped:continue
			if stripped.length() == 1:
				print("continue")
				continue
#			if stripped.begins_with('#'): continue # ignore commented out lines

			
			clipboard_indent = _line.length()-stripped.length()
#			if clipboard_indent == 0: continue
			break

		print(clipboard_indent)

		var clipboard_first_line_stripped = clipboard_first_line.lstrip(indent_char)
#		clipboard_indent = clipboard_first_line.length()-clipboard_first_line_stripped.length()
		
		var indent_diff = line_indent-clipboard_indent

		if indent_diff<0:
			# get clipboard_min_indent
			# we can't dedent more than this.
			var clipboard_min_indent: = 100000
			
			for i in range(1, lines_to_paste.size()):
				var _line:String = lines_to_paste[i]
				var _line_indent = _line.length()-_line.lstrip(indent_char).length()
				clipboard_min_indent = min(clipboard_min_indent, _line_indent)
				
			if clipboard_min_indent == 0: return

			var target_dedent = min(clipboard_min_indent, -indent_diff)


			# remove clipboard_min_indent indentation
			for i in range(1, lines_to_paste.size()):
				lines_to_paste[i] = lines_to_paste[i].right(target_dedent)
			
			
		else:
		
			# add missing indentation
			for i in range(1, lines_to_paste.size()):
				lines_to_paste[i] = indent_char.repeat(indent_diff)+lines_to_paste[i]


		lines_to_paste[0] = clipboard_first_line_stripped

		cur_text_ed.insert_text_at_cursor(lines_to_paste.join("\n"))
		cur_text_ed.accept_event()
