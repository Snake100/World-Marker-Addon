# Changelog

All notable changes to DropWorldMarker will be documented in this file.

## [1.0.2] - 2026-01-27

### Fixed
- Fixed markers not placing - corrected macro syntax to `/wm [@cursor] X`
- Fixed clear not working - corrected to `/cwm all`
- Fixed `/dwm config` command not opening settings panel
- Fixed `/dwm` and `/dwm clear` slash commands causing protected action errors
- Fixed double chat messages - use `RegisterForClicks("AnyUp")`
- Removed unused Bindings.xml (keybinds now handled programmatically)

### Added
- Debug mode checkbox in options to print macro commands to chat

## [1.0.1] - 2026-01-27

### Fixed
- Fixed world markers not placing - changed from invalid macro commands to proper `worldmarker` button type
- Fixed clear button not working - now uses correct `worldmarker` API with `action="clear"`
- Updated button click registration for proper worldmarker support

## [1.0.0] - 2026-01-27

### Added
- Initial release
- Place world markers at cursor position with a single keybind
- Cycle through user-configured marker sequence
- Customizable marker order via options panel (8 slots)
- Clear all markers keybind
- Chat message notifications (toggleable)
- Slash commands: `/dwm`, `/dwm clear`, `/dwm reset`, `/dwm config`
- Settings persist between sessions
