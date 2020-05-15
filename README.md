# st-history
History patch for `st`, which
1. Maintains two distinct cursor positions for inserting new content and viewing old content.
2. Keeps the interface to the line buffer unchanged, and hence is supposed to yield less merge
   conflicts
3. Separates the history logic and the scroll-back implementation in different patches, allowing to
   use the patch with a custom / more sophisticated scroll-back logic (like the `vim browse` patch).

# Patches
This repository contains the following separate patches on corresponding branches
1. `historyVanilla`: essential history patch which provides logic and utility functionality for
   moving through the terminal history.
2. `patch_scrollback`: simple bindings which allows the user to use the `historyVanilla` patch.
3. `patch_sel` rewrites the selection routine, allowing for a selection larger than the currently
   displayed chunk of the buffer.
4. `patch_column`: when shrinking the width of the window, invisible content is kept instead of
   removed, such that it becomes visible when the width is increased again.
5. `patch_repaint` visualizes new line-repaint-events via a distinct color in a color column.
   This comes in handy when debugging / developing a custom `scroll-back` functionality.

The master branch holds the current version of all separate patches merged together.

# History buffer implementation
The interface to the buffer `term.line` is kept unchanged and points to a chunk inside a history
round-buffer; changes are hence limited only to very few functions.
When inspecting history or scrolling down, the position of the chunk is changed.
Therefore, functions which operate in the history buffer are 'annotated' to trigger a `history
Operation`.
The `vanilla history patch` provides utility function for conveniently moving through history.

# Authors
Julius Hülsmann - <juliusHuelsmann [at] gmail [dot] com>
