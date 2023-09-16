# centerterm.nvim

Yet another plugin for centering your editor in neovim.

- Do you have a wide monitor, and a terminal window that is wide enough that you  
find it uncomfortable to be constantly holding your gaze a bit to the left?
- Do you use a tiling window manager and sometimes rotate the GUI window with
your editor to a spot that shrinks the width?

You're in luck! This dinky little plugin--that probably has several gotchas that
I'm unaware of--is for you.

**Features**
- User-specified width for main editor split
- If specified width is exceeded, a new session will automatically center itself
- If your GUI window shrinks below the specified width, then the centering will
  be removed, and vice-versa

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

**Assumptions**
- One of the two conditions are true:
    + You have one split currently open
    + Three splits related to the centering are open and no others:
      two for side padding and one for your center view
- You havent done anything manually to mess with the toggled boolean state that
  indicates to the plugin whether or not centering is currently active.

This means things can get weird if you violate these assumptions.
I might work on improving that in a future version, but thus far this hasn't
caused me any problems with my own workflow.

**`:Vs`** will create a new vertical split of your center view, and destroy the
two outer splits.</br>

**Assumptions**
- Your center view is the active split when you run the command.
- You only have your center split and the two outer/padding splits open.
- You havent done anything manually to mess with the toggled boolean state that
  indicates to the plugin whether or not centering is currently active.


**`:Vx`** will quit the currently active vertical split and reactive the
centering effect.</br>

**Assumptions**
- Only two vertical splits are currently open
- You havent done anything manually to mess with the toggled boolean state that
  indicates to the plugin whether or not centering is currently active.

### Default Keybindings
- _`<leader>cc`_ runs `Center`
- _`<leader>vs`_ runs `Vs`
- _`<leader>vx`_ runs `Vx`
