# Voldex Code Test

## Summary

## Objects

### General
#### Changes Implemented:
- Changed the Money Display ScreenGui.ResetOnSpawn from true to false. We don't want ScreenGui to get reset when dying and have to deal with object missing bugs!
- Added Janitor objects for script connection cleanup.

## Server

### General
#### Changes Implemented:
- PlayerAdded signal listener is all centralized to the Server.server.lua script.

### Data
#### Changes Implemented:
- Saving is now possible.
- Added deepcopies for new player data tables. The current system doesn't do so, so all new players in the server will have the same exact data table.
- Data Pulling and Changing are now combined into general functions for each task.
- No current need to save paycheck amount. Even if player gets separate amounts based off multipliers, that should be calculated in game specifically, no need to take up player data bandwidth.

### Paycheck
#### Changes Implemented:
- Transitioned the RequestPaycheck RemoteFunction to a module function, callable from any code. This way, we can force players to take their money in anyway. (e.g. gamepasses, limit reach, etc.)
- Removed vulnerability with adding currency to the player that was read from the client.

## Client

### Paycheck Machines
#### Changes Implemented:
- Storing the debounce time for a more accurate time estimate, as well as not needing to call for time again.
-