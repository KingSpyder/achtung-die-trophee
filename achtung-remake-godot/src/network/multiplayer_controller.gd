extends Node

# High level Multiplayer API once webrtc bridge has been made between host and client

func init_multiplayer() -> void :
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
func map_webrtc_multiplayer(rtc_mp: WebRTCMultiplayerPeer) -> void :
	multiplayer.multiplayer_peer = rtc_mp

# this get called on the host and clients
func peer_connected(id) -> void:
	print("Player Connected " + str(id))
	
# this get called on the host and clients
func peer_disconnected(id) -> void:
	print("Player Disconnected " + str(id))
	
# called only from clients
func connected_to_server() -> void:
	print("connected To Server!")

# called only from clients
func connection_failed() -> void:
	print("Couldnt Connect")
	
@rpc("any_peer")
func send_chat_message(message: String):
	print("Message reçu via RPC: ", message)

func _on_send_message_web_rtc_button_down() -> void:
	print("send message via webrtc")
	rpc("send_chat_message", "Salut tout le monde 👋")
