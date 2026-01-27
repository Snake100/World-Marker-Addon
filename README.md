# DropWorldMarker

A World of Warcraft addon that places world markers (raid flares) at your cursor position with a single keybind, cycling through a customizable sequence of markers.

## Features

- **One-key marker placement** - Press a keybind to drop markers at your cursor
- **Custom marker sequence** - Set the exact order of markers to cycle through
- **Works in combat** - Full cycling support during combat encounters
- **Cursor placement** - Markers drop exactly where your cursor is pointing
- **Clear all markers** - Separate keybind to remove all world markers

## Installation

1. Download or clone this repository
2. Copy the `DropWorldMarker` folder to your WoW AddOns directory:
   ```
   World of Warcraft\_retail_\Interface\AddOns\
   ```
3. Restart WoW or `/reload` if already logged in

## Configuration

Open the settings panel with `/dwm config` or through Interface Options > AddOns > DropWorldMarker.

### Marker Sequence

Set up to 8 slots to define which markers to place and in what order. Select a marker icon for each slot, or "None" to skip that slot. The addon cycles through your sequence and loops back to the beginning.

**Example:** Set slots 1-4 to Star, Moon, Skull, Cross and leave 5-8 as None. The addon will cycle: Star → Moon → Skull → Cross → Star...

### Keybindings

Set your keybinds directly in the options panel:
- **Place Next Marker** - Drops the next marker in your sequence at cursor
- **Clear All Markers** - Removes all world markers and resets the sequence

Click the keybind button and press your desired key (supports Shift, Ctrl, Alt modifiers). Press Escape to clear a keybind.

### Chat Messages

Toggle whether the addon prints messages to chat when placing or clearing markers.

## Slash Commands

| Command | Description |
|---------|-------------|
| `/dwm` | Place next marker |
| `/dwm clear` | Clear all markers |
| `/dwm reset` | Reset sequence to beginning |
| `/dwm config` | Open options panel |
| `/dwm sync` | Sync sequence (after manual changes) |

## World Marker Reference

| Slot | Marker |
|------|--------|
| 1 | Square (Blue) |
| 2 | Triangle (Green) |
| 3 | Diamond (Purple) |
| 4 | Cross (Red) |
| 5 | Star (Yellow) |
| 6 | Circle (Orange) |
| 7 | Moon (Silver) |
| 8 | Skull (White) |

## Requirements

- World of Warcraft Retail (tested on 12.0.0)
- Must be raid leader or assistant to place world markers

## Notes

- Keybinds set through this addon do not appear in WoW's standard Key Bindings menu - they are managed entirely through the addon's settings panel
- The sequence automatically resets when you change options or clear all markers
- Marker cycling works in combat; sequence changes require being out of combat
