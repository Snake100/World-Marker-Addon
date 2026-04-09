# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DropWorldMarker is a World of Warcraft addon that allows placing world markers (raid flares) at the cursor position with a single keybind, cycling through user-selected markers.

## WoW Addon Architecture

**File Structure:**
- `DropWorldMarker.toc` - Addon manifest (interface version 120001 for 12.0.1, metadata, file load order)
- `Core.lua` - Main addon logic, secure buttons, slash commands
- `Options.lua` - Settings panel using the Dragonflight Settings API
- `CHANGELOG.md` - Version history for CurseForge
- `pkgmeta.yaml` - CurseForge packager configuration (project ID: 1445999)

**NOTE:** We do NOT use `Bindings.xml` - keybinds are handled programmatically via `SetBindingClick()` in Options.lua

**Key Concepts:**
- World markers (flares) are placed using macro commands: `/wm [@cursor] X` (where X is marker 1-8)
- Clear all markers: `/cwm all`
- Keybindings are set programmatically with `SetBindingClick(key, "ButtonName", "LeftButton")`
- Saved variables persist between sessions via `SavedVariables` in .toc and the `ADDON_LOADED` event
- Protected actions cannot be called during combat (`InCombatLockdown()` check required)

## Development

**Testing the addon:**
1. Copy the addon folder to `World of Warcraft\_retail_\Interface\AddOns\DropWorldMarker`
2. Restart WoW or `/reload` if already logged in
3. Use `/dwm config` to open settings and set keybinds

**Interface version:** Update `## Interface:` in .toc when WoW patches (current: 120001 for 12.0.1)

**Slash commands:** `/dwm`, `/dwm place`, `/dwm clear`, `/dwm reset`, `/dwm config`

**Releasing to CurseForge:**
- Releases are automated via CurseForge webhook (configured in GitHub repo settings)
- To release: `git tag v1.0.X && git push origin v1.0.X`
- CurseForge auto-packages tagged commits; untagged pushes are ignored
- Version in tag determines release version on CurseForge

## Known Issues & Solutions

### Issue: Invalid macro commands
- **WRONG:** `/wm 1 [@cursor]` - number before modifier doesn't work
- **CORRECT:** `/wm [@cursor] 1` - modifier BEFORE the marker number
- **WRONG:** `/cwm 0` or `/clearworldmarker 0`
- **CORRECT:** `/cwm all`

### Issue: SecureHandlerWrapScript errors (RESOLVED)
- Error: `Invalid 'header' frame handle` - was caused by old Bindings.xml conflicts
- **Solution:** `SecureHandlerWrapScript()` DOES work correctly for cycling. The errors were from other issues (Bindings.xml). Use `SecureHandlerWrapScript(button, "PreClick", button, [[...]])` for combat-safe cycling.

### Issue: Can't combine templates
- Error: `CreateFrame(): Couldn't find inherited node "SecureActionButtonTemplate,SecureHandlerTemplate"`
- **Solution:** Just use `SecureActionButtonTemplate` alone - the `_preclick` attribute works without SecureHandlerTemplate

### Issue: Double chat messages
- Caused by `RegisterForClicks("AnyUp", "AnyDown")` firing on both press and release
- **Solution:** Use `RegisterForClicks("LeftButtonDown", "LeftButtonUp")` or just `"AnyDown"`

### Issue: type="worldmarker" shows targeting reticle
- Using `type="worldmarker"` with `action="set"` shows a reticle requiring extra click
- **Solution:** Use `type="macro"` with `macrotext="/wm [@cursor] X"` instead

### Issue: Slash commands can't execute protected actions
- `button:Click("LeftButton")` from Lua code is insecure and won't run protected macros
- **Solution:** Slash commands will show error; users must use keybinds for placing/clearing markers

### Issue: Settings.OpenToCategory() fails with string argument
- Error: `bad argument #1 to 'OpenSettingsPanel' (outside of expected range)`
- **Solution:** Store the category object when registering in Options.lua (`addon.settingsCategory = category`) and use `Settings.OpenToCategory(addon.settingsCategory:GetID())` in Core.lua

### Issue: RegisterForClicks behavior
- `"AnyDown"` or `"LeftButtonDown"` - macro doesn't execute
- `"LeftButtonDown", "LeftButtonUp"` - works but fires TWICE
- `"AnyUp", "AnyDown"` - works but fires TWICE
- `"LeftButtonUp"` - works but no cycling with SecureHandlerWrapScript
- `"AnyUp"` - works correctly with SecureHandlerWrapScript for cycling
- **Solution:** Use `RegisterForClicks("AnyUp")` with `SecureHandlerWrapScript`

### Issue: Keybinds stop working (ActionButtonUseKeyDown CVar) - RESOLVED April 2026
- **Symptom:** Keybinds suddenly stop placing/clearing markers, but `/wm [@cursor] 1` works when typed manually in a macro
- **Cause:** The `ActionButtonUseKeyDown` CVar (Options > Combat > Cast on Key Down) affects SecureActionButtonTemplate. If CVar is enabled (key down) but button only registers for "AnyUp", the action won't fire.
- **Solution:** Set `button:SetAttribute("useOnKeyDown", false)` to override the CVar per-button. This attribute was added in patch 11.1.5 to allow per-button control.
- **IMPORTANT:** Do NOT register for both "AnyUp" and "AnyDown" as this causes double-firing. Use `useOnKeyDown` attribute + `RegisterForClicks("AnyUp")` only.

## API Reference

**Macro Commands (WoW 12.0):**
- `/wm [@cursor] X` - Place world marker X (1-8) at cursor position
- `/cwm all` - Clear all world markers

**Secure Button Setup:**
```lua
local btn = CreateFrame("Button", "MyButton", UIParent, "SecureActionButtonTemplate")
btn:SetAttribute("type", "macro")
btn:SetAttribute("macrotext", "/wm [@cursor] 1")
btn:SetAttribute("useOnKeyDown", false) -- Override ActionButtonUseKeyDown CVar
btn:RegisterForClicks("AnyUp")
```

**Marker indices:** 1=Square(Blue), 2=Triangle(Green), 3=Diamond(Purple), 4=Cross(Red), 5=Star(Yellow), 6=Circle(Orange), 7=Moon(Silver), 8=Skull
