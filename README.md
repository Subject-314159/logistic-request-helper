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

-   Only one specific request amount can be displayed/set
-   Request amount can't be set to 'infinite'
-   Updating the logistic request from the character window doesn't update the GUI while the GUI is open
    -   Containment: Close and open
-   Changing the mod settings while the GUI is open might not display it in the correct location
    -   Containment: Close both the GUI and character crafting screen
-   Changing the anchor position might not work
    -   Containment: Untoggle the "anchor" setting, open/close the GUI, toggle the "anchor" setting

Roadmap:

-   Add option to set min/max request separately
-   Add min/max request amount numbers in the GUI
-   Auto update GUI when updating the logistic requests from the character window
-   Improve GUI location handling and shortcut button toggling
