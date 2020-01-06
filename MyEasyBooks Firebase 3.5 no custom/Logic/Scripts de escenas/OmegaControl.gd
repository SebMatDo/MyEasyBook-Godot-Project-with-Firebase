extends Control

#### ESTE NODO DE CONTROL SE ENCARGARA DE CREAR Y BORRAR CUALQUIER NODO Y NUNCA SERA CAMBIADO
var room
#var admin='"Matseuu":"Co4425982"'
var users
var temp
var key
var fin=false
var testo=""
onready var ADM=$Node2D/ADM
onready var ADM2=$Node2D/ADM2
# Called when the node enters the scene tree for the first time.
func _ready():

	var new_room = load("res://MainMenu.tscn").instance() ## SE ABRE LA OTRA INSTANCIA
	add_child(new_room)
	room = new_room
	key="users"
	
	
func change_room(c_room):
	room.queue_free()
	var new_room = load(c_room).instance() ## SE ABRE LA OTRA INSTANCIA
	add_child(new_room)
	room = new_room
	
