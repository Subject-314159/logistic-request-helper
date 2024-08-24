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

Known issues:

-   Only one specific request amount can be set

Roadmap:

-   Add option to set min/max request separately
-   Add checkbox "enable personal logistic" as per main character window
-   Add expand/collapse button per group
