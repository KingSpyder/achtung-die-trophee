extends Node

# Interface between local client and remote signaling server

const uuid_util = preload('res://addons/uuid/uuid.gd')

enum NAKAMA_OP_CODE {
	NEW_PEER,
	PEER_READY,
	OFFER,
	ANSWER,
	CANDIDATE,
	MESSAGE
}

var socket : NakamaSocket
var client : NakamaClient
var session : NakamaSession
var device_id : String

func init_server_socket() -> void:
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

	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	print("Socket connected.")
	
	socket.received_match_state.connect(self._on_match_state)
	socket.received_match_presence.connect(self._on_match_presence)

func generate_device_id() -> String:
	# cannot use OS.get_device_id() because not available on web builds
	return uuid_util.v4()
	
func _on_match_presence(p_presence : NakamaRTAPI.MatchPresenceEvent):
	for p in p_presence.joins:
		GameManager.remote_players[p.user_id] = p
		print("%s joined match" % p.user_id)
	for p in p_presence.leaves:
		GameManager.remote_players.erase(p.user_id)
		print("%s left match" % p.user_id)

func _on_match_state(match_state : NakamaRTAPI.MatchData):
	print('received match state ', match_state.op_code)
	match match_state.op_code:
		NAKAMA_OP_CODE.NEW_PEER:
			var data = JSON.parse_string(match_state.data)
			print("new peer received %s" % data.peer_id)
			ClientController.new_peer_received(data.peer_id)
		NAKAMA_OP_CODE.PEER_READY:
			var data = JSON.parse_string(match_state.data)
			print("peer ready received %s" % data.peer_id)
			ClientController.create_offer()
		NAKAMA_OP_CODE.OFFER:
			var data = JSON.parse_string(match_state.data)
			print("offer received %s" % data.peer_id)
			ClientController.offer_received(data.peer_id, data.offer)
		NAKAMA_OP_CODE.ANSWER:
			var data = JSON.parse_string(match_state.data)
			print("answer received %s" % data.peer_id)
			ClientController.answer_received(data.peer_id, data.answer)
		NAKAMA_OP_CODE.CANDIDATE:
			var data = JSON.parse_string(match_state.data)
			print("candidates received %s" % data.peer_id)
			ClientController.candidate_received(data.peer_id, data.mid, data.index, data.sdp)
		NAKAMA_OP_CODE.MESSAGE:
			var data = JSON.parse_string(match_state.data)
			print("received message from signaling ", data.message)
		_:
			print("Unsupported op code.")

func send_new_peer(signaling_match_id: String, peer_id: int) -> void :
	_send_signaling_msg(signaling_match_id, NAKAMA_OP_CODE.NEW_PEER, JSON.stringify({
		"peer_id": peer_id,
		"type": NAKAMA_OP_CODE.NEW_PEER
	}))
	
func send_peer_ready(signaling_match_id: String, peer_id: int) -> void :
	_send_signaling_msg(signaling_match_id, NAKAMA_OP_CODE.PEER_READY, JSON.stringify({
		"peer_id": peer_id,
		"type": NAKAMA_OP_CODE.PEER_READY
	}))

func send_offer(signaling_match_id: String, offer: String, peer_id: int) -> void:
	_send_signaling_msg(signaling_match_id, NAKAMA_OP_CODE.OFFER, JSON.stringify({
		"peer_id": peer_id,
		"type": NAKAMA_OP_CODE.OFFER,
		"offer": offer
	}))

func send_answer(signaling_match_id: String, answer: String, peer_id: int) -> void:
	_send_signaling_msg(signaling_match_id, NAKAMA_OP_CODE.ANSWER, JSON.stringify({
		"peer_id": peer_id,
		"type": NAKAMA_OP_CODE.ANSWER,
		"answer": answer
	}))

func send_candidate(signaling_match_id: String, mid: String, index: int, sdp: String, local_peer_id: int) -> void:
	_send_signaling_msg(signaling_match_id, NAKAMA_OP_CODE.CANDIDATE, JSON.stringify({
		"peer_id": local_peer_id,
		"type": NAKAMA_OP_CODE.CANDIDATE,
		"mid": mid,
		"index": index,
		"sdp": sdp
	}))
	
func send_message(signaling_match_id: String, peer_id: int, message: String) -> void:
	_send_signaling_msg(signaling_match_id, NAKAMA_OP_CODE.MESSAGE, JSON.stringify({
		"peer_id": peer_id,
		"type": NAKAMA_OP_CODE.MESSAGE,
		"message": message
	}))
	
func _send_signaling_msg(signaling_match_id: String, op_code: int, data: String = "") -> void:
	print("send message type %s" % str(op_code))
	await socket.send_match_state_async(signaling_match_id, op_code, data)
	
	
