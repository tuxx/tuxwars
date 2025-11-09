# Roadmap

This roadmap outlines the planned features and development priorities for Super Tux War.

## Current Status

### ✅ Completed (Phase 0 - Core Foundation)

- **Player Movement**
  - SMW-style physics (walk, run, jump)
  - Variable jump height
  - Coyote time and jump buffering
  - Ice block physics (reduced friction)

- **Level System**
  - 32×32 tile-based levels
  - TileMapLayer support (solid, semisolid, decoration)
  - Level thumbnails with auto-generation
  - Level info and metadata

- **Combat System**
  - Head stomp mechanics
  - Character death and respawn (2s delay)
  - Gravestone spawning
  - Score tracking

- **AI System**
  - NPC controller with pathfinding
  - Navigation graph generation
  - Jump arc physics simulation
  - Multiple CPU character support (up to 7 tested)

- **Character System**
  - Modular character components (physics, visuals, lifecycle)
  - Character selection (Tux, Beasty, Gopher)
  - Animation system
  - CPU color tinting

- **UI System**
  - Start menu with character selection
  - Level selection
  - Pause menu
  - Game over scoreboard
  - Dev menu (F11/F12 debug tools)

- **Editor Tools**
  - Level thumbnail baker plugin
  - Auto-baking on level save

## In Progress (Phase 1)

### 🚧 Items & Power-ups

**Status**: Planning phase

**Planned Items**:
- **Stompboxes**: Breakable boxes that spawn items
- **Fish**: Speed boost power-up
- **Floppies**: Collectible items (scoring)
- **Sudo**: Invincibility power-up
- **Throwable hazards**: Objects that can be thrown at opponents
- **Level-wide stun**: Item that stuns all other characters

**Technical Requirements**:
- Item spawning system
- Item collision and pickup
- Power-up state management
- Throwable object physics
- Visual effects for power-ups

---

## Phase 2: Audio System

### 🎵 Sound & Music

**Priority**: High  
**Status**: Not started

**Sound Effects Needed**:
- Jump sound
- Stomp hit sound
- Death sound
- Respawn sound
- Item pickup sound
- Power-up activation sound
- UI interaction sounds

**Music Needed**:
- Menu music
- Level music (multiple tracks)
- Victory/game over music

**Technical Requirements**:
- AudioStreamPlayer management
- Sound effect system with pooling
- Music system with crossfading
- Volume controls and settings
- Audio bus configuration

---

## Phase 3: Multiplayer

### 🎮 Local Multiplayer

**Priority**: High  
**Status**: Not started

**Features**:
- Split-screen support (2-4 players)
- Local input management for multiple controllers
- Camera system for multiple viewports
- Per-player UI elements

**Technical Requirements**:
- Input device mapping
- Viewport splitting and management
- Character spawning for local players
- Score tracking per player

### 🌐 Network Multiplayer

**Priority**: Medium  
**Status**: Not started (requires local multiplayer first)

**Phase 3a: Peer-to-Peer**
- Host/join game system
- P2P networking with Godot's high-level multiplayer API
- Lobby system
- Player synchronization
- Input prediction and lag compensation

**Phase 3b: Dedicated Servers (Optional)**
- Server browser
- Matchmaking
- Server hosting tools
- Anti-cheat considerations

**Technical Requirements**:
- Network architecture design
- State synchronization
- Rollback netcode (if needed)
- Connection handling and reconnection
- Network optimization

---

## Phase 4: Game Modes

### 🏆 Game Modes

**Priority**: Medium  
**Status**: Not started (requires multiplayer)

Currently only **Free-for-All Deathmatch** exists.

**Planned Modes**:
- **Team Deathmatch**: Teams compete for most stomps
- **Capture the Flag**: Grab the flag and return to base
- **Last One Standing**: Battle royale style, limited lives
- **Collect the Floppies**: Gather the most collectibles
- **King of the Hill**: Control a zone for longest time
- **Race Mode**: First to reach the goal

**Technical Requirements**:
- Game mode framework/system
- Team management
- Mode-specific UI
- Win conditions and scoring
- Mode-specific level requirements

---

## Phase 5: Content Expansion

### 🌍 Worlds & Levels

**Priority**: Medium  
**Status**: 2 levels exist, need more

**Needs**:
- 10-20 levels across multiple worlds
- Themed worlds (ice, desert, forest, castle, etc.)
- Boss arenas (if boss mode is added)
- Community level support/workshop

**Level Themes Needed**:
- Ice/Snow world
- Desert world
- Forest world
- Castle/Dungeon world
- Tech/Cyber world
- Sky/Cloud world

### 🎨 Visual Polish

**Priority**: Low-Medium  
**Status**: Basic pixel art exists

**Needs**:
- Particle effects (dust, impact, power-up sparkles)
- Screen shake and juice effects
- Improved character sprites (see [CONTRIBUTING.md](CONTRIBUTING.md))
- Animated backgrounds
- Weather effects (rain, snow)
- Lighting effects

### 🎭 Additional Characters

**Priority**: Medium  
**Status**: 3 characters exist (Tux, Beasty, Gopher)

**Planned Characters** (see [CONTRIBUTING.md](CONTRIBUTING.md)):
- OpenBSD Fish (Puffy)
- GIMP (Wilber)
- GNU (Gnu)
- Rust (Ferris the crab)
- More open-source mascots

**Technical Requirements**:
- Character-specific stats/abilities (optional)
- More animations (attack, special moves)
- Character unlock system (optional)

---

## Phase 6: Polish & Quality of Life

### ✨ Polish

**Priority**: Low-Medium  
**Status**: Ongoing

**Features**:
- Better UI/UX design
- Improved menu animations
- Tutorial/how to play
- Settings menu (controls, audio, graphics)
- Key rebinding
- Gamepad support improvements
- Accessibility options

### 🛠️ Developer Tools

**Priority**: Low  
**Status**: Basic dev menu exists

**Enhancements**:
- Level editor improvements
- In-game debug tools
- Performance profiler
- Network testing tools
- Replay system

---

## Phase 7: Platform Support

### 📱 Additional Platforms

**Priority**: Low  
**Status**: Web build works, desktop TBD

**Platforms**:
- ✅ Web (HTML5) - Working
- 🚧 Linux - Tested locally, needs official builds
- 🚧 Windows - Needs testing
- 🚧 macOS - Needs testing
- ❓ Steam Deck - Future consideration
- ❓ Mobile (Android/iOS) - Low priority, needs UI redesign

---

## Long-Term Ideas

These are ideas for the distant future, priority TBD:

- **Modding Support**: Custom characters, levels, items
- **Level Editor In-Game**: Built-in level creation tool
- **Spectator Mode**: Watch matches
- **Replays**: Save and replay matches
- **Statistics**: Detailed player stats and achievements
- **Seasonal Events**: Limited-time modes and cosmetics
- **Tournament Mode**: Bracket system for competitive play
- **Custom Game Rules**: Modifiers and mutators

---

## Contributing to Roadmap Items

Interested in implementing a feature? Here's how to help:

1. **Check GitHub Issues**: Features may have associated issues
2. **Discuss First**: Open an issue or discussion for major features
3. **Start Small**: Pick smaller tasks if you're new to the codebase
4. **See [CONTRIBUTING.md](CONTRIBUTING.md)**: For general contribution guidelines

## Timeline

**Note**: This is a hobby project with no fixed timeline. Features will be completed as contributors have time and interest. The phases are priority-based, not time-based.

**Current Focus**: Phase 1 (Items) and Phase 2 (Audio)

---

**Last Updated**: 2025-11-09  
**Version**: 0.1.0-alpha

