extends Control

var temp_ar = 0
var ar_books_created=[]
var nocreate = -1
var text = ""
var filters =[true,false,false,false] # : [0] = Nombre , [1] autor , [2] genero, [3] disponible
var libros
var actual = []
var ar_textures = {}
#### CARGO LOS NODOS COMO VARIABLES PARA QUE SEA MAS FACIL MANEJARLOS #####
onready var VBOX=$ScrollContainer/VB_container/VBoxLibros
onready var pop = get_parent().get_parent().get_node("Pop_ChargeBook")
onready var lb_nombre=pop.get_node("Book_info_total/Lb_nombre")
onready var tex_image=pop.get_node("Book_info_total/Tex_image_book")
onready var lb_autor=pop.get_node("Book_info_total/Lb_autor")
onready var lb_genero=pop.get_node("Book_info_total/Lb_genero")
onready var lb_cel=pop.get_node("Book_info_total/Lb_cel")
onready var lb_correo=pop.get_node("Book_info_total/Lb_correo")
onready var lb_creador=pop.get_node("Book_info_total/Lb_creador")
onready var lb_comentario=pop.get_node("Book_info_total/Lb_comentario")

func _on_B_lupa_pressed():
	text = $ScrollContainer/VB_container/HB_bar/L_bar.text.capitalize()
	actual=[]
	ar_textures={}
	nocreate=-1
	if text != "":
		for i in len(libros["documents"]): ### HAGO UNA LISTA DE LOS GENEROS DE TODOS LOS LIBROS Y LOS SEPARO POR LOS FILTROS
			
			var nombre=libros["documents"][i]["fields"]["nombre"]["stringValue"]
			nombre=nombre.capitalize()
			var genero = libros["documents"][i]["fields"]["genero"]["stringValue"]
			genero=genero.capitalize()
			var autor = libros["documents"][i]["fields"]["autor"]["stringValue"]
			autor=autor.capitalize()
			
			#var disponible para agregar despues

			##### LOS COMPARO Y LOS QUE SEA N SIMILARES SALDRAN A LA LUZ ####
			if filters[0]==true:
				if nombre.similarity(text) >=0.6:
					actual.append(libros["documents"][i]["fields"])

			
			if filters[1]==true:
				if autor.similarity(text) >=0.6:
					actual.append(libros["documents"][i]["fields"])
			
			if filters[2]==true:
				if genero.similarity(text) >=0.6:
					actual.append(libros["documents"][i]["fields"])
	
	else:
		for i in len(libros["documents"]):
			actual.append(libros["documents"][i]["fields"])
	
	print(actual)
	if ar_books_created != [] :
		VBOX.queue_free()
		
		VBOX=VBoxContainer.new()
		VBOX.set_alignment(BoxContainer.ALIGN_CENTER)
		$ScrollContainer/VB_container.add_child(VBOX)
		VBOX.set_h_size_flags(2)
		VBOX.set_v_size_flags(2)
		
		
	for i in len(actual):
		add_vbox(i)


