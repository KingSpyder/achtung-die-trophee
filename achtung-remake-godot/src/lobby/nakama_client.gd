extends Node

const uuid_util = preload('res://addons/uuid/uuid.gd')

enum NAKAMA_OP_CODE {
	NEW_PEER,
	PEER_READY,
	OFFER,
	ANSWER,
	CANDIDATE,
}

const HOST_PEER_ID = 1

var client : NakamaClient
var socket : NakamaSocket
var session : NakamaSession
var match_created : NakamaRTAPI.Match

var rtc_mp := WebRTCMultiplayerPeer.new()
var peer: WebRTCPeerConnection
#var data_channel: WebRTCDataChannel
var multiplayer_peer: WebRTCMultiplayerPeer

var connected_opponents = {}

var is_host = false
var device_id : String

@export var match_code_input: LineEdit

# HOST NAKAMA MATCH

func _ready():
	print("Starting nakama client...")
	client = Nakama.create_client("defaultkey", "127.0.0.1", 7350)
	
	device_id = generate_device_id()

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
	socket.received_match_presence.connect(self._on_match_presence)
	
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
# this get called on the server and clients
func peer_connected(id):
	print("Player Connected " + str(id))
	
# this get called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	
# called only from clients
func connected_to_server():
	print("connected To Server!")

# called only from clients
func connection_failed():
	print("Couldnt Connect")
	
func create_match() -> void:
	#var match_code = generate_match_code()
	var match_code = "AAAAA"
	match_created = await socket.create_match_async(match_code)
	if match_created.is_exception():
		print("An error occurred: %s" % match_created)
		return
	is_host = true
	rtc_mp.create_server()
	multiplayer.multiplayer_peer = rtc_mp
	print("New match with id %s from %s with %s people in" % [match_created.match_id, match_code, match_created.presences.size()])
	
func join_match(match_code: String) -> void:
	match_created = await socket.create_match_async(match_code)
	if match_created.is_exception():
		print("An error occurred: %s" % match_created)
		return

	if match_created.presences.size() < 1:
		print("no match %s found" % match_code)
		var result = await socket.leave_match_async(match_created.match_id)
		if result.is_exception():
			print("Error leaving match: %s" % result)
		return
		
	var peer_id = generate_peer_id()

	rtc_mp.create_client(peer_id)
	multiplayer.multiplayer_peer = rtc_mp
#	# The host will always have 1 as a peer_id
	create_peer(1)
	print("joined with id %s from %s with %s people in" % [match_created.match_id, match_code, match_created.presences.size()])

func _on_join_match_button_down() -> void:
	join_match(match_code_input.text)
	
func _on_create_match_button_down() -> void:
	create_match()

func generate_device_id() -> String:
	return uuid_util.v4()

func generate_match_code() -> String:
	const chars = "abcdefghijklmnopqrstuvwxyz0123456789"
	var output_length := 5
	var output_string := ""

	for i in range(output_length):
		output_string += chars[randi() % chars.length()]
	return output_string

func generate_peer_id() -> int :
	var rng = RandomNumberGenerator.new()
	const MIN_PEER_ID = 2
	const MAX_PEER_ID = 2147483647
	return rng.randi_range(MIN_PEER_ID, MAX_PEER_ID)

func _on_send_message_button_down() -> void:
	_send_signaling_msg(match_created.match_id, NAKAMA_OP_CODE.CANDIDATE, JSON.stringify({
		"type": "test",
		"sdp": "testsdp"
	}))
	
@rpc("any_peer")
func send_chat_message(message: String):
	print("Message reçu via RPC: ", message)
	
func _on_send_message_web_rtc_button_down():
	print("send message via webrtc")
	rpc("send_chat_message", "Salut tout le monde 👋")

func _send_signaling_msg(id: String, type: int, data: String = "") -> void:
	print("send message type %s" % str(type))
	await socket.send_match_state_async(id, type, data)

func _on_match_presence(p_presence : NakamaRTAPI.MatchPresenceEvent):
	for p in p_presence.joins:
		connected_opponents[p.user_id] = p
		print("%s joined match" % p.user_id)
		if(p.user_id == device_id && not is_host):
			create_peer(1)
	for p in p_presence.leaves:
		connected_opponents.erase(p.user_id)

func _on_match_state(match_state : NakamaRTAPI.MatchData):
	print('received message ', match_state.op_code)
	match match_state.op_code:
		NAKAMA_OP_CODE.NEW_PEER:
			var data = JSON.parse_string(match_state.data)
			print("new peer received %s" % data.peer_id)
			_new_peer_received(data.peer_id)
		NAKAMA_OP_CODE.PEER_READY:
			var data = JSON.parse_string(match_state.data)
			print("peer ready received %s" % data.peer_id)
			create_offer()
		NAKAMA_OP_CODE.OFFER:
			var data = JSON.parse_string(match_state.data)
			print("offer received %s" % data.peer_id)
			_offer_received(data.peer_id, data.offer)
		NAKAMA_OP_CODE.ANSWER:
			var data = JSON.parse_string(match_state.data)
			print("answer received %s" % data.peer_id)
			_answer_received(data.peer_id, data.answer)
		NAKAMA_OP_CODE.CANDIDATE:
			var data = JSON.parse_string(match_state.data)
			print("candidates received %s" % data.peer_id)
			_candidate_received(data.peer_id, data.mid, data.index, data.sdp)
		_:
			print("Unsupported op code.")


