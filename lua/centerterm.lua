local M = {}
M.center_width = 120


local function create_blank_buffer(width)
  vim.cmd("vnew")
  vim.api.nvim_buf_set_option(0, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(0, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(0, 'swapfile', false)
  vim.api.nvim_win_set_width(0, width)
  vim.api.nvim_win_set_option(0, 'number', false)
  vim.api.nvim_win_set_option(0, 'relativenumber', false)
  vim.opt.fillchars:append("vert: ")
  vim.opt.fillchars:append({ eob = ' ' })
end


local function create_centered_buffer(width)
  local total_width = vim.o.columns
  if total_width < width + 2 then return false end
  local left_buffer_width = math.floor((total_width - width) / 2)
  local right_buffer_width = total_width - width - left_buffer_width
  local main_win = vim.api.nvim_get_current_win()

  create_blank_buffer(left_buffer_width)
  vim.cmd("wincmd l")
  vim.cmd("wincmd H")
  vim.api.nvim_set_current_win(main_win)
  create_blank_buffer(right_buffer_width)
  vim.cmd("wincmd l")
  vim.api.nvim_win_set_width(0, width)
  return true
end


local centered = false

function M.toggle_centered_buffer(width)
  if centered then
    vim.cmd("only")
    centered = false
  else
    centered = create_centered_buffer(width)
  end
end


function M.quit_vertical_split_and_toggle()
    vim.cmd("q")
    M.toggle_centered_buffer(M.center_width)
end


function M.vertical_split_and_toggle(width)
    M.toggle_centered_buffer(width)
    vim.cmd("vs")
end


function M.set_default_keybindings()
    local bind_opts = { noremap=true, silent=true }
    -- Toggle center
    vim.keymap.set("n", "<leader>cc",  "<cmd>Center<CR>", bind_opts)
    -- Vertical split with toggle center
    vim.keymap.set("n", "<leader>vs",  "<cmd>Vs<CR>", bind_opts)
    -- Close current split then toggle center
    vim.keymap.set("n", "<leader>vx", "<cmd>Vx<CR>", bind_opts)
end


local function setup_autocmd()
    vim.cmd([[
        augroup DetectVimResize
            autocmd! * <buffer>
            autocmd VimResized * Center
        augroup END
    ]])
end


local function set_vim_commands()
    vim.cmd(
    "command! Center lua require('centerterm')"..
    ".toggle_centered_buffer(vim.g.centerterm_width)"
    )
    -- Create new vertical split and toggle Center
    vim.cmd(
    "command! Vs lua require('centerterm')"..
    ".vertical_split_and_toggle(vim.g.centerterm_width)"
    )
    -- Quit current vertical split and toggle Center
    vim.cmd(
    "command! Vx lua require('centerterm')"..
    ".quit_vertical_split_and_toggle()"
    )
end


-- Initialize autocmds
function M.setup(opts)
    opts = opts or {}
    if opts.default_keybindings then
        M.set_default_keybindings()
    end
    if opts.center_width then
        M.center_width = opts.center_width
    end
    vim.g.centerterm_width = M.center_width
    -- Define the command to toggle the centered buffer
    set_vim_commands()
    setup_autocmd()
    -- Enable the centered buffer by default
    vim.cmd("autocmd VimEnter * Center")
    end

return M
