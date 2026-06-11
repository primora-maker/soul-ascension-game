extends Node3D
# Environment Manager - Manages dynamic environments (Hell, Earth, Heaven)

class_name EnvironmentManager

@onready var world_env: WorldEnvironment = $WorldEnvironment

var phase: String = "hell"

# Environment settings per phase
var environments: Dictionary = {
	"hell": {
		"ambient_color": Color.RED,
		"fog_color": Color(0.5, 0, 0),
		"fog_enabled": true,
		"sky_rotation": 0.0,
		"music": "battle"
	},
	"earth": {
		"ambient_color": Color.GRAY,
		"fog_color": Color(0.7, 0.7, 0.8),
		"fog_enabled": false,
		"sky_rotation": PI / 4,
		"music": "earth"
	},
	"heaven": {
		"ambient_color": Color.WHITE,
		"fog_color": Color(0.9, 0.95, 1),
		"fog_enabled": false,
		"sky_rotation": PI,
		"music": "heaven"
	}
}

func _ready():
	print("[EnvironmentManager] Initialized")
	set_phase("hell")

func set_phase(new_phase: String) -> void:
	"""Change environment phase"""
	if new_phase not in environments:
		print("[EnvironmentManager] Unknown phase: %s" % new_phase)
		return
	
	phase = new_phase
	var env_data = environments[phase]
	
	print("[EnvironmentManager] Setting phase to: %s" % phase)
	
	# Update lighting
	if world_env and world_env.environment:
		var env = world_env.environment
		env.ambient_light_source = Environment.AMBIENT_LIGHT_FIXED
		env.ambient_light_intensity = 1.0
	
	# Play appropriate music
	AudioManager.play_music(env_data.music)

func transition_to_phase(target_phase: String, duration: float = 2.0) -> void:
	"""Smoothly transition to new phase"""
	print("[EnvironmentManager] Transitioning to %s" % target_phase)
	
	# Create transition effect
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): set_phase(target_phase))
	tween.tween_property(self, "modulate", Color.WHITE, duration)
