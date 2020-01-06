extends Control

onready var nombre = $ScrollContainer/BoxContainer/VBoxContainer/L_nombre
onready var apellido = $ScrollContainer/BoxContainer/VBoxContainer2/L_apellido
onready var fecha = $ScrollContainer/BoxContainer/VBoxContainer3/HBoxContainer/Fecha
onready var numero1  = $ScrollContainer/BoxContainer/VBoxContainer4/L_No
onready var numero2  = $ScrollContainer/BoxContainer/VBoxContainer5/L_No2
onready var  correo = $ScrollContainer/BoxContainer/VBoxContainer6/L_correo
onready var label= $ScrollContainer/BoxContainer/Label
var fecha_text=""
var new_profile := false
var information_sent := false
var fecha_elegida=false
var profile := {
	"nombre" : {},
	"apellido" : {},
	"fecha" : {},
	"numero1" : {},
	"numero2" : {},
	"correo" : {}
} 
var update= true
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.get_document("users/%s" % Firebase.user_info.id)
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	
	if Firebase.temp_array_request[1] == 404:
		update=false


func _on_Button_button_down():
	get_parent().change_room("res://Logic/Escenas/MainMenu.tscn")


func _on_CalendarButton_date_selected(date_obj):
	$ScrollContainer/BoxContainer/VBoxContainer3/HBoxContainer/Fecha.text= "Tu fecha es: "+ date_obj.date()
	fecha_text=$ScrollContainer/BoxContainer/VBoxContainer3/HBoxContainer/Fecha.text
	fecha_elegida=true

func _on_Button2_button_down():
	if nombre.text.empty() or apellido.text.empty() or fecha_elegida!=true or numero1.text.empty():
		label.text = "Porfavor llena los espacios que contengan un '*'"
		return
	profile.nombre = { "stringValue": nombre.text }
	profile.apellido = { "stringValue": apellido.text }
	profile.fecha = { "stringValue": fecha_text }
	profile.numero1 = { "stringValue": numero1.text }
	profile.numero2 = { "stringValue": numero2.text }
	profile.correo = { "stringValue": correo.text }
	if update==false:
		Firebase.save_document ("users?documentId=%s" % Firebase.user_info.id, profile)
		information_sent = true
	else:
		Firebase.update_document("users?documentId=%s" % Firebase.user_info.id, profile)
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	#if response_code != 200:
	if Firebase.temp_array_request[1] != 200:
		label.text =  Firebase.temp_array_request[3].error.message.capitalize()
	#	label.text = response_body.result.error.message.capitalize()
	else:
		label.text = "Guardado exitoso amigo"
		yield(get_tree().create_timer(1.0), "timeout")
		get_parent().change_room("res://Logic/Escenas/explor.tscn")

