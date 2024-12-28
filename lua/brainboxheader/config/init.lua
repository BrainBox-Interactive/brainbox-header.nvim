local M = {}

M.opts = {
  length = 100,
  margin = 5,
  default_map = true,
  auto_update = true,
  user = "username",
  mail = "your@mail.com",
  asciiart = {
    "#########################",
    "#########################",
    "###                   ###",
    "###     #########     ###",
    "########         ########",
    "###                   ###",
    "###    ##             ###",
    "###     ##            ###",
    "###     ##            ###",
    "###                   ###",
    "#########################",
    "#########################",
  },
  asciibrainbox = {
    "____________  ___  _____ _   _ ______  _______   __",
    "| ___ \\ ___ \\/ _ \\|_   _| \\ | || ___ \\|  _  \\ \\ / /",
    "| |_/ / |_/ / /_\\ \\ | | |  \\| || |_/ /| | | |\\ V / ",
    "| ___ \\    /|  _  | | | | . ` || ___ \\| | | |/   \\ ",
    "| |_/ / |\\ \\| | | |_| |_| |\\  || |_/ /\\ \\_/ / /^\\ \\",
    "\\____/\\_| \\_\\_| |_/\\___/\\_| \\_/\\____/  \\___/\\/   \\/",
  },
  git = {
    enabled = false,
    bin = "git",
    user_global = true,
    email_global = true,
  },
}

---Applies the user options to the default table.
---@param opts table: settings
M.set = function(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M
