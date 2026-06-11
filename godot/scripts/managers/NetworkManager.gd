extends Node
# Network Manager - Handles all communication with backend server
# UPDATED: All requests allowed (no auth required unless specified)

class_name NetworkManager

var api_url: String = "http://localhost:3000/api"
var websocket_url: String = "ws://localhost:3000"
var ws: WebSocketPeer = null
var connected: bool = false

# HTTP client
var http_client: HTTPClient = HTTPClient.new()

func _ready():
	print("[NetworkManager] Initialized - All requests enabled")
	setup_websocket()

func setup_websocket() -> void:
	"""Initialize WebSocket connection"""
	ws = WebSocketPeer.new()
	var error = ws.connect_to_url(websocket_url)
	if error != OK:
		print("[NetworkManager] WebSocket connection error: %d" % error)
		return
	print("[NetworkManager] WebSocket connecting...")

func _process(delta: float) -> void:
	if ws and ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.poll()
		var message = ws.get_message()
		if message != null:
			handle_websocket_message(message)

func handle_websocket_message(message: String) -> void:
	"""Process incoming WebSocket messages"""
	var data = JSON.parse_string(message)
	if data == null:
		return
	
	var msg_type = data.get("type", "")
	match msg_type:
		"auth_success":
			print("[NetworkManager] WebSocket authenticated")
			connected = true
		"battle_update":
			print("[NetworkManager] Battle update received")
		"multiplayer_action":
			print("[NetworkManager] Multiplayer action received")
		_:
			print("[NetworkManager] Unknown message type: %s" % msg_type)

func send_websocket_message(message: Dictionary) -> void:
	"""Send message via WebSocket"""
	if ws and ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.send_text(JSON.stringify(message))

# ============================================================================
# AUTHENTICATION ENDPOINTS
# ============================================================================

func register(username: String, email: String, password: String) -> Dictionary:
	"""Register new player"""
	var url = "%s/auth/register" % api_url
	var body = JSON.stringify({
		"username": username,
		"email": email,
		"password": password
	})
	
	var response = await post_request(url, body, false)
	if response.success and response.data.has("token"):
		return {
			"success": true,
			"token": response.data.token,
			"player": response.data.player
		}
	return {"success": false, "error": response.error}

func login(email: String, password: String) -> Dictionary:
	"""Login player"""
	var url = "%s/auth/login" % api_url
	var body = JSON.stringify({
		"email": email,
		"password": password
	})
	
	var response = await post_request(url, body, false)
	if response.success and response.data.has("token"):
		var token = response.data.token
		# Authenticate WebSocket
		send_websocket_message({
			"type": "authenticate",
			"token": token
		})
		return {
			"success": true,
			"token": token,
			"player": response.data.player
		}
	return {"success": false, "error": response.error}

# ============================================================================
# CHARACTER ENDPOINTS
# ============================================================================

func create_character(character_name: String, soul_name: String) -> Dictionary:
	"""Create new character"""
	var url = "%s/character/create" % api_url
	var body = JSON.stringify({
		"character_name": character_name,
		"soul_name": soul_name
	})
	
	var response = await post_request(url, body, false)
	if response.success:
		return {
			"success": true,
			"character": response.data.character
		}
	return {"success": false, "error": response.error}

func get_character(character_id: int) -> Dictionary:
	"""Get character details"""
	var url = "%s/character/%d" % [api_url, character_id]
	var response = await get_request(url, false)
	
	if response.success:
		return {
			"success": true,
			"character": response.data.character,
			"abilities": response.data.abilities,
			"recent_moral_choices": response.data.recent_moral_choices
		}
	return {"success": false, "error": response.error}

func get_my_characters() -> Dictionary:
	"""Get all characters for player"""
	var url = "%s/character/my-characters" % api_url
	var response = await get_request(url, false)
	
	if response.success:
		return {
			"success": true,
			"characters": response.data.characters
		}
	return {"success": false, "error": response.error}

func update_character_stats(character_id: int, stats: Dictionary) -> Dictionary:
	"""Update character stats"""
	var url = "%s/character/%d/stats" % [api_url, character_id]
	var body = JSON.stringify(stats)
	
	var response = await patch_request(url, body, false)
	if response.success:
		return {"success": true, "character": response.data.character}
	return {"success": false, "error": response.error}

# ============================================================================
# BATTLE ENDPOINTS
# ============================================================================

func start_battle(character_id: int, enemy_id: int) -> Dictionary:
	"""Start new battle"""
	var url = "%s/battle/start" % api_url
	var body = JSON.stringify({
		"characterId": character_id,
		"enemyId": enemy_id
	})
	
	var response = await post_request(url, body, false)
	if response.success:
		return {
			"success": true,
			"battle": response.data.battle
		}
	return {"success": false, "error": response.error}

func record_battle_action(battle_id: int, action_type: String, ability_id: int, damage: int) -> Dictionary:
	"""Record battle action"""
	var url = "%s/battle/%d/action" % [api_url, battle_id]
	var body = JSON.stringify({
		"action_type": action_type,
		"ability_id": ability_id,
		"damage": damage
	})
	
	var response = await post_request(url, body, false)
	if response.success:
		return {"success": true, "turn": response.data.turn}
	return {"success": false, "error": response.error}

func end_battle(battle_id: int, result: String, player_final_health: int) -> Dictionary:
	"""End battle"""
	var url = "%s/battle/%d/end" % [api_url, battle_id]
	var body = JSON.stringify({
		"battle_result": result,
		"player_final_health": player_final_health,
		"enemy_final_health": 0
	})
	
	var response = await post_request(url, body, false)
	if response.success:
		return {
			"success": true,
			"result": response.data.result,
			"rewards": response.data.rewards,
			"battle": response.data.battle
		}
	return {"success": false, "error": response.error}

