local M = {}
M.auto_center = true
M.center_width = 120
M.main_id = vim.api.nvim_get_current_win()
M.left_id = nil
M.right_id = nil
M.centering = false
M.centered = false


local function is_padding_win(win)
    if win == M.left_id or win == M.right_id then
        return true
    else
        return false
    end
end


-- return the first win id that is not one of the padding windows
local function get_first_non_padding_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if not is_padding_win(win) then
            return win
        end
    end
end


function M.set_current_as_main()
    M.main_id = vim.api.nvim_get_current_win()
end


function M.get_main()
    if M.main_id ~= nil then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if win == M.main_id then
                return M.main_id
            end
        end
    end
    M.main_id = get_first_non_padding_win()
    return M.main_id
end


local function create_blank_buffer(pos)
    vim.cmd("vnew")
    vim.api.nvim_buf_set_option(0, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(0, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(0, 'swapfile', false)
    vim.api.nvim_win_set_option(0, 'number', false)
    vim.api.nvim_win_set_option(0, 'relativenumber', false)
    vim.opt.fillchars:append("vert: ")
    vim.opt.fillchars:append({ eob = ' ' })
    vim.cmd(string.format("wincmd %s", pos))
    return vim.api.nvim_get_current_win()
end


local function create_centered_buffer(width)
    local total_width = vim.o.columns
    if total_width < width + 2 then
      return false
    end
    local left_buffer_width = math.floor((total_width - width) / 2)
    local right_buffer_width = total_width - width - left_buffer_width

    -- right padding
    M.right_id = create_blank_buffer("L")
    -- left padding
    M.left_id = create_blank_buffer("H")

    vim.api.nvim_win_set_width(M.right_id, right_buffer_width)
    vim.api.nvim_win_set_width(M.left_id, left_buffer_width)
    vim.api.nvim_set_current_win(M.get_main())

    return true
end


function M.silent_close_windows(window_ids)
    for _, win in ipairs(window_ids) do
        local _, err = pcall(function()
            vim.api.nvim_win_close(win, false)
        end)
        if err then
            print(win, err)
        end
    end
end


function M.toggle_center(width)
    if M.centered then
        M.silent_close_windows({M.left_id, M.right_id})
        M.left_id = nil
        M.right_id = nil
        vim.api.nvim_set_current_win(M.get_main())
        M.centered = false
    else
        M.centered = create_centered_buffer(width)
    end
end


function M.quit_vertical_split_and_toggle()
    vim.cmd("q")
    M.toggle_center(M.center_width)
end


function M.vertical_split_and_toggle(width)
    M.toggle_center(width)
    vim.cmd("vs")
end


-- recenter all content
function M.recenter()
    M.centering = true
    if M.left_id ~= nil then
        vim.api.nvim_set_current_win(M.left_id)
        vim.cmd("q")
        M.left_id = nil
    end
    if M.right_id ~= nil then
        vim.api.nvim_set_current_win(M.right_id)
        vim.cmd("q")
        M.right_id = nil
    end
    M.centered = false
    M.toggle_center(M.center_width)
    M.centering = false
end


local function get_centered_width()
    local total_width = vim.o.columns
    local left_width = 0
    local right_width = 0
    if M.left_id ~= nil then
        left_width = vim.api.nvim_win_get_width(M.left_id)
    end
    if M.right_id ~= nil then
        right_width = vim.api.nvim_win_get_width(M.right_id)
    end
    return total_width - (left_width + right_width)
end


function M.do_on_resize()
    if not M.auto_center or M.centering then
        return
    end
    if M.center_width ~= get_centered_width() then
        M.recenter()
    end
end


function M.set_default_keybindings()
    local bind_opts = { noremap=true, silent=true }
    -- Toggle center
    vim.keymap.set("n", "<leader>cc",  "<cmd>Center<CR>", bind_opts)
    -- Recenter
    vim.keymap.set("n", "<leader>rr",  "<cmd>Recenter<CR>", bind_opts)
    -- Vertical split with toggle center
    vim.keymap.set("n", "<leader>vs",  "<cmd>Vs<CR>", bind_opts)
    -- Close current split then toggle center
    vim.keymap.set("n", "<leader>vx", "<cmd>Vx<CR>", bind_opts)
end


local function setup_autocmd()
    vim.cmd([[
        augroup DetectVimResize
            autocmd! * <buffer>
            autocmd WinResized * lua require('centerterm').do_on_resize()
        augroup END
    ]])
end


local function set_vim_commands()
    vim.cmd(
    "command! Center lua require('centerterm')"..
    ".toggle_center(vim.g.centerterm_width)"
    )
    -- Activate auto-center
    vim.cmd(
    "command! CenterOn lua require('centerterm')"..
    ".auto_center = true"
    )
    -- Deactivate auto-center
    vim.cmd(
    "command! CenterOff lua require('centerterm')"..
    ".auto_center = false"
    )
    -- Recenter the main window after closing all others
    vim.cmd(
    "command! Recenter lua require('centerterm')"..
    ".close_others_and_recenter()"
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
    -- Set current window as main
    vim.cmd(
    "command! CenterSet lua require('centerterm')"..
    ".set_current_as_main()"
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
