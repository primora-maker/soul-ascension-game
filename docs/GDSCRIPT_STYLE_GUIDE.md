# Soul Ascension - GDScript Style Guide

## Overview
This document outlines the coding standards for the Soul Ascension Godot project.

## Naming Conventions

### Classes
Use PascalCase for class names:
```gdscript
class_name PlayerCharacter
class_name BattleSystem
class_name GameManager
```

### Functions & Variables
Use snake_case for functions and variables:
```gdscript
func take_damage(amount: int) -> void
var current_health: int = 100
var is_alive: bool = true
```

### Constants
Use UPPER_SNAKE_CASE for constants:
```gdscript
const MAX_HEALTH: int = 100
const ATTACK_COOLDOWN: float = 2.0
```

### Signals
Use snake_case for signals:
```gdscript
signal player_died
signal battle_started
signal moral_choice_made
```

## Code Organization

### File Structure
```
godot/
├── scenes/
│   ├── menu/
│   ├── main/
│   ├── enemies/
│   └── ui/
├── scripts/
│   ├── managers/
│   ├── player/
│   ├── enemy/
│   ├── systems/
│   └── utils/
├── assets/
│   ├── models/
│   ├── textures/
│   ├── audio/
│   └── ui/
└── project.godot
```

## Code Style

### Comments
Use clear, descriptive comments:
```gdscript
# Calculate damage with variance
func calculate_damage(power: int) -> int:
	var damage = power + randi_range(-5, 5)
	return max(1, damage)
```

### Type Hints
Always use type hints:
```gdscript
func take_damage(amount: int) -> void:
var health: int = 100
```

### Error Handling
Check for null/invalid instances:
```gdscript
if is_instance_valid(player):
	player.take_damage(damage)
```

## Performance

- Use `@onready` for node references
- Cache frequently accessed nodes
- Use object pooling for frequently spawned enemies
- Profile with Godot's profiler

## Testing

- Test each system independently
- Test multiplayer scenarios locally
- Use debug prints judiciously

---

For more information, see the main README.md
