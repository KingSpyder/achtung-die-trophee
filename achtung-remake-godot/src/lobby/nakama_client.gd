extends Node

enum NAKAMA_OP_CODE {
	OFFER,
	ANSWER,
	CANDIDATE,
}

var client : NakamaClient
var socket : NakamaSocket
var session : NakamaSession
var match_created : NakamaRTAPI.Match

var rtc_mp := WebRTCMultiplayerPeer.new()
var peer: WebRTCPeerConnection
#var data_channel: WebRTCDataChannel
var multiplayer_peer: WebRTCMultiplayerPeer

var is_host = false
var device_id : String

@export var match_code_input: LineEdit

# HOST NAKAMA MATCH

func _ready():
	print("Starting nakama client...")
	client = Nakama.create_client("defaultkey", "127.0.0.1", 7350)
		
	# Get the System's unique device identifier
	device_id = OS.get_unique_id() + _generate_match_code()

	# Authenticate with the Nakama server using Device Authentication
	session = await client.authenticate_device_async(device_id)
	if session.is_exception():
		print("An error occurred: %s" % session)
		return
	print("Successfully authenticated: %s" % session)
	
	socket = Nakama.create_socket_from(client)

	#var bridge = NakamaMultiplayerBridgqe.new(socket)

	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	print("Socket connected.")
	
	socket.received_match_state.connect(self._on_match_state)

	
func create_match() -> void:
	var match_code = _generate_match_code()
	match_created = await socket.create_match_async(match_code)
	if match_created.is_exception():
		print("An error occurred: %s" % match_created)
		return

	print("New match with id %s from %s with %s people in" % [match_created.match_id, match_code, match_created.presences.size()])
	
func join_match(match_code: String) -> void:
	match_created = await socket.create_match_async(match_code)
	if match_created.is_exception():
		print("An error occurred: %s" % match_created)
		return

	print("joined with id %s from %s with %s people in" % [match_created.match_id, match_code, match_created.presences.size()])

func _on_join_match_button_down() -> void:
	join_match(match_code_input.text)
	
func _on_create_match_button_down() -> void:
	create_match()

func _generate_match_code() -> String:
	const chars = "abcdefghijklmnopqrstuvwxyz0123456789"
	var output_length := 5
	var output_string := ""

	for i in range(output_length):
		output_string += chars[randi() % chars.length()]
	return output_string
	

func _on_send_message_button_down() -> void:
	_send_msg(match_created.match_id, NAKAMA_OP_CODE.CANDIDATE, JSON.stringify({
		"type": "test",
		"sdp": "testsdp"
	}))


func _send_msg(id: String, type: int, data: String = "") -> void:
	await socket.send_match_state_async(id, type, data)
	pass;
	#return ws.send_text(JSON.stringify({
		#"type": type,
		#"id": id,
		#"data": data,
	#}))

func _on_match_state(match_state : NakamaRTAPI.MatchData):
	print('received message')
	match match_state.op_code:
		NAKAMA_OP_CODE.CANDIDATE:
			# Get the updated position data
			print("message received %s" % match_state.data)
			#var position_state = JSON.parse_string(match_state.data)
			# Update the game object associated with that player
		_:
			print("Unsupported op code.")

func _new_ice_candidate(mid_name: String, index_name: int, sdp_name: String, id: int) -> void:
	send_candidate(match_created.id, mid_name, index_name, sdp_name)
	

func send_candidate(id: int, mid: String, index: int, sdp: String) -> void:
	pass
	#return _send_msg(NAKAMA_OP_CODE.CANDIDATE, id, "\n%s\n%d\n%s" % [mid, index, sdp])

# HANDLE WEBRTC MESSAGES AND CONNECTION

func create_host() -> void:
	is_host = true
	peer = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [
			{"urls": ["stun:stun.l.google.com:19302"]}
		]
	})
	
	peer.ice_candidate_created.connect(_new_ice_candidate.bind(device_id))

	# Canal de données (pour inputs)
	var data_channel = peer.create_data_channel("inputs")
	#data_channel.connect("data_received", self, "_on_data_received")

	# Quand il y a de nouveaux candidats ICE, les envoyer via signaling
	#peer_connection.connect("ice_candidate_created", self, "_on_ice_candidate")

	# Créer l'offre SDP
	#var offer = await peer_connection.create_offer()
	#await peer_connection.set_local_description(offer)
	#signaling_client.send(JSON.print({
		#"type": "offer",
		#"sdp": offer["sdp"]
	#}))

func _on_data_channel(channel: WebRTCDataChannel):
	var data_channel = channel
	#data_channel.connect("data_received", self, "_on_data_received")

func _on_data_received(channel_name, data):
	var message = data.get_string_from_utf8()
	print("Reçu: ", message)
