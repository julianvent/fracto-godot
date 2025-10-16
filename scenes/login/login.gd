extends Control

func _ready():
	$HTTPRequest.request_completed.connect(_http_request_completed)
	var data = {
		"name": "Hector",
		"email": "godot@gmail.com",
		"password": "godot1234"
	}
	
	var body = JSON.new().stringify(data)
	var headers = ["Content-Type: application/json"]
	var url = "https://fracto-api.onrender.com/api/v1/auth/register"
	
	var error = $HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()

	print(response_code)
