# Level Design Guide

Welcome to the Super Tux War level design guide! This section covers everything you need to create engaging multiplayer arena levels.

## 📋 Quick Start

New to level design? Start here:

1. **[Getting Started](getting-started.md)** - Create your first level step-by-step
2. **[Tile Layers & Block Types](tile-layers.md)** - Learn the tile system
3. **[Spawn Points](spawn-points.md)** - Set up character spawning

## 📚 Complete Guide

### Essential Topics

- **[Getting Started](getting-started.md)**  
  Step-by-step tutorial for creating a new level from scratch
  
- **[Tile Layers & Block Types](tile-layers.md)**  
  Understanding solid blocks, semisolid platforms, ice, death tiles, and decorations
  
- **[Spawn Points](spawn-points.md)**  
  How the spawn system works and best practices for placement

### Advanced Topics

- **[Level Thumbnails](level-thumbnails.md)**  
  Automatic thumbnail generation with the baker plugin
  
- **[Navigation Graph](navigation-graph.md)**  
  How the AI pathfinding system analyzes your levels

## 🎨 Design Philosophy

Super Tux War levels follow **Super Mario War conventions**:

### Core Principles

1. **Open Arenas** - Avoid narrow corridors
2. **Vertical Play** - Multiple platform heights
3. **Movement Flow** - Design for running and jumping
4. **Combat Spaces** - Room to maneuver and stomp
5. **Fair Spawning** - Spread spawn points throughout the level

### Design Rules

- **Tile Grid**: Strict 32×32 pixel grid
- **Headroom**: ≥2 tiles above platforms
- **Jump Gaps**: ≤3 tiles horizontal, ~2-3 tiles vertical
- **Arena Size**: Recommended 1280×720px viewport area (40×22.5 tiles)
- **Spawn Points**: 4-8 points for good distribution

### Common Mistakes to Avoid

❌ **Don't create 1-tile-high tunnels** - Characters need headroom  
❌ **Don't make gaps >4 tiles** - Players can't jump that far  
❌ **Don't cluster spawn points** - Spread them out  
❌ **Don't forget semisolid platforms** - They enable vertical movement  
❌ **Don't over-decorate** - Keep gameplay readable

✅ **Do provide multiple paths** - Vertical and horizontal options  
✅ **Do test with 4+ players** - Ensure enough space  
✅ **Do use varied platform heights** - Create interesting combat  
✅ **Do place spawn points strategically** - Away from death hazards

## 🛠️ Level Components

Every level needs these components:

### Required Nodes

```
TileMapLevel (Node2D)
├── DecorationTileMap (TileMapLayer)
├── GroundTileMap (TileMapLayer)
├── SemisolidTileMap (TileMapLayer)
├── HUD (CanvasLayer)
├── SpawnManager (Node)
│   ├── SpawnPoint (Marker2D)
│   ├── SpawnPoint2 (Marker2D)
│   └── ... (more spawn points)
└── LevelInfo (Node)
```

### Scripts Required

- **LevelNavigation** (`level_navigation.gd`) - Attached to root Node2D
- **SpawnManager** (`spawn_manager.gd`) - Manages character spawning
- **LevelInfo** (`level_info.gd`) - Stores level metadata

See [Getting Started](getting-started.md) for detailed setup instructions.

## 📏 Technical Specifications

### Tile System

- **Tile Size**: 32×32 pixels (fixed)
- **TileSet**: `res://assets/tilesets/smw_blocks.tres`
- **Physics Layers**: Layer 0 (solid), Layer 1 (semisolid)

### Block Types

| Type | Layer | Collision | Description |
|------|-------|-----------|-------------|
| **Solid** | GroundTileMap | Full | Walls, floors, ceilings |
| **Ice** | GroundTileMap | Full | Low-friction solid blocks |
| **Semisolid** | SemisolidTileMap | Top only | One-way platforms |
| **Death (Floor)** | GroundTileMap | Full | Kills from above (planned) |
| **Death (Ceiling)** | GroundTileMap | Full | Kills from below (planned) |
| **Decoration** | DecorationTileMap | None | Visual only |

### Character Physics

Understanding character movement helps design better levels:

- **Walk Speed**: 240 px/s (7.5 tiles/sec)
- **Run Speed**: 330 px/s (10.3 tiles/sec)
- **Jump Height**: ~2-3 tiles
- **Jump Distance**: ~3-4 tiles horizontal
- **Character Size**: ~30×30 px collision box

See [game_constants.gd](../../scripts/core/game_constants.gd) for exact values.

## 🎯 Level Design Workflow

### Standard Process

1. **Sketch Layout** - Paper sketch or digital mockup
2. **Create Scene** - Duplicate `level01.tscn` or create from template
3. **Build Geometry** - Paint tiles on GroundTileMap and SemisolidTileMap
4. **Add Decorations** - Visual polish on DecorationTileMap
5. **Place Spawns** - 8-16 spawn points spread throughout
6. **Set Metadata** - Update LevelInfo with level name
7. **Test Gameplay** - Play with multiple NPCs
8. **Bake Thumbnail** - Run level thumbnail baker
9. **Iterate** - Refine based on playtesting

### Testing Checklist

- [ ] All spawn points work correctly
- [ ] No unreachable areas
- [ ] Characters can navigate between platforms
- [ ] No spawn camping positions
- [ ] Level thumbnail generated
- [ ] Tested with 7 NPCs
- [ ] Performance is smooth

## 📖 Additional Resources

- [Godot TileMap Documentation](https://docs.godotengine.org/en/4.5/tutorials/2d/using_tilemaps.html)
- Project [README.md](../../README.md) for game design overview

## 🤝 Need Help?

- Check the [main documentation](../README.md)
- Review existing levels: `scenes/levels/level01.tscn`, `level02.tscn`
- Open an issue on GitHub for questions

---

**Next**: [Getting Started →](getting-started.md)

