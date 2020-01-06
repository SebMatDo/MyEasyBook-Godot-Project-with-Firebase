extends Control

var actual
var libros
var temp_info
onready var pop=$PopUPGenero/GenrePopUp

func _ready():
	Firebase.get_document("users/%s" % Firebase.user_info.id)
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	Firebase.Omega.user_info=Firebase.temp_array_request[3]
	
	Firebase.get_document("Books")
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")

	libros=Firebase.temp_array_request[3]
	Firebase.get_document("Cantidad/cantidad_actual") ## LLAMO LA CANTIDAD ACTUAL
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	actual = Firebase.temp_array_request[3]["fields"]["cantidad_actual"]["integerValue"]
	actual = int(actual)
	pop.pop=$PopUPGenero/Pop_ChargeBook
	pop.charge_labels()
	

func _on_B_explorar_button_down():
	$ScrollContainer.get_v_scrollbar().value=0


func _on_B_usuario_button_down():
	get_parent().change_room("res://Logic/Escenas/Usuario.tscn")

func _on_B_pedidos_button_down():
	get_parent().change_room("res://Logic/Escenas/Pedidos.tscn")

func _on_B_settings_button_down():
	get_parent().change_room("res://Logic/Escenas/Settings.tscn")

func _on_B_navigation_button_down():
	get_parent().change_room("res://Logic/Escenas/Navigation.tscn")


func _on_B_genre1_button_down():
	$PopUPGenero.visible=true
	
	pop.get_node("Lb_Genre").text="Ficción y literatura"
	if pop.ar_books == []:
		for i in actual:
			var genero=libros["documents"][i]["fields"]["genero"]["stringValue"]
			genero=genero.capitalize()
			print(genero)
			if  genero.similarity("Ficcion") >=0.5 or genero.similarity("Literatura") >=0.5 :
				pop.temp_info=libros["documents"][i]["fields"]
				pop.load_book()
				yield(pop,"end_load")
				print("cargado")


func _on_B_atras_button_down():
	$PopUPGenero.visible=false


func _on_B_upload_button_down():
	$PopUP_Upload.visible=true
	Firebase.get_document("Cantidad/cantidad_actual") ## LLAMO LA CANTIDAD ACTUAL
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	actual = Firebase.temp_array_request[3]["fields"]["cantidad_actual"]["integerValue"]
	actual = int(actual)
	$PopUP_Upload/UploadBook.numID = "Book" + str (actual+1)
	print($PopUP_Upload/UploadBook.numID)
	## Asi se llama toda la colección : Firebase.get_document("Books/")
	#yield(Firebase.http,"request_completed")
	#print(Firebase.temp_array_request[3])


func _on_B_cancel_button_down():
	$PopUP_Upload.visible=false


func _on_B_atras_charge_button_down():
	$PopUPGenero/Pop_ChargeBook.visible=false


func _on_B_prueba_button_down():
	Firebase.Omega.change_room("res://Logic/Escenas/gettear.tscn")
