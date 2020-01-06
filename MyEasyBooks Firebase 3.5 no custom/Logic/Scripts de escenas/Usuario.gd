extends Control

onready var nombre = $ScrollContainer/BoxContainer/VBoxContainer/L_nombre
onready var apellido = $ScrollContainer/BoxContainer/VBoxContainer2/L_apellido
onready var fecha = $ScrollContainer/BoxContainer/VBoxContainer3/HBoxContainer/Fecha
onready var numero1  = $ScrollContainer/BoxContainer/VBoxContainer4/L_No
onready var numero2  = $ScrollContainer/BoxContainer/VBoxContainer5/L_No2
onready var  correo = $ScrollContainer/BoxContainer/VBoxContainer6/L_correo
onready var label= $ScrollContainer/BoxContainer/Label

func _on_Button2_button_down():
	get_parent().change_room("res://Logic/Escenas/Registro2.tscn")

func _on_B_Regresar_button_down():
	get_parent().change_room("res://Logic/Escenas/explor.tscn")

func _ready():
	Firebase.get_document("users/%s" % Firebase.user_info.id) ## Para acceder es así.
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	var dic = Firebase.temp_array_request[3].fields
	nombre.text = dic["nombre"]["stringValue"]
	apellido.text= dic["apellido"]["stringValue"]
	fecha.text= dic["fecha"]["stringValue"]
	numero1.text= dic["numero1"]["stringValue"]
	numero2.text= dic["numero2"]["stringValue"]
	correo.text= dic["correo"]["stringValue"]
	
