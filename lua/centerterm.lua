local M = {}

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

function M.vertical_split_and_toggle(width)
    M.toggle_centered_buffer(width)
    vim.cmd("vs")
end

--local function setup_autocmd()
--    vim.cmd([[
--        augroup DetectVimResize
--        autocmd! * <buffer>
--    ]]..
--    "autocmd VimResized * lua require('centerterm')"..
--    ".toggle_centered_buffer(vim.g.centerterm_width)"..
--    [[
--        augroup END
--    ]]
--)
--end

local function setup_autocmd()
  vim.cmd([[
    augroup DetectVimResize
      autocmd! * <buffer>
      autocmd VimResized * lua require('centerterm').toggle_centered_buffer(vim.g.centerterm_width)
    augroup END
  ]])
end

-- Initialize autocmds
function M.setup()
    setup_autocmd()
end

return M

