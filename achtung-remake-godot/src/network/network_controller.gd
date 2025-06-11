extends Control

@export var address = "127.0.0.1"
@export var port = 8910

var peer

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
func _process(delta: float):
	pass
	
# Peer id 1 is the server
func peer_connected(id):
	print("Peer Connected %s" % str(id))
	
func peer_disconnected(id):
	print("Peer Connected %s" % str(id))
	GameManager.players.erase(id)
	#Todo handle if player is erased
	
func connected_to_server():
	print("Connected to server")
	send_player_information.rpc_id(1, multiplayer.get_unique_id(), "guest" + str(multiplayer.get_unique_id()))
	
func connection_failed():
	print("Connection to server failed...")
	
@rpc("any_peer")
func send_player_information(id, name):
	if( not GameManager.players.has(id) ):
		GameManager.players[id] = {
			"id": id,
			"name": name,
			"score": 0
		}
	
	if(multiplayer.is_server()):
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].id, GameManager.players[i].name)

@rpc("any_peer", "call_local")
func start_game_online():
	var scene = load("res://src/game/gameScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()
	
@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://src/game/gameScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_down():
	start_host_server()
	
func start_host_server():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	
	if(error != OK):
		print("Server hosting creation failed: code %s" % error)
		return
		
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	print("Server host created")
	send_player_information(multiplayer.get_unique_id(), "host")
	
	
func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	
	peer.create_client(address, port)
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.multiplayer_peer = peer
	
	print("Connected to server")
	pass


func _on_start_button_down() -> void:
	start_game.rpc()
	pass # Replace with function body.


func _on_add_player_button_down() -> void:
	var playerSize = GameManager.players.size()
	var id = str(playerSize + 2)
	GameManager.players[id] = {
			"id": id,
			"name": "guest" + id,
			"score": 0
		}
	pass # Replace with function body.
