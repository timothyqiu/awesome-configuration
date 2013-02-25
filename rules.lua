local awful     = require "awful"
local beautiful = require "awful"
awful.rules = require "awful.rules"

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Chromium to always map on tags number 1 of screen 1.
    { rule = { class = "Chromium" },
      properties = { tag = tags[1][1] } },
    -- Set Flash fullscreen window to float
    { rule = { class = "Exe" },
      properties = { floating = true } },
}
-- }}}
