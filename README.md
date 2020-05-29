# st-history / st-vim-browse
History patch for `st`, which
1. Maintains two distinct cursor positions for inserting new content and viewing old content.
2. Keeps the interface to the line buffer unchanged, and hence is supposed to yield less merge
   conflicts
3. Separates the history logic and the scroll-back implementation in different patches, allowing to
   use the patch with a custom / more sophisticated scroll-back logic (like the `vim browse` patch).

This patch can be used in combination with the `st-vim-browse` patch, which is a sophisticated
scroll-back patch operating on top of the history functionality and is also developed in this
repository. The vim patch provides >50 vim-like motions & operators and a search & info overlay.
Documentation on how this patch is used can be found:
1. in the source code of `normalMode.c`: function `kpressHist()` -> `executeMotion()`,
2. in the Wiki, or
3. at the [Suckless release page](https://st.suckless.org/patches/vim_browse/).

# Patches
In this repository I develop the following separate patches on corresponding branches
1. `historyVanilla`: essential history patch which provides logic and utility functionality for
   moving through the terminal history.
2. `patch_scrollback`: simple bindings which allows the user to use the `historyVanilla` patch.
3. `patch_sel` rewrites the selection routine, allowing for a selection larger than the currently
   displayed chunk of the buffer.
4. `patch_column`: when shrinking the width of the window, invisible content is kept instead of
   removed, such that it becomes visible when the width is increased again.
5. `patch_repaint` visualizes new line-repaint-events via a distinct color in a color column.
   This comes in handy when debugging / developing a custom `scroll-back` functionality.
6. `patch_vim`: offers vim-like motions for moving through the history, yanking text and searching.

# Assembling the latest patches
The script `release.sh` on branch `master` / `tool` assembles the latest versions of all patches
and provides them in a newly created patches directory.
It generates (1) a raw patch for each branch, and (2) meta-patches for useful combinations of the
patches provided above.
```bash
./release.sh 1 1
```

# History buffer implementation
The interface to the buffer `term.line` is kept unchanged and points to a chunk inside a history
round-buffer; changes are hence limited only to very few functions.
When inspecting history or scrolling down, the position of the chunk is changed.
Therefore, functions which operate in the history buffer are 'annotated' to trigger a `history
Operation`.
The `vanilla history patch` provides utility function for conveniently moving through history.

# Authors
Julius Hülsmann - <juliusHuelsmann [at] gmail [dot] com>
