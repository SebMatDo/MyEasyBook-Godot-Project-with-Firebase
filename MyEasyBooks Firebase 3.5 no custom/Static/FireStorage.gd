extends Node
const STORAGE_URL = "https://firebasestorage.googleapis.com/v0/b/myeasybookprueba.appspot.com/o"
const UPLOAD_URL = "?uploadType=media&name="
var httpc: HTTPClient
var http : HTTPRequest
var temp_body
var temp
var err = 0
const POSTING_URL="/v0/b/myeasybookprueba.appspot.com/o"
# [0] = result
# [1] = response_code
# [2] = headers


#	else:
#		var temp_body = body
#		temp_array_request=[temp_result,temp_response_code,temp_headers,temp_bod#y]
	#	print(result, response_code, headers, body)

func _ready():
	httpc=HTTPClient.new()
	http=HTTPRequest.new()
	add_child(http)
	http.connect("request_completed",self,"_on_HTTPRequest_request_completed")
	err = httpc.connect_to_host("https://firebasestorage.googleapis.com",-1)
	assert(err == OK)
	while httpc.get_status() == HTTPClient.STATUS_CONNECTING or httpc.get_status() == HTTPClient.STATUS_RESOLVING:
		httpc.poll()
		print("Connecting...")
		OS.delay_msec(500)
	print("Connected")
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	
	var temp_result = result
	var temp_response_code = response_code
	var temp_headers = headers
	temp_body = body
	temp = [temp_result, temp_response_code, temp_headers]
	
func get_document_storage (path : String) -> void:
	var url := STORAGE_URL + path
	print(url)
	http.request (url, _get_requested_headers(), false, HTTPClient.METHOD_GET )
	
func save_document_storage( path : String, fields) -> void:
	var url := POSTING_URL+ UPLOAD_URL + path
	httpc.request_raw (httpc.METHOD_POST,url, _get_requested_headers(), fields)
		
func _get_requested_headers():
	return PoolStringArray ([
#		"Content-Type: image/png",
		"Authorization: Bearer %s" % Firebase.user_info.token
	])
