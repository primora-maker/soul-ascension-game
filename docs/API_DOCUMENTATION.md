# Soul Ascension - API Documentation

## Authentication Endpoints

### Register
```
POST /api/auth/register
Content-Type: application/json

{
  "username": "player_name",
  "email": "player@example.com",
  "password": "secure_password"
}

Response: 201 Created
{
  "message": "Player registered successfully",
  "player": { ... },
  "token": "jwt_token"
}
```

### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "player@example.com",
  "password": "secure_password"
}

Response: 200 OK
{
  "message": "Login successful",
  "player": { ... },
  "token": "jwt_token"
}
```

### Verify Token
```
POST /api/auth/verify
Authorization: Bearer <token>

Response: 200 OK
{
  "valid": true,
  "player": { ... }
}
```

## Character Endpoints

### Create Character
```
POST /api/character/create
Authorization: Bearer <token>
Content-Type: application/json

{
  "character_name": "Soul Name",
  "soul_name": "Optional Soul Name"
}

Response: 201 Created
{
  "message": "Character created successfully",
  "character": { ... }
}
```

### Get My Characters
```
GET /api/character/my-characters
Authorization: Bearer <token>

Response: 200 OK
{
  "count": 3,
  "characters": [ ... ]
}
```

### Get Character Details
```
GET /api/character/:characterId
Authorization: Bearer <token>

Response: 200 OK
{
  "character": { ... },
  "abilities": [ ... ],
  "recent_moral_choices": [ ... ]
}
```

### Update Character Stats
```
PATCH /api/character/:characterId/stats
Authorization: Bearer <token>
Content-Type: application/json

{
  "experience_points": 100,
  "moral_alignment": 5,
  "faith_level": 10,
  "righteousness_points": 50
}

Response: 200 OK
{
  "message": "Character updated successfully",
  "character": { ... }
}
```

## Battle Endpoints

### Start Battle
```
POST /api/battle/start
Authorization: Bearer <token>
Content-Type: application/json

{
  "characterId": 1,
  "enemyId": 5
}

Response: 201 Created
{
  "message": "Battle started",
  "battle": { ... }
}
```

### Record Battle Action
```
POST /api/battle/:battleId/action
Authorization: Bearer <token>
Content-Type: application/json

{
  "action_type": "attack",
  "ability_id": 1,
  "damage": 25
}

Response: 200 OK
{
  "message": "Action recorded",
  "turn": { ... },
  "battle_log_length": 5
}
```

### End Battle
```
POST /api/battle/:battleId/end
Authorization: Bearer <token>
Content-Type: application/json

{
  "battle_result": "won",
  "player_final_health": 45,
  "enemy_final_health": 0
}

Response: 200 OK
{
  "message": "Battle ended",
  "result": "won",
  "rewards": {
    "experience_gained": 100,
    "points_gained": 50,
    "moral_impact": 5
  }
}
```

### Get Battle History
```
GET /api/battle/history/:characterId?limit=10
Authorization: Bearer <token>

Response: 200 OK
{
  "count": 10,
  "battles": [ ... ]
}
```

## Quest Endpoints

### Get Available Quests
```
GET /api/quest/:characterId/available
Authorization: Bearer <token>

Response: 200 OK
{
  "count": 5,
  "quests": [ ... ]
}
```

### Start Quest
```
POST /api/quest/:questId/start
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Quest started",
  "quest": { ... }
}
```

### Complete Quest
```
POST /api/quest/:questId/complete
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Quest completed",
  "quest": { ... },
  "rewards": {
    "experience": 100,
    "points": 50,
    "alignment": 5
  }
}
```

## Multiplayer Endpoints

### Create Session
```
POST /api/multiplayer/session/create
Authorization: Bearer <token>
Content-Type: application/json

{
  "session_name": "Demon Slayers",
  "session_type": "cooperative",
  "max_players": 4
}

Response: 201 Created
{
  "message": "Multiplayer session created",
  "session": { ... }
}
```

### Join Session
```
POST /api/multiplayer/session/:sessionId/join
Authorization: Bearer <token>
Content-Type: application/json

{
  "characterId": 1
}

Response: 200 OK
{
  "message": "Successfully joined session",
  "session_id": 1,
  "character_name": "Soul Name"
}
```

### Get Session Members
```
GET /api/multiplayer/session/:sessionId/members
Authorization: Bearer <token>

Response: 200 OK
{
  "count": 3,
  "members": [ ... ]
}
```

### Leave Session
```
POST /api/multiplayer/session/:sessionId/leave
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Successfully left session"
}
```

### List Active Sessions
```
GET /api/multiplayer/sessions?session_type=cooperative&status=waiting
Authorization: Bearer <token>

Response: 200 OK
{
  "count": 5,
  "sessions": [ ... ]
}
```

## Leaderboard Endpoints

### Righteousness Leaderboard
```
GET /api/leaderboard/righteousness?limit=50&offset=0

Response: 200 OK
{
  "leaderboard_type": "righteousness",
  "count": 50,
  "leaderboard": [ ... ]
}
```

### Total Points Leaderboard
```
GET /api/leaderboard/points?limit=50&offset=0

Response: 200 OK
{
  "leaderboard_type": "total_points",
  "count": 50,
  "leaderboard": [ ... ]
}
```

### Battles Won Leaderboard
```
GET /api/leaderboard/battles?limit=50&offset=0

Response: 200 OK
{
  "leaderboard_type": "battles_won",
  "count": 50,
  "leaderboard": [ ... ]
}
```

### Get Character Rank
```
GET /api/leaderboard/rank/:characterId

Response: 200 OK
{
  "character_name": "Soul Name",
  "ranks": {
    "righteousness": 15,
    "total_points": 23,
    "battles_won": 10
  },
  "stats": { ... }
}
```

## WebSocket Events

### Connect & Authenticate
```
{
  "type": "authenticate",
  "playerId": 1,
  "characterId": 1
}

Response:
{
  "type": "auth_success",
  "message": "Authenticated successfully"
}
```

### Battle Update
```
{
  "type": "battle_update",
  "characterId": 1,
  "payload": { ... }
}
```

### Moral Choice
```
{
  "type": "moral_choice",
  "characterId": 1,
  "payload": { ... }
}
```

### Multiplayer Action
```
{
  "type": "multiplayer_action",
  "sessionId": 1,
  "payload": { ... }
}
```

## Error Responses

All error responses follow this format:

```json
{
  "error": "Error Type",
  "message": "Detailed error message",
  "details": "Additional context if available"
}
```

### Common Status Codes
- `200 OK`: Successful request
- `201 Created`: Resource created
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Authentication required
- `404 Not Found`: Resource not found
- `409 Conflict`: Duplicate or conflicting data
- `500 Internal Server Error`: Server error

## Authentication Header

All authenticated endpoints require:
```
Authorization: Bearer <jwt_token>
```

Tokens expire after 7 days by default.

---

For more information, see the main README.md or Game Design Document.
