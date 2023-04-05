# Voldex Code Test

## Summary
### Initial Thoughts
- Game seems to only have ~200 lines of code total. A lot of the code is quite messy, a lot of vulnerabilities regarding code sequencing and client telling server what to do. Most systems may need to be refactored.

### General
#### Changes Implemented:
- Cleaned up codebase to be structured in a much more collective manner.
- Added custom types, makes it easier  to know what objects are doing what and what information they hold!

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

### Pads
#### Changes Implemented:
- Removing event signals just to fire a function within the same module, unnecessary.
- Cleaned up for loop in terms of use and specified which for loop that's being used. While it's not necessary to add pairs/ipairs, it's best to for code cleanliness and readability.
- Code order of operations is completely in the wrong order. Before changes: Pad is set to finished before player's funds are subtracted, and player's funds are never checked to see if they have enough.

## Client

### Paycheck Machines
#### Changes Implemented:
- Storing the debounce time for a more accurate time estimate, as well as not needing to call for time again.
- No need to create multiple loops just to get the same objects. Reuse the code! :D
- Realized later on that there's no need to listen for touch events on the client to send over to the server! Mistake! Fixed.