extends Node

# Local client manager to init match and connections between 

const HOST_PEER_ID = 1

var signaling_match: NakamaRTAPI.Match

var rtc_mp = WebRTCMultiplayerPeer.new()
	
func _on_host_button_down() -> void:
	create_match()

func _on_join_button_down(match_code_input: LineEdit) -> void:
	join_match(match_code_input)
	
func _on_leave_button_down() -> void:
	leave_match()

func create_match() -> void:
	var match_code = generate_match_code()
	signaling_match = await ServerController.socket.create_match_async(match_code)
	if signaling_match.is_exception():
		print("An error occurred: %s" % signaling_match)
		return
	rtc_mp.create_server()
	
	MultiplayerController.map_webrtc_multiplayer(rtc_mp)
	
	print("New match with id %s from %s with %s people in" % [signaling_match.match_id, match_code, signaling_match.presences.size()])
	

func join_match(match_code_input: LineEdit) -> void:
	var match_code = match_code_input.text
	signaling_match = await ServerController.socket.create_match_async(match_code)
	if signaling_match.is_exception():
		print("An error occurred: %s" % signaling_match)
		return

	if signaling_match.presences.size() < 1:
		print("no match %s found" % match_code)
		var result = await ServerController.socket.leave_match_async(signaling_match.match_id)
		if result.is_exception():
			print("Error leaving match: %s" % result)
		return
		
	var peer_id = generate_peer_id()

	rtc_mp.create_client(peer_id)
	
	MultiplayerController.map_webrtc_multiplayer(rtc_mp)
	
#	# The host will always have 1 as a peer_id
	create_peer(1)
	print("joined with id %s from %s with %s people in" % [signaling_match.match_id, match_code, signaling_match.presences.size()])

func leave_match() -> void:
	if(signaling_match) :
		var result = await ServerController.socket.leave_match_async(signaling_match.match_id)
		if result.is_exception():
			print("Error leaving match: %s" % result)
		signaling_match = null
		return

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
	
func create_peer(peer_id: int) -> void :
	var peer = WebRTCPeerConnection.new()
	
	peer.initialize({ "IceServers": NetworkConfigs.IceServers })
	
	var local_peer_id = rtc_mp.get_unique_id()
	
	peer.ice_candidate_created.connect(_new_ice_candidate.bind(local_peer_id))
	peer.session_description_created.connect(_offer_created.bind(peer_id))
	
	# Each client send an offer to the host to establish webrtc connexion
	if(peer_id < local_peer_id) :
		rtc_mp.add_peer(peer, peer_id)
		print("added host peer")
		ServerController.send_new_peer(signaling_match.match_id, local_peer_id)
	else :
		rtc_mp.add_peer(peer, peer_id)
		
func new_peer_received(peer_id) -> void:
	create_peer(peer_id)
	ServerController.send_peer_ready(signaling_match.match_id, peer_id)
	
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
	if type == "offer": ServerController.send_offer(signaling_match.match_id, data, rtc_mp.get_unique_id())
	else: ServerController.send_answer(signaling_match.match_id, data, peer_id)
	
func offer_received(peer_id: int, offer: String) -> void:
	print("Got offer from peer_id: %d" % peer_id)
	rtc_mp.get_peer(peer_id).connection.set_remote_description("offer", offer)

func answer_received(peer_id: int, answer: String) -> void:
	print("Got answer for: %d" % peer_id)
	if rtc_mp.has_peer(HOST_PEER_ID):
		rtc_mp.get_peer(HOST_PEER_ID).connection.set_remote_description("answer", answer)
		
func _new_ice_candidate(mid: String, index: int, sdp: String, local_peer_id: int) -> void:
	ServerController.send_candidate(signaling_match.match_id, mid, index, sdp, local_peer_id)
	
func candidate_received(peer_id: int, mid: String, index: int, sdp: String) -> void:
	if rtc_mp.has_peer(peer_id):
		rtc_mp.get_peer(peer_id).connection.add_ice_candidate(mid, index, sdp)
		
func _on_send_message_button_down() -> void:
	ServerController.send_message(signaling_match.match_id, rtc_mp.get_unique_id(), "Salut à tous !!")
