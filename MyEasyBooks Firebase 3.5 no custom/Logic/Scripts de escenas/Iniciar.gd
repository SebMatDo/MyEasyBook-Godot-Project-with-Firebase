extends Control

onready var username : LineEdit = $L_correo
onready var password : LineEdit = $L_pass
onready var label : Label = $Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Button_button_down():
	get_parent().change_room("res://Logic/Escenas/MainMenu.tscn")


func _on_Button2_button_down():
	if username.text.empty() or password.text.empty():
		label.text = " Porfavor llena los espacios con información valida " 
		return
	Firebase.login(username.text, password.text)
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	#if response_code != 200:
	if Firebase.temp_array_request[1] != 200:
		label.text =  Firebase.temp_array_request[3].error.message.capitalize()
	#	label.text = response_body.result.error.message.capitalize()
	else:
		label.text = "Login exitoso amigo"
		$Timer.start()
	
	
func _on_Timer_timeout():
	get_parent().change_room("res://Logic/Escenas/explor.tscn")


