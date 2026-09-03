## Representation of the power-up token in the game world.
## Responsible for detecting when a player collects the token and emitting a signal.
class_name PowerUpToken
extends Area2D

signal collected(token: PowerUpToken, collector: PlayerScript)

const PowerUpDefinitionScript = preload("res://src/powerup/powerup_definition.gd")
const PlayerScript = preload("res://src/player/player.gd")
const PhysicsLayersScript = preload("res://src/configs/physics_layers.gd")

var _presence_player: AudioStreamPlayer = null

@export var definition: PowerUpDefinitionScript:
	set(value):
		definition = value
		_update_visuals()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_layer = 1 << PhysicsLayersScript.POWERUP_TOKEN_BIT
	collision_layer = 0
	collision_mask = 1 << PhysicsLayersScript.POWERUP_TOKEN_BIT
	_update_visuals()
	_setup_proximity_audio()

func _process(_delta: float) -> void:
	if _presence_player != null and _presence_player.playing:
		_update_proximity_volume()

func _update_visuals() -> void:
	if not is_node_ready():
		return
	if definition == null:
		return
	if definition.token_texture != null:
		$TokenSprite.texture = definition.token_texture
		if $CollisionShape2D.shape is CircleShape2D:
			var radius = ($CollisionShape2D.shape as CircleShape2D).radius
			$TokenSprite.scale = Vector2.ONE * (radius * 2) / definition.token_texture.get_size().x
	else:
		$TokenSprite.self_modulate = definition.token_color


func _on_body_entered(body: Node) -> void:
	if definition == null:
		return
	var player := body as PlayerScript
	if player == null:
		return
	collected.emit(self, player)
	
func _setup_proximity_audio() -> void:
	if definition == null or not "is_present_music" in definition or definition.get("is_present_music") == null:
		return

	var stream: AudioStream = definition.is_present_music
	if stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
		stream.loop = true
		stream.loop_offset = 7.0
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = int(7.0 * stream.mix_rate)

	_presence_player = AudioStreamPlayer.new()
	_presence_player.stream = stream
	_presence_player.bus = &"Trophee"
	add_child(_presence_player)
	_presence_player.play(4.0) # On commence à 4s


func _update_proximity_volume() -> void:
	if _presence_player == null:
		return

	if GameManager.players_alive.is_empty():
		_presence_player.volume_db = -80.0
		return

	var min_distance := INF
	for player in GameManager.players_alive:
		if is_instance_valid(player):
			var dist := global_position.distance_to(player.global_position)
			if dist < min_distance:
				min_distance = dist
	var min_d: float = definition.get("presence_min_distance")
	var max_d: float = definition.get("presence_max_distance")
	
	var factor := clampf(1.0 - ((min_distance - min_d) / (max_d - min_d)), 0.5, 1.0)
	_presence_player.volume_db = linear_to_db(factor)
