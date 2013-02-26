local awful     = require "awful"
local beautiful = require "beautiful"
local naughty   = require "naughty"
local vicious   = require "vicious"
local wibox     = require "wibox"

-- {{{ Widgets
local function format_str(value, color)
    return string.format('<span font="%s" color="%s">%s</span>',
                         beautiful.widget_font, color, value)
end

local function format_kv(label, value)
    local res = ''
    if label then
        res = res .. format_str(label, beautiful.fg_widget_label)
    end
    if value then
        res = res .. format_str(value, beautiful.fg_widget_value)
    end
    return res
end

local separator = wibox.widget.textbox()
separator:set_markup(' <span color="' .. beautiful.fg_widget_sep .. '" size="small">⋆</span> ')

local batwidget = { widget = wibox.widget.textbox() }
vicious.register(batwidget.widget, vicious.widgets.bat,
    function (widget, args)
        local color = beautiful.fg_widget_value
        local state = args[1]   -- battery state
        local level = args[2]   -- currenty battery charge level
        if level < 10 and state == '-' then
            batwidget.lastid = naughty.notify({
                title = "Battery low!",
                preset = naughty.config.presets.critical,
                timeout = 20,
                text = "Battery level is currently " .. level .. "%.\n" ..
                       args[3] .. " left before running out of power.",
                replaces_id = batwidget.lastid
            }).id
        end
        return format_kv('Bat: ', level .. "%");
    end,
    61, "BAT0"
)

local cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, format_kv("CUP: ", "$1%"))

local datewidget = wibox.widget.textbox()
vicious.register(datewidget, vicious.widgets.date, format_str("%a %m/%d %R", beautiful.fg_widget_clock), 30)

local memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, format_kv("Mem: ", "$1%"), 13)

local volwidget = wibox.widget.textbox()
vicious.register(volwidget, vicious.widgets.volume, format_kv("$2 ", "$1%"), 2, "PCM")
-- }}}

-- {{{ Wibox

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({
        screen = s,
        fg = beautiful.fg_normal,
        bg = beautiful.bg_widget,
        position = "top",
        height = 14
    })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mylayoutbox[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(separator)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(separator)
    right_layout:add(volwidget)
    right_layout:add(separator)
    right_layout:add(cpuwidget)
    right_layout:add(separator)
    right_layout:add(memwidget)
    right_layout:add(separator)
    right_layout:add(batwidget.widget)
    right_layout:add(separator)
    right_layout:add(datewidget)
    right_layout:add(separator)
    if s == 1 then right_layout:add(wibox.widget.systray()) end

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}
