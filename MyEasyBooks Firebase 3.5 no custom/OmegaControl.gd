extends Control

#### ESTE NODO DE CONTROL SE ENCARGARA DE CREAR Y BORRAR CUALQUIER NODO Y NUNCA SERA CAMBIADO
var room
var temp
var user_info
# Called when the node enters the scene tree for the first time.
func _ready():

	var new_room = load("res://Logic/Escenas/MainMenu.tscn").instance() ## SE ABRE LA OTRA INSTANCIA
	add_child(new_room)
	room = new_room
	
	
	
func change_room(c_room):
	######### ESTA FUNCION SE ENCARGA DE "CAMBIAR" LAS INTANCIAS, BORRANDO LA ANTERIOR ######### 
	room.queue_free()
	var new_room = load(c_room).instance() ## SE ABRE LA OTRA INSTANCIA
	add_child(new_room)
	room = new_room
	
	
	
func loading():
	######### QUE EL USUARIO NO PUEDA INTERACTUAR MIENTRAS ESTA CARGANDO ####
	$Node2D/Pop_loading.visible=true
	$Node2D/Pop_loading/Spr_load/AnimationPlayer.play("loading")
	
func end_loading():
	$Node2D/Pop_loading.visible=false
	$Node2D/Pop_loading/Spr_load/AnimationPlayer.stop()
	

