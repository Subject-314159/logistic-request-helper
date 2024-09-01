# Logistic request helper

Adds a window (GUI) that allows you to quickly set logistic requests.

The lay-out of items in the GUI resembles the crafting pane and all items are on the same location, so that you can easily find them back.

Open by clicking the shortcut button or pressing either `ALT+L` or `SHIFT+E`. Mod settings available to attach it to the player crafting screen instead.

Features:

-   `Click` an item to add the item's stack size to your current logistic request amount
-   `Shift+Click` an item to subtract the item's stack size from your current logistic request amount
    -   `Shift+Click` an item with request 0 removes the request
    -   `Shift+Click` an item with no request sets a request at 0
-   `Right click` an item to immediately remove the request

# Demo

![demo](https://i.imgur.com/bJrUoM7.mp4)

---

# Known issues

-   Hovering over the request number on an icon doesn't make the button glow (won't fix, modding limitation)
-   When hovering from/to the request number the tooltip briefly disappears (won't fix, midding limitation)

# Roadmap

-   Internal optimization: Refactor code & act on on_entity_logistic_slot_changed instead of updating on_tick, where possible
-   Add GUI to logistic chests & vehicles
-   Add checkbox "enable personal logistic" as per main character and vehicle window
-   Auto-size the height of the GUI when attached to the crafting screen, if possible
-   Make GUI width more consistend when collapsing all groups

# Collaborations welcome

-   Start a discussion with your ideas
-   Open a pull request on Github
-   Report issues/bugs under discussions
