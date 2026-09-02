extends Node

var music_player: AudioStreamPlayer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = &"Music"
	add_child(music_player)

func play_music(stream: AudioStream, volume_factor: float=1.0) -> void:
	if music_player.stream == stream and music_player.playing:
		return # Ne relance pas si déjà en cours
	music_player.stream = stream
	music_player.volume_db = linear_to_db(volume_factor)
	music_player.play()
	
func pause_music() -> void:
	if music_player and music_player.playing:
		music_player.stream_paused = true

func resume_music() -> void:
	if music_player:
		music_player.stream_paused = false

func play_sfx(stream: AudioStream, volume_factor: float=1.0) -> AudioStreamPlayer:
	if stream == null:
		return
		
	# Lecture par SFX pour éviter coupure
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = &"SFX"
	sfx_player.volume_db = linear_to_db(volume_factor)
	add_child(sfx_player)
	
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)
	
	return sfx_player
