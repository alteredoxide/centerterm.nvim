# centerterm.nvim

Yet another plugin for centering your editor in neovim.

- Do you have a wide monitor and a terminal window that is wide enough that you  
find it uncomfortable to be constantly holding your gaze a bit to the left?
- Do you use a tiling window manager and sometimes rotate the GUI window with
your editor to a spot that shrinks the width?

You're in luck! This dinky little plugin--that probably has several gotchas that
I'm unaware of--is for you.

**Features**
- User-specified total width for all centered content.
- Automatic re-centering that operates as you create and destroy windows/splits,
  or grow/shrink the terminal window.
  - Whenever total width is less than specified center width + 2, centering is
    removed until that width is exceeded.
- Works with multiple open windows: the padding remains on the outside.

## Installation
### Packer
Add the following to your `packer.lua` file:
```lua
use 'alteredoxide/centerterm.nvim'
```
Add the following either to `init.lua` or `nvim/after/plugin/centerterm.lua`:
```lua
local centerterm = require('centerterm').setup({
    default_keybindings = true, -- things like <leader>cc to toggle center
    center_width = 120 -- specify column width of center split
})
```

## Usage
### Commands
**`:Center`** will toggle the centering effect.</br>

_Assumptions_
- You haven't done anything manually to mess with the toggled boolean state that
  indicates to the plugin whether or not centering is currently active.

**`:CenterOn`** Enables auto-centering (default). This means that as you do
things within neovim, such as resizing, splitting, closing, etc., centerterm
will automatically keep your neovim windows within your terminal centered.
Having this on is also required in order for the padding windows to close
automatically when you close your last non-padding window.

**`:CenterOff`** Disables auto-centering. Do this if you need to make some
manual adjustments or if auto-centering is interacting badly with another
plugin.

**`:CenterSet`** Sets the current window as the "main" window. This is not yet
entirely useful, though it can be handy for having to make some manual
adjustments after disabling auto-centering.

**`:Recenter`** Destoys the current padding windows and re-centers everything.
This is also not necessarily very useful at the moment.

**`:Vs`** will create a new vertical split of your center view, and destroy the
two outer splits.</br>

_Assumptions_
- See assumption for `:Center`


**`:Vx`** will quit the currently active window and reactivate the
centering effect.</br>

_Assumptions_
- See last assumption for `:Center`

The next couple commands aren't custom, but they are useful.
**`:wqa`** write and quit all -- convenient to close all splits when centered.
**`:qa`** or **`:qa!`** are the `q` and `q!` equivalents to `wqa`.

**NOTE:** if you have a single window centered _and_ auto-centering is enbabled,
then running `:q` on the main window will close the padding and exit.

### Default Keybindings
- `<leader>cc` runs `Center`
- `<leader>rr` runs `Recenter`
- `<leader>vs` runs `Vs`
- `<leader>vx` runs `Vx`
