# Voldex Code Test

## Summary

### Special Thanks
I'd like to give special thanks to Ruizukun and Roblox for creating the 2 packages I used in the project!

- Thanks to Ruizukun for Janitor!
- Thanks to Roblox for TestEZ!

### Initial Thoughts
- Game seems to only have ~200 lines of code total. A lot of the code is quite messy, a lot of vulnerabilities regarding code sequencing and client telling server what to do. Most systems may need to be refactored.
- A lot of the general codebase for how things are stored are all over the place. It would be inefficient to do a complete revamp of the base system as unfortunate as that sounds. Might be worthful in the future overtime migrating to a more secure and organized database, but for just the code test and time constraints, I don't see it as necessary.

### Final Thoughts
- While I made quite a large some of changes, almost rewriting a lot of the code, I also reused much of the already set in stone codebase in terms of how pads and paycheck machines will function, where their data is stored, etc.
- I tried not to make too drastic changes from the base product as it deemed to be highly inefficient and would've made this process take much longer. I think it would be good to put in place something for replication to specific clients, this way the server doesn't have visuals to render in, best for server performance.
- Overall, I think the game is far more clean, far more secure, and far more expandable. As expandability is also a highly important aspect to game development.

### What did I do to put my personality to it?
#### Tool Giver
- I thought it would be quite unique to have a toolbase system added to the game for tool use!
- Tool Giving system is also easily expandable for any tool that people want to add!

#### Build Tool
- I thought this was a pretty funny idea the fact that you could click anywhere to make a building appear there haha!
- Buildings that are placed are set to random as it makes it feel more like magic in a way of the magic isn't always perfect.
- SEEABLE FROM MULTIPLAYER!

#### My thoughts on these additions
- While I could've gone a more custom and very likely more secure system by creating my own tool system, I feel as though this keeps it simple and within the time limit allocations.
- I feel like I over did this code test in so many different places, so I didn't really want to overcomplicate my own additions as much, but still wanted a little feature for people to enjoy!
- DID WANT TO MENTION. Buildings DO NOT appear on the server. HOWEVER, it is replicated to all clients, this way clients can see all of the buildings, watch it grow (tween animated on the server) without any hits on the server, nor having to deal with network ownership of the asset and such as well.

### General
#### Changes Implemented:
- Excited to say that the game is now multiplayer as welL! Up to 8 players!
- Cleaned up codebase to be structured in a much more collective manner.
- Added custom types, makes it easier  to know what objects are doing what and what information they hold!
- Server and client scripts now have a unionized system for running .Init() and .PlayerAdded()/.PlayerRemoving() functions. This leaves for a much cleaner and optimized codebase.
- Code has become much more secure through the use of sanity checks as much as possible. Making sure that every object that is used, has been accounted for and not lost when running a function accurately.

## Objects

### General
#### Changes Implemented:
- Changed the Money Display ScreenGui.ResetOnSpawn from true to false. We don't want ScreenGui to get reset when dying and have to deal with object missing bugs!
- Added Janitor objects for script connection cleanup.
- Pads now get billboardgui that will function correctly based off attributes given!
- Pads now get completely deleted so there isn't any left over objects in the workspace.

## Server

### Data
#### Changes Implemented:
- Saving is now possible.
- Added deepcopies for new player data tables. The current system doesn't do so, so all new players in the server will have the same exact data table.
- Data Pulling and Changing are now combined into general functions for each task.
- No current need to save paycheck amount. Even if player gets separate amounts based off multipliers, that should be calculated in game specifically, no need to take up player data bandwidth.
- When changing data on the server, you have the option to whitelist certain data types that when changed get fired to the client to listen in on.

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

### General
#### Changes Implemented:
- Removed random functions and listeners that didn't have any use or end goal.

### User Interface Handler
#### Changes Implemented:
- Player's money is grabbed on client runtime to get and change the display.
- Option to listen in for more than just money being updated, rather more data can now be tracked on the client when it gets updated as well!

### Paycheck Machines
#### Changes Implemented:
- Storing the debounce time for a more accurate time estimate, as well as not needing to call for time again.
- No need to create multiple loops just to get the same objects. Reuse the code! :D
- Realized later on that there's no need to listen for touch events on the client to send over to the server! Mistake! Fixed.

### Pads
#### Changes Implemented:
- Pads are listened in and automatically setup once they get added to the workspace.

### Sounds
#### Changes Implemented:
- Added a PlaySFXFromName remote to send a signal for the client to play a certain song from the server.
- Created a simple working sound system for sound effects to be played and removed, nothing too in-depth.

#### All Sound Effects:
- PaycheckMachine receiving noise
- Coin noise from money spending
- Building noise from building placement
(If sounds don't work, likely permissions aren't set)

## Things I Would Change About The Codebase I Implemented
#### Changes I'd Make:
- More in-depth systems rather than short-end, not as customizable based systems where we have unlimited posibility with what goes on. (e.g. tool system being a simple tool giver and roblox backpack versus player backpack with custom equips and custom tool usage events).
- Having error handling when it comes to sanity checks. If an object couldn't be found on a sanity check, there should be some sort of warning system or notification. Or even error analytics for us to track to know how many times it hits a breaking point on that side of things. (e.g. if not ( playerMoney ) then return end should be replaced with if not ( playerMoney ) then warn("Player Money could not be found") or some other in-depth warning system).