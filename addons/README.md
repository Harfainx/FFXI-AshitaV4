# My Addons

## ChatLog ##

| Created by | [Harfainx](https://github.com/Harfainx) |
| :--- | :--- 
| Version | 2.1.1 |

** Information **

A floating chat logger that can be customized in size, color, and filters. Does not currently capture unity messages, and probably some others.

- Drag and drop to your location of choice
- Adjust size by grabbing the bottom or sides
- Right click the top bar to select filters
- Menus to customize just about everything
- Position, inventory, experience, JP, and merit counts are available
- Auto blocking messages in the game's window logs has been enabled with a new "Log Blocking" tab for Limit Points, EXP, Capacity Points, Gil, Merit Points, Job Points, EXP/CP/LP Chains, each type of chat, system messages, RoE messages, and Sparks of Eminence messages. No need to disable anything manually in game (Big thanks to Genesis for the blocking logic in RoEBeGone)

| Screenshot | |
| :--- | :--- 
| Main window | ![Main Window](/images/ChatLog/ChatLog-Main.png) |
| Appearance Settings | ![Settings](/images/ChatLog/ChatLog-Settings.png) |
| Color Settings | ![Chat Colors](/images/ChatLog/ChatLog-ChatColors.png) |
| Log Blocking Settings | ![Chat Colors](/images/ChatLog/ChatLog-LogBlocking.png) |

## ItemLog ##

| Created by | [Harfainx](https://github.com/Harfainx) |
| :--- | :--- 
| Version | 1.0.0 |

** Information **

A floating item logger that watches inventory, treasure pool, and recent drops.

- Drag and drop to your location of choice
- Adjust size by grabbing the bottom or sides
- Right click the top bar to select option
- Menu to customize just about everything
- Pool only shows when active to save space, and always shows everything in it (dynamically expands)
- Item drop history can be adjusted 1-50
- Game log window blocking for Item Drop and Item Obtained messages

| Screenshot | |
| :--- | :--- 
| Main | ![Main Window](/images/ItemLog/ItemLog-MainAndSettings.png) |

-----

# Information for updated addons

## Blusets for Ashita V4

**Source Information**
| Created by | [Atom0s](https://github.com/atom0s) |
| :--- | :--- 
| Hosted at | [AshitaV4 Github](https://github.com/AshitaXI/Ashita-v4beta/tree/main/addons/blusets) |
| Version | 1.2 |

**Changes**
- Corrected an issue where the spells wouldn't always be added. There is a bug where it routinely fails to set a spell, then moves on to the next one

| File | Change(s) |
| :--- | :--- |
| blusets\blu.lua | Line 295-297 - Updated and now lines 295-302 |
| blusets\blusets.lua | Lines 152-153 - New scrpt at lines 152-175 |

## Simplelog for Ashita V4

**Source Information**
| Created by | [Spike2D](https://github.com/Spike2D) |
| :--- | :--- |
| Hosted at | [Spike2D Github](https://github.com/Spike2D/SimpleLog) |
| Version | 1.1 |

**Changes**
- Fixed the script to check and not crash or drop

| File | Change(s) |
| :--- | :--- |
| simplelog\lib\actionhandlers.lua | Lines 944-948 - Updated script for full fix |
