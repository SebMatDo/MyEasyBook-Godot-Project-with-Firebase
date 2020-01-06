extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_B_navigattion_button_down():
	get_parent().change_room("res://Logic/Escenas/Navigation.tscn")

func _on_B_settings_button_down():
	get_parent().change_room("res://Logic/Escenas/Settings.tscn")


func _on_B_pedidos_button_down():
	get_parent().change_room("res://Logic/Escenas/Pedidos.tscn")


func _on_B_usuario_button_down():
	get_parent().change_room("res://Logic/Escenas/Usuario.tscn")

func _on_B_explorar_button_down():
	get_parent().change_room("res://Logic/Escenas/explor.tscn")