func create_peer(peer_id: int) -> void :
	peer = WebRTCPeerConnection.new()
	# Use a public STUN server for moderate NAT traversal.
	# Note that STUN cannot punch through strict NATs (such as most mobile connections),
	# in which case TURN is required. TURN generally does not have public servers available,
	# as it requires much greater resources to host (all traffic goes through
	# the TURN server, instead of only performing the initial connection).
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	
	var local_peer_id = rtc_mp.get_unique_id()
	
	peer.ice_candidate_created.connect(_new_ice_candidate.bind(peer_id))
	peer.session_description_created.connect(_offer_created.bind(peer_id))
	
	# Each client send an offer to the host to establish webrtc connexion
	if(peer_id < local_peer_id) :
		rtc_mp.add_peer(peer, peer_id)
		print("added host peer")
		send_new_peer(local_peer_id)
	else :
		rtc_mp.add_peer(peer, peer_id)

func send_new_peer(peer_id: int) -> void :
	_send_signaling_msg(match_created.match_id, NAKAMA_OP_CODE.NEW_PEER, JSON.stringify({
		"peer_id": peer_id,
		"type": NAKAMA_OP_CODE.NEW_PEER
	}))
	
func _new_peer_received(peer_id) -> void:
	create_peer(peer_id)
	send_peer_ready(peer_id)
	
func send_peer_ready(peer_id: int) -> void :
	_send_signaling_msg(match_created.match_id, NAKAMA_OP_CODE.PEER_READY, JSON.stringify({
		"peer_id": peer_id,
		"type": NAKAMA_OP_CODE.PEER_READY
	}))

func create_offer() -> void:
	print('creating offer...')
	if not rtc_mp.has_peer(HOST_PEER_ID):
		print("ERROR: no host peer")
		return
	rtc_mp.get_peer(HOST_PEER_ID).connection.create_offer()

func _offer_created(type: String, data: String, peer_id: int) -> void:
	if not rtc_mp.has_peer(peer_id):
		return
	print("%s created for peer %s" % [type, peer_id])
	rtc_mp.get_peer(peer_id).connection.set_local_description(type, data)
	if type == "offer": send_offer(data, rtc_mp.get_unique_id())
	else: send_answer(data, peer_id)

func send_offer(offer: String, peer_id: int) -> void:
	_send_signaling_msg(match_created.match_id, NAKAMA_OP_CODE.OFFER, JSON.stringify({
		"peer_id": peer_id,
		"type": NAKAMA_OP_CODE.OFFER,
		"offer": offer
	}))

func send_answer(answer: String, peer_id: int) -> void:
	_send_signaling_msg(match_created.match_id, NAKAMA_OP_CODE.ANSWER, JSON.stringify({
		"peer_id": peer_id,
		"type": NAKAMA_OP_CODE.ANSWER,
		"answer": answer
	}))

func _new_ice_candidate(mid: String, index: int, sdp: String, peer_id: int) -> void:
	send_candidate(mid, index, sdp, peer_id)
	

func send_candidate(mid: String, index: int, sdp: String, peer_id: int) -> void:
	_send_signaling_msg(match_created.match_id, NAKAMA_OP_CODE.CANDIDATE, JSON.stringify({
		"peer_id": rtc_mp.get_unique_id(),
		"type": NAKAMA_OP_CODE.CANDIDATE,
		"mid": mid,
		"index": index,
		"sdp": sdp
	}))

func _offer_received(peer_id: int, offer: String) -> void:
	print("Got offer from peer_id: %d" % peer_id)
	
	rtc_mp.get_peer(peer_id).connection.set_remote_description("offer", offer)

func _answer_received(peer_id: int, answer: String) -> void:
	print("Got answer for: %d" % peer_id)
	if rtc_mp.has_peer(HOST_PEER_ID):
		rtc_mp.get_peer(HOST_PEER_ID).connection.set_remote_description("answer", answer)

func _candidate_received(peer_id: int, mid: String, index: int, sdp: String) -> void:
	if rtc_mp.has_peer(peer_id):
		rtc_mp.get_peer(peer_id).connection.add_ice_candidate(mid, index, sdp)

#func _on_data_channel(channel: WebRTCDataChannel):
	#var data_channel = channel
	##data_channel.connect("data_received", self, "_on_data_received")
#
#func _on_data_received(channel_name, data):
	#var message = data.get_string_from_utf8()
	#print("Reçu: ", message)
	
