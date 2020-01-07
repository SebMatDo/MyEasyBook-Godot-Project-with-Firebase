extends Control


onready var VBOX= $ScrollContainer/VBoxContainer
var temp_info : Dictionary
onready var explor= get_parent().get_parent()
signal end_load
var ar_books : Array
var nocreate : int = -1
var ar_books_created :Array
var temp_ar : int
var pop
var lb_nombre
var tex_image
var lb_autor
var lb_genero
var lb_cel
var lb_correo
var lb_comentario
var lb_creador
var ar_textures =[]


func add_vbox():
	var book= {
		"object":"",
		"texture":"",
		"button":"",
		"label":""
	}
	var new_vbox = HBoxContainer.new()
	VBOX.add_child(new_vbox)
	new_vbox.set_custom_minimum_size(Vector2(200,200))
	
	var texture = TextureRect.new()
	new_vbox.add_child(texture)
	texture.set_custom_minimum_size(Vector2(140,220))
	texture.set_expand(true)
	texture.set_stretch_mode(1)
	texture.set_size(Vector2(140,220))
	
	nocreate+=1
	
	var button = load("res://Logic/Escenas/ButtonList.tscn").instance()
	texture.add_child(button)
	button.set_custom_minimum_size(Vector2(110,100))
	button.set_size(Vector2(110,100))
	button.rect_position.x+=15
	button.rect_position.y+=45
	button.creator=self
	button.ar_number=nocreate
	
	var label = Label.new()
	texture.add_child(label)
	label._set_position(Vector2(25,200))
	label.set_self_modulate(Color(0, 0, 0))
	book.object=new_vbox
	book.texture=texture
	book.button=button
	book.label=label
	ar_books_created.append(book)
	
	
func load_book():
	ar_books.append(temp_info)
	add_vbox()
	ar_books_created[nocreate]["label"].text=temp_info["nombre"]["stringValue"]
	var pat = temp_info["imagen"]["stringValue"]
	pat= pat.split(",") # Convertir a ARRAY
	Firestorage.get_document_storage("/"+pat[0])
	yield(Firestorage.http,"request_completed")
	var meta_info=parse_json(Firestorage.temp_body.get_string_from_ascii())
	print(meta_info)
	var token= meta_info["downloadTokens"]
	var new_url = "/" + pat[0] + "?alt=media&token=" + token
	Firestorage.get_document_storage(new_url)
	yield(Firestorage.http,"request_completed")
	var pool_up = Firestorage.temp_body
	var image = Image.new()
	image.create_from_data(int(pat[1]),int(pat[2]),false,int(pat[3]),pool_up)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	ar_books_created[nocreate]["texture"].texture=texture
	ar_textures.append(texture)
	emit_signal("end_load")
	
func charge_book():
	if temp_ar>len(ar_textures)-1:
		return
	pop.visible=true
	lb_nombre.text= "Nombre: " +ar_books[temp_ar]["nombre"]["stringValue"]
	lb_autor.text= "Autor: " + ar_books[temp_ar]["autor"]["stringValue"]
	lb_genero.text= "Genero: " + ar_books[temp_ar]["genero"]["stringValue"]
	lb_comentario.text=" Informacion: " + ar_books[temp_ar]["info"]["stringValue"]
	lb_cel.text="Celular: " + ar_books[temp_ar]["celular"]["stringValue"]
	lb_correo.text="Correo: " + ar_books[temp_ar]["correo"]["stringValue"]
	lb_creador.text="Creador: " + ar_books[temp_ar]["creador"]["stringValue"]
	tex_image.texture=ar_textures[temp_ar]
	
func charge_labels():
	
	lb_nombre=pop.get_node("Book_info_total/Lb_nombre")
	tex_image=pop.get_node("Book_info_total/Tex_image_book")
	lb_autor=pop.get_node("Book_info_total/Lb_autor")
	lb_genero=pop.get_node("Book_info_total/Lb_genero")
	lb_cel=pop.get_node("Book_info_total/Lb_cel")
	lb_correo=pop.get_node("Book_info_total/Lb_correo")
	lb_creador=pop.get_node("Book_info_total/Lb_creador")
	lb_comentario=pop.get_node("Book_info_total/Lb_comentario")
