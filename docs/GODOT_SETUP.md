extends Node
# Godot Installation & Setup Guide

## Requirements

- **Godot 4.x** (Latest stable): [Download](https://godotengine.org/download)
- **Node.js 18+** for backend
- **PostgreSQL 14+** or Supabase account
- **Git** for version control

## Backend Setup

1. Navigate to backend directory:
   ```bash
   cd backend
   npm install
   ```

2. Configure environment:
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

3. Setup database:
   ```bash
   npm run migrate
   ```

4. Start server:
   ```bash
   npm start
   ```

Server runs on `http://localhost:3000`

## Godot Setup

1. Open Godot 4.x

2. Import Soul Ascension project:
   - Click "Import Project"
   - Navigate to `godot/` directory
   - Click "Import & Edit"

3. Wait for resources to load

4. Open project:
   - Edit → Project Settings
   - Verify autoload managers are configured
   - Check network settings

## Running the Game

1. **Backend Running**: `npm start` (in backend directory)

2. **In Godot Editor**:
   - Press F5 or click Play button
   - Game starts in Main Menu scene

3. **Configure API Endpoint**:
   - In NetworkManager.gd
   - Change `api_url` if backend runs on different port
   - Change `websocket_url` for WebSocket connection

## Build for Desktop

1. In Godot:
   - Go to Project → Project Settings → Export
   - Configure export templates
   - Select platform (Windows/macOS/Linux)
   - Click Export Project

2. Built executable will be in `build/` directory

## Build for Mobile (Android/iOS)

1. Install Android SDK (for Android builds)

2. In Godot:
   - Project → Project Settings → Export
   - Configure Android/iOS export presets
   - Export project

## Project Structure

```
godot/
├── scenes/           # Game scenes
│   ├── menu/        # Menu screens
│   ├── main/        # Gameplay scenes
│   ├── enemies/     # Enemy scenes
│   └── ui/          # UI components
├── scripts/         # GDScript files
│   ├── managers/    # Game managers
│   ├── player/      # Player scripts
│   ├── enemy/       # Enemy AI
│   ├── systems/     # Game systems
│   └── utils/       # Utility functions
├── assets/          # Game assets
│   ├── models/      # 3D models
│   ├── textures/    # Textures
│   ├── audio/       # Music & SFX
│   └── ui/          # UI graphics
└── project.godot    # Project config
```

## Tips for Development

### Scene Management
- Use autoload managers for global state
- Keep scenes modular and reusable
- Use signals for communication between scenes

### Performance
- Profile with Godot's built-in profiler
- Use object pooling for frequently spawned enemies
- Cache frequently accessed nodes

### Testing
- Test each scene independently
- Use play button in editor to test locally
- Test multiplayer scenarios with multiple instances

### Debugging
- Use `print()` statements strategically
- Use Godot's debugger for step-through debugging
- Monitor network requests in browser dev tools

## Troubleshooting

### Connection Issues
- Verify backend is running on correct port
- Check firewall settings
- Verify API_URL in NetworkManager matches backend

### Missing Assets
- Ensure all assets are imported correctly
- Check resource paths in scripts
- Rebuild project if issues persist

### Performance Problems
- Monitor FPS with Godot profiler
- Reduce polygon count for enemies
- Optimize particle effects

## Next Steps

1. Create 3D models for characters and enemies
2. Design 3D environments for Hell, Earth, Heaven
3. Create UI designs
4. Add more quests and story content
5. Implement additional abilities and items
6. Setup build pipelines for releases

---

For more information, see docs/GAME_DESIGN.md and docs/API_DOCUMENTATION.md
