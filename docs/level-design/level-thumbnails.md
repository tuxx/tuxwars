# Level Thumbnails

Level thumbnails provide visual previews in the level select screen. Super Tux War includes a custom editor plugin that automatically generates thumbnails from your level scenes.

## Overview

The **Level Thumb Baker** plugin:
- Automatically captures level layouts
- Generates 256×144 PNG thumbnails
- Updates registry for preloading (important for web builds)
- Runs automatically when levels are saved
- Can be triggered manually from the editor

## Baker Plugin

**Plugin Path**: `addons/level_thumb_baker/`  
**Main Script**: `baker_plugin.gd`  
**Output Directory**: `assets/level_thumbs/`  
**Registry**: `scripts/level_thumbnails.gd`

### How It Works

1. **Finds level scenes** in `scenes/levels/` (files starting with "level")
2. **Renders each level** in a SubViewport (256×144)
3. **Computes bounds** from TileMapLayer nodes
4. **Scales and centers** the level to fit the thumbnail
5. **Saves PNG** to `assets/level_thumbs/`
6. **Updates registry** with preload statements for web builds

### Automatic Baking

The plugin automatically bakes thumbnails when:
- A level scene (`.tscn`) in `scenes/levels/` is modified
- The filesystem reimports resources

**You usually don't need to do anything** - just save your level and the thumbnail updates automatically!

### Manual Baking

To manually trigger thumbnail generation:

1. In Godot Editor, click **Project** in the top menu
2. Select **Tools → Level Thumbs: Bake**
3. Wait for baking to complete (check Output console)

**Console Output**:
```
Baked 2 level thumbnails (skipped 0 up-to-date)
Updated LevelThumbnails registry at res://scripts/level_thumbnails.gd
```

## Thumbnail Specifications

### Output Format

- **Size**: 256×144 pixels (16:9 aspect ratio)
- **Format**: PNG with transparency
- **Naming**: `{level_basename}.png` (e.g., `level01.png`)
- **Location**: `assets/level_thumbs/`

### Rendering Settings

```gdscript
const THUMB_SIZE := Vector2i(256, 144)
```

- **Texture Filter**: Nearest (pixel-perfect)
- **Transparent Background**: Yes
- **Camera**: Centered on level bounds
- **Scaling**: Fit entire level within thumbnail

### What Gets Captured

The baker captures **all TileMapLayer nodes** in your level:
- DecorationTileMap (background)
- GroundTileMap (solid tiles)
- SemisolidTileMap (platforms)

**Not captured**:
- SpawnPoint markers (invisible in game)
- Characters (they spawn at runtime)
- HUD elements (CanvasLayer)
- Dynamic objects

## Level Registry

### LevelThumbnails Class

**Script**: `res://scripts/level_thumbnails.gd`  
**Type**: Resource class (auto-generated)

This registry ensures thumbnails are **preloaded** at compile time, which is critical for web/HTML5 builds where runtime file access is restricted.

### Registry Structure

```gdscript
extends Resource
class_name LevelThumbnails

const THUMBNAILS := {
	"level01": preload("res://assets/level_thumbs/level01.png"),
	"level02": preload("res://assets/level_thumbs/level02.png"),
}

static func get_thumbnail(level_path: String) -> Texture2D:
	var basename := level_path.get_file().get_basename()
	if THUMBNAILS.has(basename):
		return THUMBNAILS[basename]
	return null

static func get_available_levels() -> Array[String]:
	var levels: Array[String] = []
	levels.assign(THUMBNAILS.keys())
	return levels
```

### Using Thumbnails in Code

**Get thumbnail for a level**:
```gdscript
var thumbnail := LevelThumbnails.get_thumbnail("res://scenes/levels/level01.tscn")
if thumbnail:
	texture_rect.texture = thumbnail
```

**Get all available levels**:
```gdscript
var available_levels := LevelThumbnails.get_available_levels()
for level_name in available_levels:
	print(level_name)  # "level01", "level02", etc.
```

## Level Requirements

For a level to get a thumbnail:

### Naming Convention

- **File location**: `res://scenes/levels/`
- **File name pattern**: `level*.tscn` (must start with "level")
- **Examples**: `level01.tscn`, `level02.tscn`, `level_castle.tscn`

### Scene Structure

Your level must have:
- At least one **TileMapLayer** node with painted tiles
- Proper **TileSet** assigned (usually `smw_blocks.tres`)
- Some **tile data** (used_rect not empty)

**Minimal valid level**:
```
TileMapLevel (Node2D)
├── GroundTileMap (TileMapLayer) [with tiles painted]
└── ... (other nodes)
```

## Troubleshooting

### Thumbnail Not Generated

**Check these**:

