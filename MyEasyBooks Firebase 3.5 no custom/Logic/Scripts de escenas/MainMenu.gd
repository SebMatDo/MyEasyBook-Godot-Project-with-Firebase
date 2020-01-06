extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_down():
	get_parent().change_room("res://Logic/Escenas/RegisterMenu.tscn")


func _on_Button2_button_down():
	get_parent().change_room("res://Logic/Escenas/Iniciar_Menu.tscn")


func _on_Button3_button_down():
	$Popup.show()
	
	
