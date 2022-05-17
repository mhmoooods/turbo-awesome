local naughty = require "naughty"
local awful = require "awful"
local beautiful = require "beautiful"
local gears = require "gears"

local DEFAULT = 30
local current = DEFAULT
local muted = false
local notif_id

local function send_notif(from_toggle_mute)
    local icon, text

    -- If audio is being muted then use the mute icon.
    if from_toggle_mute and muted then
        icon = beautiful.icons.volume.mute
        text = "Muted"
    else
        -- Otherwise just show the current volume and
        -- appropriate icon.
        text = "Volume: " .. current .. "%"
        if current >= 75 then
            icon = beautiful.icons.volume.high
        elseif current >= 25 and current < 75 then
            icon = beautiful.icons.volume.medium
        else
            icon = beautiful.icons.volume.low
        end
    end

    -- Send notification and update notif_id
    notif_id = naughty.notify({
        title = "Audio",
        text = text,
        icon = icon,
        icon_size = 35,
        -- TODO: Get light icons, and invert the colors so that bg = black, fg =
        -- accent, border_color = accent
        bg = beautiful.colors.accent,
        fg = beautiful.colors.black,
        border_width = 2,
        border_color = beautiful.colors.alt_black,
        shape = function(cr, x, y) return gears.shape.rounded_rect(cr, x, y, 5) end,
        replaces_id = notif_id
    }).id
end

-- Calls amixer command to set Master volume to val.
local function set_volume(val)
    current = val
    awful.spawn("amixer set Master " .. val .. "%")
end

-- Increments current volume by 5% and sends a notification.
local function volume_up()
    set_volume(current + 5)
    send_notif(false)
end

-- Decrements current volume by 5% and sends a notification.
local function volume_down()
    set_volume(current - 5)
    send_notif(false)
end

-- Toggles between mute.
local function toggle_mute()
    if muted then
        awful.spawn("amixer set Master unmute")
        muted = false
    else
        awful.spawn("amixer set Master mute")
        muted = true
    end

    send_notif(true)
end

-- Make sure it's unmuted on startup.
awful.spawn("amixer set Master unmute")
-- Set volume to default value on startup.
set_volume(DEFAULT)

return {
    volume_up = volume_up,
    volume_down = volume_down,
    toggle_mute = toggle_mute
}

