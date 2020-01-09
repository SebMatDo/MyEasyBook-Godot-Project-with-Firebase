extends Control

##############  	INICIALIZAR VARIABLES ##################### 
var actual
var libros
var temp_info
onready var pop=$PopUPGenero/GenrePopUp

func _ready():
	
	
	######### DESCARGA LA INFORMACIÓN DEL USUARIO Y LA GUARDA ####
	if Firebase.Omega.user_info == null:
		Firebase.get_document("users/%s" % Firebase.user_info.id)
		Firebase.Omega.loading()
		yield(Firebase.http,"request_completed")
		Firebase.Omega.user_info=Firebase.temp_array_request[3]
	
	################## GUARDA LA INFORMACIÓN DE TODOS LOS LIBROS ##############
	Firebase.get_document("Books")
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	libros=Firebase.temp_array_request[3]
	###### LLAMO LA CANTIDAD ACTUAL PARA SABER CUANTOS LIBROS HAY #########
	Firebase.get_document("Cantidad/cantidad_actual") ## LLAMO LA CANTIDAD ACTUAL
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	actual = Firebase.temp_array_request[3]["fields"]["cantidad_actual"]["integerValue"]
	actual = int(actual)
	

func _on_B_explorar_button_down():
	############# SI SE LE VUELVE A DAR A EXPLORAR, SE VA A LA PARTE SUPERIOR 
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
	
	pop.get_node("Lb_Genre").text="Ficción y literatura" ### NOMBRO EL GENERO
	if pop.ar_books == []: ## SI LA LISTA DE LIBROS ESTA VACIA: , ESTO SE HACE PARA QUE NO SE CARGUE SIEMPRE QUE SE ABRA
		for i in actual: ### HAGO UNA LISTA DE LOS GENEROS DE TODOS LOS LIBROS
			var genero=libros["documents"][i]["fields"]["genero"]["stringValue"]
			genero=genero.capitalize()
			
			##### LOS COMPARO Y LOS QUE SEA N SIMILARES SALDRAN A LA LUZ ####
			if  genero.similarity("Ficcion") >=0.5 or  genero.similarity("Literatura") >=0.5 :
				pop.temp_info=libros["documents"][i]["fields"] ### LE PASO LA INFO DE CADA LIBRO ENVIADO 
				pop.load_book() ## SE CARGA EL LIBRO
				yield(pop,"end_load") ## ESPERA A QUE SE CARGUE EL LIBRO Y COMIENZA A HACER LA OTRA CARGA
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
	$Pop_ChargeBook.visible=false


func _on_B_search_button_down():
	$PopUP_Search.visible=true
	$PopUP_Search/Control_search.libros=libros


func _on_B_close_button_down():
	$PopUP_Search.visible=false
