extends Control

###### INICIALIZR VARIABLES ##########
onready var VBOX= $ScrollContainer/VBoxContainer
var temp_info : Dictionary
onready var explor= get_parent().get_parent()
signal end_load
var ar_books : Array
var nocreate : int = -1
var ar_books_created :Array
var temp_ar : int
var ar_textures =[]
onready var pop = get_parent().get_parent().get_node("Pop_ChargeBook")
onready var lb_nombre=pop.get_node("Book_info_total/Lb_nombre")
onready var tex_image=pop.get_node("Book_info_total/Tex_image_book")
onready var lb_autor=pop.get_node("Book_info_total/Lb_autor")
onready var lb_genero=pop.get_node("Book_info_total/Lb_genero")
onready var lb_cel=pop.get_node("Book_info_total/Lb_cel")
onready var lb_correo=pop.get_node("Book_info_total/Lb_correo")
onready var lb_creador=pop.get_node("Book_info_total/Lb_creador")
onready var lb_comentario=pop.get_node("Book_info_total/Lb_comentario")




func add_vbox():
	##### ESTA FUNCION AÑADE EL LIBRO EN MINIATURA ##### ADEMAS DE QUE MANTIENE EL ORDEN CON LA UI

	var book= { ## SE CREA UN DICCIONARIO CON EL CONTENEDOR, LA IMAGEN Y EL NOMBRE DEL LIBRO
		"object":"",
		"texture":"",
		"button":"",
		"label":""
	}
	#### SE CREA UN NUEVO CONTAINER CON SU TAMAÑO
	var new_vbox = HBoxContainer.new()
	VBOX.add_child(new_vbox)
	new_vbox.set_custom_minimum_size(Vector2(200,200))
	### SE AGREGA EL CONTENEDOR DE LA IMAGEN
	var texture = TextureRect.new()
	new_vbox.add_child(texture)
	texture.set_custom_minimum_size(Vector2(140,220))
	texture.set_expand(true)
	texture.set_stretch_mode(1)
	texture.set_size(Vector2(140,220))
	
	nocreate+=1
	### SE AGREGA UN BOTON Y SE LE MANDA EL NUMERO DE LIBRO QUE ES ###
	var button = load("res://Logic/Escenas/ButtonList.tscn").instance()
	texture.add_child(button)
	button.set_custom_minimum_size(Vector2(110,100))
	button.set_size(Vector2(110,100))
	button.rect_position.x+=15
	button.rect_position.y+=45
	button.creator=self
	button.ar_number=nocreate

	###### SE PASA EL NOMBRE DEL LIBRO A LA LABEL#######
	var label = Label.new()
	texture.add_child(label)
	label._set_position(Vector2(25,200))
	label.set_self_modulate(Color(0, 0, 0))
	
	###### SE AGREGA AL DICCIONARIO LO QUE SE ACABÓ DE CREAR Y SE GUARDA EN UN ARRAY ######
	book.object=new_vbox
	book.texture=texture
	book.button=button
	book.label=label
	ar_books_created.append(book)
	
	
func load_book():
	###### ESTA FUNCION SE ENCARGA DE PASAR LA INFORMACION DEL LIBRO ####
	
	##### SE GUARDA LA INFORMACION DE LIBRO EN UN ARRAY ####
	ar_books.append(temp_info)
	#### SE CREAN LOS CONTENEDORES ####
	add_vbox()

	######## SE PASA LA INFORMACION A EL CONTENEDOR
	ar_books_created[nocreate]["label"].text=temp_info["nombre"]["stringValue"]
	
	##### SE CARGA LA INFORMACION DE LA IMAGEN ####
	var pat = temp_info["imagen"]["stringValue"]
	pat= pat.split(",") # Convertir a ARRAY
	
	###### SE DESCARGA LA TOKEN DE LA IMAGEN ######
	Firestorage.get_document_storage("/"+pat[0])
	yield(Firestorage.http,"request_completed")
	var meta_info=parse_json(Firestorage.temp_body.get_string_from_ascii())
	print(meta_info)
	var token= meta_info["downloadTokens"]
	
	#### SE CREA UNA NUEVA URL CON EL TOKEN Y SE DESCARGA LA IMAGEN EN FORMATO POOL BYTE ARRAY ####
	var new_url = "/" + pat[0] + "?alt=media&token=" + token
	Firestorage.get_document_storage(new_url)
	yield(Firestorage.http,"request_completed")
	var pool_up = Firestorage.temp_body
	
	#### SE CARGA LA IMAGEN ####
	#### SE CREA UN CONTENEDOR Y SE CREA LA IMAGEN CON LA INFORMACION DE LA IMAGEN + SU TEXTURA EN FORMATO BINARIO
	var image = Image.new()
	image.create_from_data(int(pat[1]),int(pat[2]),false,int(pat[3]),pool_up)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	##### SE GUARDA EL NOMBRE DE LA TEXTURA PARA SER REUSADA SI ES NECESARIO Y SE PASA A LA MINIATURA DEL LIBRO YA CREADO ####
	ar_books_created[nocreate]["texture"].texture=texture
	ar_textures.append(texture)
	emit_signal("end_load")
	
func charge_book():
	
	##### ESTA FUNCION CARGA EL LIBRO EN PANTALLA COMPLETA OCN MAS DATOS ####
	if temp_ar>len(ar_textures)-1: ##### SI TODAVIA NO SE HA CARGADO LA IMAGEN, NO HAGA NADA
		return
	
	pop.visible=true #####HACE VISIBLE LA PANTALLA COMPLETA DEL LIBRO Y CARGA LOS DATOS A LA LABEL, LOS DATOS SON LOS GUARDADOS EN EL ARRAY
	lb_nombre.text= "Nombre: " +ar_books[temp_ar]["nombre"]["stringValue"]
	lb_autor.text= "Autor: " + ar_books[temp_ar]["autor"]["stringValue"]
	lb_genero.text= "Genero: " + ar_books[temp_ar]["genero"]["stringValue"]
	lb_comentario.text=" Informacion: " + ar_books[temp_ar]["info"]["stringValue"]
	lb_cel.text="Celular: " + ar_books[temp_ar]["celular"]["stringValue"]
	lb_correo.text="Correo: " + ar_books[temp_ar]["correo"]["stringValue"]
	lb_creador.text="Creador: " + ar_books[temp_ar]["creador"]["stringValue"]
	tex_image.texture=ar_textures[temp_ar]
	
