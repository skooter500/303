@tool
class_name AssistantToolCodeWriter

var _plugin:EditorPlugin
var _code_selector:AssistantToolSelection


func _init(plugin:EditorPlugin, code_selector:AssistantToolSelection) -> void:
	_plugin = plugin
	_code_selector = code_selector


func write_to_code_editor(text_answer:String, code_placement:AIQuickPromptResource.CodePlacement) -> bool:
	var select_success := _code_selector.back_to_selection()
	if select_success:
		var script_editor := _plugin.get_editor_interface().get_script_editor().get_current_editor()
		var code_editor = script_editor.get_base_editor()
		var start_line:int = code_editor.get_selection_from_line()
		var end_line:int = code_editor.get_selection_to_line()
		code_editor.set_caret_line(start_line)
		match code_placement:
			AIQuickPromptResource.CodePlacement.BeforeSelection:
				code_editor.insert_line_at(start_line, text_answer)
			AIQuickPromptResource.CodePlacement.AfterSelection:
				if end_line == code_editor.get_line_count() - 1: #it is at the end of the editor
					code_editor.text += "\n%s" % text_answer
				else:
					code_editor.insert_line_at(end_line + 1, text_answer)
			AIQuickPromptResource.CodePlacement.ReplaceSelection:
				code_editor.delete_selection()
				text_answer = text_answer.trim_suffix("\n")
				code_editor.insert_text_at_caret(text_answer)
			_:
				push_error("Unexpected Quick Prompt code placement value: %s" % code_placement)
		code_editor.scroll_vertical = code_editor.get_scroll_pos_for_line(start_line) - 10
		code_editor.select(start_line, 0, start_line, 0)
		return true
	return false
