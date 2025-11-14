extends Node

@export var match_code_input: LineEdit

func _ready():
	ServerController.init_server_socket()
	MultiplayerController.init_multiplayer()
	
	var host_button = $Host
	var join_button = $Join
	var send_message_button = $SendMessage
	var send_message_rtc_button = $SendMessageWebRTC
	
	host_button.button_down.connect(ClientController._on_host_button_down)
	join_button.button_down.connect(ClientController.join_match.bind(match_code_input))
	send_message_button.button_down.connect(ClientController._on_send_message_button_down)
	send_message_rtc_button.button_down.connect(MultiplayerController._on_send_message_web_rtc_button_down)
