extends Control

var check=false
onready var username : LineEdit = $L_correo
onready var password : LineEdit = $L_pass
onready var label : Label = $Label


func _on_Button_button_down():
	get_parent().change_room("res://Logic/Escenas/MainMenu.tscn")


func _on_Button2_button_down():
	$Popup.show()


func _on_Button_REG_button_down():
	if check==true:
		if password.text.empty() or username.text.empty():
			label.text="Correo o contraseña invalida"
			return
		Firebase.register(username.text,password.text)
		Firebase.Omega.loading()
		yield(Firebase.http,"request_completed")
	#if response_code != 200:
		if Firebase.temp_array_request[1] != 200:
			label.text =  Firebase.temp_array_request[3].error.message.capitalize()
		#	label.text = response_body.result.error.message.capitalize()
		else:
			label.text = "Login exitoso amigo"
			$Timer.start()
	else:
		label.text = "Debes aceptar términos y condiciones \n para usar esta app"

func _on_Button_check_button_down():
	check=!check
	$Button_check/TextureRect.visible=check


func _on_Timer_timeout():
	get_parent().change_room("res://Logic/Escenas/Registro2.tscn")
