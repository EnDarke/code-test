# Voldex Code Test

## Summary

## Server
#### Changes Implemented:
- PlayerAdded signal listener is all centralized to the Server.server.lua script.

### DataSystem
#### Changes Implemented:
- Saving is now possible.
- Added deepcopies for new player data tables. The current system doesn't do so, so all new players in the server will have the same exact data table.
- Data Pulling and Changing are now combined into general functions for each task.

## Client