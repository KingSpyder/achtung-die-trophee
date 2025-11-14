extends Node

@onready var socket = Nakama.create_socket_from(client)

func _ready():
	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	print("Socket connected.")
