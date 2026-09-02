extends Node

var music_player: AudioStreamPlayer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = &"Music"
	add_child(music_player)

func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return # Ne relance pas si déjà en cours
	music_player.stream = stream
	music_player.play()

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
		
	# Lecture par SFX pour éviter coupure
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = &"SFX"
	add_child(sfx_player)
	
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)
