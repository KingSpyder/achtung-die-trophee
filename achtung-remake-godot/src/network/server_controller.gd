## Interface between local client and remote signaling server
extends Node

enum NakamaOpCode { NEW_PEER, PEER_READY, OFFER, ANSWER, CANDIDATE, MESSAGE }

const UUID_UTIL = preload("res://addons/uuid/uuid.gd")

var socket: NakamaSocket
var client: NakamaClient
var session: NakamaSession
var device_id: String


func init_server_socket() -> void:
	print("Starting nakama client...")
	client = Nakama.create_client(
		NetworkConfigs.NAKAMA.server_key,
		NetworkConfigs.NAKAMA.host,
		NetworkConfigs.NAKAMA.port,
		NetworkConfigs.NAKAMA.scheme
	)

	device_id = generate_device_id()

	# Authenticate with the Nakama server using Device Authentication
	session = await client.authenticate_device_async(device_id)
	if session.is_exception():
		print("An error occurred: %s" % session)
		return
	print("Successfully authenticated: %s" % session)

	socket = Nakama.create_socket_from(client)

	var connected: NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	print("Socket connected.")

	socket.received_match_state.connect(self._on_match_state)
	socket.received_match_presence.connect(self._on_match_presence)


func generate_device_id() -> String:
	# cannot use OS.get_device_id() because not available on web builds
	return UUID_UTIL.v4()


func _on_match_presence(p_presence: NakamaRTAPI.MatchPresenceEvent):
	for p in p_presence.joins:
		GameManager.remote_players[p.user_id] = p
		print("%s joined match" % p.user_id)
	for p in p_presence.leaves:
		GameManager.remote_players.erase(p.user_id)
		print("%s left match" % p.user_id)


func _on_match_state(match_state: NakamaRTAPI.MatchData):
	print("received match state ", match_state.op_code)
	match match_state.op_code:
		NakamaOpCode.NEW_PEER:
			var data = JSON.parse_string(match_state.data)
			print("new peer received %s" % data.peer_id)
			ClientController.new_peer_received(data.peer_id)
		NakamaOpCode.PEER_READY:
			var data = JSON.parse_string(match_state.data)
			print("peer ready received %s" % data.peer_id)
			ClientController.create_offer()
		NakamaOpCode.OFFER:
			var data = JSON.parse_string(match_state.data)
			print("offer received %s" % data.peer_id)
			ClientController.offer_received(data.peer_id, data.offer)
		NakamaOpCode.ANSWER:
			var data = JSON.parse_string(match_state.data)
			print("answer received %s" % data.peer_id)
			ClientController.answer_received(data.peer_id, data.answer)
		NakamaOpCode.CANDIDATE:
			var data = JSON.parse_string(match_state.data)
			print("candidates received %s" % data.peer_id)
			ClientController.candidate_received(data.peer_id, data.mid, data.index, data.sdp)
		NakamaOpCode.MESSAGE:
			var data = JSON.parse_string(match_state.data)
			print("received message from signaling ", data.message)
		_:
			print("Unsupported op code.")


func send_new_peer(signaling_match_id: String, peer_id: int) -> void:
	_send_signaling_msg(
		signaling_match_id,
		NakamaOpCode.NEW_PEER,
		JSON.stringify({"peer_id": peer_id, "type": NakamaOpCode.NEW_PEER})
	)


func send_peer_ready(signaling_match_id: String, peer_id: int) -> void:
	_send_signaling_msg(
		signaling_match_id,
		NakamaOpCode.PEER_READY,
		JSON.stringify({"peer_id": peer_id, "type": NakamaOpCode.PEER_READY})
	)


func send_offer(signaling_match_id: String, offer: String, peer_id: int) -> void:
	_send_signaling_msg(
		signaling_match_id,
		NakamaOpCode.OFFER,
		JSON.stringify({"peer_id": peer_id, "type": NakamaOpCode.OFFER, "offer": offer})
	)


func send_answer(signaling_match_id: String, answer: String, peer_id: int) -> void:
	_send_signaling_msg(
		signaling_match_id,
		NakamaOpCode.ANSWER,
		JSON.stringify({"peer_id": peer_id, "type": NakamaOpCode.ANSWER, "answer": answer})
	)


func send_candidate(
	signaling_match_id: String, mid: String, index: int, sdp: String, local_peer_id: int
) -> void:
	_send_signaling_msg(
		signaling_match_id,
		NakamaOpCode.CANDIDATE,
		JSON.stringify(
			{
				"peer_id": local_peer_id,
				"type": NakamaOpCode.CANDIDATE,
				"mid": mid,
				"index": index,
				"sdp": sdp
			}
		)
	)


func send_message(signaling_match_id: String, peer_id: int, message: String) -> void:
	_send_signaling_msg(
		signaling_match_id,
		NakamaOpCode.MESSAGE,
		JSON.stringify({"peer_id": peer_id, "type": NakamaOpCode.MESSAGE, "message": message})
	)


func _send_signaling_msg(signaling_match_id: String, op_code: int, data: String = "") -> void:
	print("send message type %s" % str(op_code))
	await socket.send_match_state_async(signaling_match_id, op_code, data)