func add_vbox(i):
	##### ESTA FUNCION AÑADE EL LIBRO EN MINIATURA ##### ADEMAS DE QUE MANTIENE EL ORDEN CON LA UI

	###### CONTAINER PARA CENTRAR #####
	var new_hbox = HBoxContainer.new()
	VBOX.add_child(new_hbox)
	new_hbox.set_custom_minimum_size(Vector2(275,150))
	new_hbox.set_alignment(BoxContainer.ALIGN_CENTER)
	
	#### SE CREA UN NUEVO CONTAINER CON SU TAMAÑO
	var new_vbox = VBoxContainer.new()
	new_hbox.add_child(new_vbox)
	new_vbox.set_custom_minimum_size(Vector2(150,150))

	#### Se agrega una separacion entre cada libro ####
	var split=VSplitContainer.new()
	VBOX.add_child(split)
	split.set_custom_minimum_size(Vector2(100,15))
	
	### SE AGREGA EL CONTENEDOR DE LA IMAGEN
	var texture = TextureRect.new()
	new_vbox.add_child(texture)
	texture.set_custom_minimum_size(Vector2(110,110))
	texture.set_expand(true)
	texture.set_stretch_mode(6)

	###### SE PASA EL NOMBRE DEL LIBRO A LA LABEL#######
	var label = Label.new()
	new_vbox.add_child(label)
	label.set_self_modulate(Color(0, 0, 0))
	label.text=actual[i]["nombre"]["stringValue"].capitalize()
	
	nocreate+=1
	### SE AGREGA UN BOTON Y SE LE MANDA EL NUMERO DE LIBRO QUE ES ###
	var button = load("res://Logic/Escenas/ButtonList.tscn").instance()
	texture.add_child(button)
	button.set_custom_minimum_size(Vector2(110,110))
	button.set_position(Vector2(25,0))
	button.creator=self
	button.ar_number=nocreate

	
	var httpp = load("res://Logic/Escenas/HTTPRequest_Multi.tscn").instance()
	texture.add_child(httpp)
	var pat = actual[i]["imagen"]["stringValue"]
	pat= pat.split(",") # Convertir a ARRAY
	
	###### SE DESCARGA LA TOKEN DE LA IMAGEN ######
	httpp.get_document_storage("/"+pat[0])
	yield(httpp,"request_completed")
	var meta_info=parse_json(httpp.temp_body.get_string_from_ascii())
	var token= meta_info["downloadTokens"]
	
	#### SE CREA UNA NUEVA URL CON EL TOKEN Y SE DESCARGA LA IMAGEN EN FORMATO POOL BYTE ARRAY ####
	var new_url = "/" + pat[0] + "?alt=media&token=" + token
	httpp.get_document_storage(new_url)
	yield(httpp,"request_completed")
	var pool_up = httpp.temp_body
	
	#### SE CARGA LA IMAGEN ####
	#### SE CREA UN CONTENEDOR Y SE CREA LA IMAGEN CON LA INFORMACION DE LA IMAGEN + SU TEXTURA EN FORMATO BINARIO
	var image = Image.new()
	image.create_from_data(int(pat[1]),int(pat[2]),false,int(pat[3]),pool_up)
	var texture_img = ImageTexture.new()
	texture_img.create_from_image(image)
	##### SE GUARDA EL NOMBRE DE LA TEXTURA PARA SER REUSADA SI ES NECESARIO Y SE PASA A LA MINIATURA DEL LIBRO YA CREADO ####
	texture.texture=texture_img
	ar_textures[actual[i]["nombre"]["stringValue"]] = texture_img

	
func charge_book():
	##### ESTA FUNCION CARGA EL LIBRO EN PANTALLA COMPLETA OCN MAS DATOS ####
	if not ar_textures.has(actual[temp_ar]["nombre"]["stringValue"]):## SI TODAVIA NO SE HA CARGADO LA IMAGEN, NO HAGA NADA
		return
	
	pop.visible=true #####HACE VISIBLE LA PANTALLA COMPLETA DEL LIBRO Y CARGA LOS DATOS A LA LABEL, LOS DATOS SON LOS GUARDADOS EN EL ARRAY
	lb_nombre.text= "Nombre: " +actual[temp_ar]["nombre"]["stringValue"].capitalize()
	lb_autor.text= "Autor: " + actual[temp_ar]["autor"]["stringValue"].capitalize()
	lb_genero.text= "Genero: " + actual[temp_ar]["genero"]["stringValue"].capitalize()
	lb_comentario.text=" Informacion: " + actual[temp_ar]["info"]["stringValue"].capitalize()
	lb_cel.text="Celular: " + actual[temp_ar]["celular"]["stringValue"].capitalize()
	lb_correo.text="Correo: " + actual[temp_ar]["correo"]["stringValue"].capitalize()
	lb_creador.text="Creador: " + actual[temp_ar]["creador"]["stringValue"].capitalize()
	tex_image.texture=ar_textures[temp_ar]
	
	pop.visible=true
	get_parent().visible=false
	

func _on_chek1_pressed():
	filters [0] = !filters[0]

func _on_chek2_pressed():
	filters [1] = !filters[1]

func _on_chek3_pressed():
	filters [2] = !filters[2]

func _on_chek4_button_down():
	filters [3] = !filters[3]
