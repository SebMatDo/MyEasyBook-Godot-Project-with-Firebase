extends Node
## API DOCUMENTACION ##
## https://firebase.google.com/docs/firestore/use-rest-api ##
## ESTE SCRIPT ES Responsable de comunicarse con firebase ##
## INICIALIZACION DE VARIABLES 							"###
const API_KEY := "AIzaSyDKe8QIS8VI414Ho0150wVLXNlg6hIMqVY"
const PROJECT_ID := "myeasybookprueba"
const REGISTER_URL:= "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
const LOGIN_URL:="https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % API_KEY
const FIRESTORE_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" %PROJECT_ID
var user_info := {}
var http: HTTPRequest
onready var Omega = get_node("/root/OmegaControl") ### PARA CONECTASE MAS FACIL AL NODO QUE CONTROLA LAS INSTANCIAS ####

var temp_array_request 
# [0] = result
# [1] = response_code
# [2] = headers
# [3] = body


func _ready():
	### CREAR Y CONECTAR EL NODO HTTPREQUEST ####
	http=HTTPRequest.new()
	add_child(http)
	http.connect("request_completed",self,"_on_HTTPRequest_request_completed")
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	###### SE OBTIENE LA RESPUESTA DEL SERVIDOR Y SE GUARDA EN UN ARRAY TEMPORAL QUE PUEDE SER ACCEDIDO POR OTROS NODOS ######
	var temp_result = result
	var temp_response_code = response_code
	var temp_headers = headers
	var temp_body = parse_json(body.get_string_from_ascii())
	temp_array_request=[temp_result,temp_response_code,temp_headers,temp_body]
	Omega.end_loading()
	
func _get_user_info(result: Array) -> Dictionary:
	### ESTA FUNCION SE ENCARGA DE DEVOLVERNOS EL ID Y LA CONTRASEÑA UNICA DE LA CUENTA DE LA PERSONA QUE ESTA USANDO LA APP ####
	
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	return {
		"token" : result_body.idToken,
		"id" : result_body.localId
		}
	### El result [] es un array del http request
	## [0] = resultado , [1] =respuesta del server, [2] = headers , [3] = body

func _get_requested_headers() -> PoolStringArray:
	#### ENVIA AL SERVIDOR EL TIPO DE CONTENIDO, QUE ES UN  JSON Y LE ENVIA LA TOKEN DE AUTORIZACION #######
	return PoolStringArray ([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % user_info.token
	])

func register(email:String, password: String) -> void:
	##### SE CREA UN DICCIONARIO CON EL CORREO Y LA CONTRASEÑA SEGUN ESTANDARES DE FIREBASE ######
	var body:= {
		"email" : email,
		"password" : password,
		
		}
		
	####### SE CREA LA PETICION AL SERVIDOR CON LA URL ESPICIFACADA EN LA API, SIN HEADERS Y ENVIANDO LA INFO #####
	
	http.request(REGISTER_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	### HTTP METHOD POST SIGNIFICA QUE ESTOY ENVIANDO INFORMACION ##
	### convertimos el body en un diccionario porque eso es lo que el servidor espera ##
	var result:= yield(http,"request_completed") as Array 
	## respuesta### Esto significa que solo obtendremos la respuesta cuando 
	## El servidor la entrege segun la velocidad de internet
	if result[1]==200: ## Si el resultado es un OK
		user_info = _get_user_info(result)
		
func login (email:String, password: String) -> void:
	#BASICAMENTE LO MISMO QUE EL REGISTRO, PERO ENVIANDO OTRA INFORMACION ### 
	var body:= {
		"email" : email,
		"password" : password,
		"returnSecureToken" : true
		}
	http.request(LOGIN_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(http,"request_completed") as Array 
	if result[1] == 200: ## Si el resultado es un OK
		user_info = _get_user_info(result)

func save_document( path : String, fields : Dictionary) -> void:
	### ESTE SE USA PARA ENVIAR LOS JSON CON LOS DATOS, SE CREA UN DICCIONARIO PORQUE ESO ES LO QUE ESPERA FIREBASE, VEASE API ####
	### EL PATH ES EL NOMBRE DE LA COLECCION  #####
	var document := {"fields" : fields}
	var body := to_json(document)
	var url := FIRESTORE_URL + path
	http.request (url, _get_requested_headers(), false, HTTPClient.METHOD_POST, body )
	
func get_document (path : String) -> void:
	### SIMPLEMENTE HACE UNA PETICION AL SERVIDOR, CUANDO CONTESTA TODO SE GUARDA EN EL ARRAY TEMPORAL, VEASE: _ON_HTTP_REQUEST_COMPLETED
	var url := FIRESTORE_URL + path
	http.request (url, _get_requested_headers(), false, HTTPClient.METHOD_GET )

func update_document (path : String, fields : Dictionary) -> void:
	### ES COMO EL POST, PERO PARA ACTUALIZAR UN ARCHIVO YA EXISTENTE ##
	var document := {"fields" : fields }
	var body := to_json(document)
	var url := FIRESTORE_URL + path
	http.request(url, _get_requested_headers(), false, HTTPClient.METHOD_PATCH, body)
	
func delete_document (path : String) -> void:
	## BORRA UNH DOCUMENTO EXISTENTE ##
	var url := FIRESTORE_URL + path
	http.request(url, _get_requested_headers(), false, HTTPClient.METHOD_DELETE)