1. **File naming**: Does level filename start with "level"?
   - ✅ `level03.tscn`
   - ❌ `arena_01.tscn` (doesn't start with "level")

2. **File location**: Is level in `scenes/levels/`?
   - ✅ `res://scenes/levels/level03.tscn`
   - ❌ `res://scenes/test/level03.tscn` (wrong folder)

3. **TileMap data**: Are there painted tiles?
   - Open level in editor
   - Check GroundTileMap or SemisolidTileMap
   - Paint at least a few tiles if empty

4. **Plugin enabled**: Is the plugin active?
   - Project → Project Settings → Plugins
   - Ensure "Level Thumb Baker" is checked

### Thumbnail Looks Wrong

**Black/empty thumbnail**:
- Level has no tiles painted
- All TileMapLayers are empty
- Solution: Paint some tiles!

**Wrong scale/cropping**:
- Baker uses automatic bounds detection
- If level has stray tiles far from main area, it affects framing
- Solution: Delete stray tiles outside the main level area

**Outdated thumbnail**:
- Thumbnail wasn't regenerated after level changes
- Solution: Manually run baker (Project → Tools → Level Thumbs: Bake)

### Registry Not Updated

**Thumbnail exists but not in registry**:
1. Check `scripts/level_thumbnails.gd`
2. If thumbnail PNG exists but not in registry, run baker manually
3. Baker should output: "Updated LevelThumbnails registry"

**Web build can't load thumbnails**:
- This happens if thumbnails aren't preloaded
- Ensure registry has `preload()` statements (not load() or res://)
- Re-run baker to regenerate registry

## Customizing the Baker

### Change Thumbnail Size

Edit `baker_plugin.gd`:

```gdscript
const THUMB_SIZE := Vector2i(256, 144)  # Change dimensions here
```

**Considerations**:
- Maintain 16:9 aspect ratio for consistency
- Larger thumbnails = larger file size
- Update UI if changing dimensions

### Change Output Directory

Edit `baker_plugin.gd`:

```gdscript
const OUT_DIR := "res://assets/level_thumbs"  # Change output path
```

**Remember to**:
- Update any UI code that loads thumbnails
- Ensure directory exists or baker will create it

### Custom Rendering

The rendering logic is in `_render_level_thumbnail()`:

**Current process**:
1. Load level PackedScene
2. Instantiate in SubViewport
3. Calculate bounds from TileMapLayer nodes
4. Scale to fit THUMB_SIZE
5. Wait for render frames
6. Capture ViewportTexture
7. Save as PNG

**Customization ideas**:
- Add filters or post-processing
- Overlay level name or metadata
- Render with specific camera angles
- Include background layers or effects

### Skip Caching (Always Bake)

By default, the baker skips levels if the thumbnail is newer than the level scene (performance optimization).

To force re-bake every time, modify `_is_thumbnail_up_to_date()`:

```gdscript
func _is_thumbnail_up_to_date(level_path: String, thumb_path: String) -> bool:
	return false  # Always re-bake (slower but ensures freshness)
```

## Integration with UI

### Start Menu / Level Select

The start menu uses thumbnails for level selection. Example integration:

```gdscript
# In level select UI
func _populate_level_list() -> void:
	var levels := LevelThumbnails.get_available_levels()
	for level_name in levels:
		var thumbnail := LevelThumbnails.get_thumbnail(level_name)
		var card := LevelCard.instantiate()
		card.set_thumbnail(thumbnail)
		card.set_level_name(level_name)
		level_container.add_child(card)
```

### Level Cards

Create visual cards for level selection:

**Components**:
- **TextureRect**: Display thumbnail
- **Label**: Level name (from LevelInfo)
- **Button**: Clickable to select level

**Example scene structure**:
```
LevelCard (Button)
├── ThumbnailRect (TextureRect)
└── LevelNameLabel (Label)
```

## Best Practices

### Design for Thumbnails

When designing levels, consider how they'll look in thumbnail form:

✅ **Good for thumbnails**:
- Clear, distinct layout
- Varied platform heights (shows structure)
- Contrasting tile types (solid vs semisolid)
- Recognizable silhouette

❌ **Hard to see in thumbnails**:
- Very flat levels (all one height)
- Monochrome tile colors (low contrast)
- Overly complex layouts (too much detail)
- Mostly empty space

### Testing Thumbnails

After creating a level:
1. Save the level scene
2. Check `assets/level_thumbs/` for the PNG
3. Open the PNG to review thumbnail appearance
4. Run the game and view level select screen
5. If thumbnail looks bad, adjust level layout

### Updating Thumbnails

Thumbnails update automatically, but you can verify:

```bash
# Check thumbnail modified time
ls -lh assets/level_thumbs/
```

If a level changed but thumbnail didn't update:
- Manually run the baker
- Check console for errors
- Verify plugin is enabled

## Performance Notes

### Baking Speed

- Small levels: ~0.1 seconds
- Large levels: ~0.5 seconds
- Multiple levels: Sequential processing

The baker uses `await` and frame synchronization for reliable rendering, so expect a short delay when baking multiple levels.

### Up-to-Date Detection

The baker compares file modification times:
- **Level scene modified time** vs **Thumbnail modified time**
- If thumbnail is newer or equal, baking is skipped
- This optimization keeps iteration fast

### Web Builds

Thumbnails must be preloaded because web builds:
- Run in restricted environment (browser)
- Can't access filesystem at runtime
- Require compile-time resource embedding

The registry's `preload()` statements ensure thumbnails are baked into the web build.

## Related Topics

- **[Getting Started](getting-started.md)** - Includes thumbnail generation step
- **[Tile Layers](tile-layers.md)** - What gets rendered in thumbnails
- [baker_plugin.gd](../../addons/level_thumb_baker/baker_plugin.gd) - Baker source code
- [level_thumbnails.gd](../../scripts/levels/level_thumbnails.gd) - Thumbnail registry

---

**Next**: [Navigation Graph →](navigation-graph.md)

