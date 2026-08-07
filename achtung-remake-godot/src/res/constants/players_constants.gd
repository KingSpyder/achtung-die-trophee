extends Node

const FRED_NAME := "Fred"
const GREENLEE_NAME := "Greenlee"
const PINKNEY_NAME := "Pinkney"
const BLUEBELL_NAME := "Bluebell"
const WILLEM_NAME := "Willem"
const GREYDON_NAME := "Greydon"

const FRED_COLOR := Color("#fe0000")
const GREENLEE_COLOR := Color("#00fe00")
const PINKNEY_COLOR := Color("#fe00fe")
const BLUEBELL_COLOR := Color("#00fefe")
const WILLEM_COLOR := Color("#fe8000")
const GREYDON_COLOR := Color("#cbcbcb")

const FUNNY_ENDGAME_TEXT := {
	FRED_NAME: " (surprenant)",
	GREENLEE_NAME: " (comme toujours)",
	PINKNEY_NAME: " (il doit y avoir un bug)",
	BLUEBELL_NAME: " (la chance du débutant)",
	WILLEM_NAME: " (c'est qui?)",
	GREYDON_NAME: " (on le voyait pas)",
}

const PLAYER_SPEED := 90
const PLAYER_ANGULAR_SPEED := PLAYER_SPEED / 35
const GATE_OPEN_TIME := 50 / PLAYER_SPEED
const TRAIL_WIDTH := 6.0
const INITIAL_TRAIL_LENGTH := 12.0
