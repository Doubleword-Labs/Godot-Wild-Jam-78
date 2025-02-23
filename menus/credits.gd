extends Node2D

var title_path := "res://menus/title.tscn"

@onready var scroll: ScrollContainer = $ScrollContainer

var scroll_down = true
func _on_return_pressed() -> void:	
	get_tree().change_scene_to_file(title_path)


func _on_timer_timeout() -> void:
	if scroll.scroll_vertical == 0:
		scroll_down = true

	if scroll.scroll_vertical == 800:
		scroll_down = false

	if scroll_down:
		scroll.scroll_vertical += 1
	else:
		scroll.scroll_vertical -= 1
	
	#print(scroll.scroll_vertical)
