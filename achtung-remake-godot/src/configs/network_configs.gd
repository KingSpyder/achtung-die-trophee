extends Node

const Nakama := {
	"server_key": "defaultkey",
	"host": "achtung-die-trophee-nakama.duckdns.org",
	"port": 443,
	"scheme": "https"
}

const IceServers := [
	  {
		"urls": "stun:stun.relay.metered.ca:80",
	  },
	  {
		"urls": "turn:global.relay.metered.ca:80",
		"username": "f8e111a24e15dabf1a6aac65",
		"credential": "9ptyvLiqd9Tc/hBl",
	  },
	  {
		"urls": "turn:global.relay.metered.ca:80?transport=tcp",
		"username": "f8e111a24e15dabf1a6aac65",
		"credential": "9ptyvLiqd9Tc/hBl",
	  },
	  {
		"urls": "turn:global.relay.metered.ca:443",
		"username": "f8e111a24e15dabf1a6aac65",
		"credential": "9ptyvLiqd9Tc/hBl",
	  },
	  {
		"urls": "turns:global.relay.metered.ca:443?transport=tcp",
		"username": "f8e111a24e15dabf1a6aac65",
		"credential": "9ptyvLiqd9Tc/hBl",
	  },
	]
