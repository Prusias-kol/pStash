# pStash
Thank you to Thoth19 providing the framework with clan_stash.ash. Without his regex, I would not have the willpower to make this script.

This script functions as a CLI interface to check and manage shared clan stashes.

To install, run   
```
git checkout https://github.com/Prusias-kol/pStash main
```   

## Key Features
- Tracks a set of valuable items that are commonly put in shared clan stashes
- Tracks your personal items that overlap with the aforementioned list. Will need to re-init every time you personally acquire an item that is in the list.
- View who most recently took out a missing item
- Return items you took from the stash

## TODO
Script has barebones support for duplicate items in stash if you're part of a wealthy clan. Currently would require the user to go into data/pStash and edit those files manually to account for multiple items when tracking. Returning does not support multiple items.