func get_battle_history(character_id: int, limit: int = 10) -> Dictionary:
	"""Get battle history"""
	var url = "%s/battle/history/%d?limit=%d" % [api_url, character_id, limit]
	var response = await get_request(url, false)
	
	if response.success:
		return {
			"success": true,
			"battles": response.data.battles
		}
	return {"success": false, "error": response.error}

# ============================================================================
# QUEST ENDPOINTS
# ============================================================================

func get_available_quests(character_id: int) -> Dictionary:
	"""Get available quests"""
	var url = "%s/quest/%d/available" % [api_url, character_id]
	var response = await get_request(url, false)
	
	if response.success:
		return {
			"success": true,
			"quests": response.data.quests
		}
	return {"success": false, "error": response.error}

func start_quest(quest_id: int) -> Dictionary:
	"""Start quest"""
	var url = "%s/quest/%d/start" % [api_url, quest_id]
	var response = await post_request(url, "", false)
	
	if response.success:
		return {
			"success": true,
			"quest": response.data.quest
		}
	return {"success": false, "error": response.error}

func complete_quest(quest_id: int) -> Dictionary:
	"""Complete quest"""
	var url = "%s/quest/%d/complete" % [api_url, quest_id]
	var response = await post_request(url, "", false)
	
	if response.success:
		return {
			"success": true,
			"quest": response.data.quest,
			"rewards": response.data.rewards
		}
	return {"success": false, "error": response.error}

# ============================================================================
# MULTIPLAYER ENDPOINTS
# ============================================================================

func create_multiplayer_session(session_name: String, session_type: String, max_players: int) -> Dictionary:
	"""Create multiplayer session"""
	var url = "%s/multiplayer/session/create" % api_url
	var body = JSON.stringify({
		"session_name": session_name,
		"session_type": session_type,
		"max_players": max_players
	})
	
	var response = await post_request(url, body, false)
	if response.success:
		return {"success": true, "session": response.data.session}
	return {"success": false, "error": response.error}

func join_multiplayer_session(session_id: int, character_id: int) -> Dictionary:
	"""Join multiplayer session"""
	var url = "%s/multiplayer/session/%d/join" % [api_url, session_id]
	var body = JSON.stringify({"characterId": character_id})
	
	var response = await post_request(url, body, false)
	if response.success:
		return {"success": true}
	return {"success": false, "error": response.error}

func list_multiplayer_sessions(session_type: String = "", status: String = "") -> Dictionary:
	"""List active multiplayer sessions"""
	var url = "%s/multiplayer/sessions" % api_url
	var params = []
	if session_type:
		params.append("session_type=%s" % session_type)
	if status:
		params.append("status=%s" % status)
	if params.size() > 0:
		url += "?" + "&".join(params)
	
	var response = await get_request(url, false)
	if response.success:
		return {"success": true, "sessions": response.data.sessions}
	return {"success": false, "error": response.error}

# ============================================================================
# LEADERBOARD ENDPOINTS
# ============================================================================

func get_righteousness_leaderboard(limit: int = 50, offset: int = 0) -> Dictionary:
	"""Get righteousness leaderboard"""
	var url = "%s/leaderboard/righteousness?limit=%d&offset=%d" % [api_url, limit, offset]
	var response = await get_request(url, false)
	
	if response.success:
		return {"success": true, "leaderboard": response.data.leaderboard}
	return {"success": false, "error": response.error}

func get_character_rank(character_id: int) -> Dictionary:
	"""Get character ranking"""
	var url = "%s/leaderboard/rank/%d" % [api_url, character_id]
	var response = await get_request(url, false)
	
	if response.success:
		return {"success": true, "rank_data": response.data}
	return {"success": false, "error": response.error}

# ============================================================================
# HTTP UTILITY FUNCTIONS
# ============================================================================

func get_request(url: String, needs_auth: bool = false) -> Dictionary:
	"""Perform GET request"""
	var headers = ["Content-Type: application/json"]
	if needs_auth and GameManager.auth_token:
		headers.append("Authorization: Bearer %s" % GameManager.auth_token)
	
	var request = HTTPRequest.new()
	add_child(request)
	request.request(url, headers, HTTPClient.METHOD_GET)
	var response = await request.request_completed
	request.queue_free()
	
	return parse_response(response)

func post_request(url: String, body: String, needs_auth: bool = false) -> Dictionary:
	"""Perform POST request"""
	var headers = ["Content-Type: application/json"]
	if needs_auth and GameManager.auth_token:
		headers.append("Authorization: Bearer %s" % GameManager.auth_token)
	
	var request = HTTPRequest.new()
	add_child(request)
	request.request(url, headers, HTTPClient.METHOD_POST, body)
	var response = await request.request_completed
	request.queue_free()
	
	return parse_response(response)

func patch_request(url: String, body: String, needs_auth: bool = false) -> Dictionary:
	"""Perform PATCH request"""
	var headers = ["Content-Type: application/json"]
	if needs_auth and GameManager.auth_token:
		headers.append("Authorization: Bearer %s" % GameManager.auth_token)
	
	var request = HTTPRequest.new()
	add_child(request)
	request.request(url, headers, HTTPClient.METHOD_PATCH, body)
	var response = await request.request_completed
	request.queue_free()
	
	return parse_response(response)

func parse_response(response: Array) -> Dictionary:
	"""Parse HTTP response"""
	var result = response[1].get_string_from_utf8()
	var data = JSON.parse_string(result)
	
	if data == null:
		return {"success": false, "error": "Invalid response", "data": {}}
	
	return {
		"success": !data.has("error"),
		"data": data,
		"error": data.get("error", "")
	}
