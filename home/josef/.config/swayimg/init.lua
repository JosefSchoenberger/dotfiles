-- Example config for Swayimg.
-- This file contains the default configuration used by the application.

-- The viewer searches for the config file in the following locations:
-- 1. $XDG_CONFIG_HOME/swayimg/init.lua
-- 2. $HOME/.config/swayimg/init.lua
-- 3. $XDG_CONFIG_DIRS/swayimg/init.lua
-- 4. /etc/xdg/swayimg/init.lua

-- General config
--swayimg.mode = "viewer"                -- mode at startup
--swayimg.antialiasing = true            -- anti-aliasing
--swayimg.decoration = true              -- window title/buttons/borders
swayimg.overlay = false                  -- window overlay mode
--swayimg.exif_orientation = true        -- image orientation by EXIF
--swayimg.dnd_button = "MouseRight"      -- drag-and-drop mouse button

-- Image list configuration
--swayimg.imagelist.order = "numeric"    -- list order
--swayimg.imagelist.reverse = false      -- reverse order
--swayimg.imagelist.recursive = false    -- recursive directory reading
--swayimg.imagelist.adjacent = false     -- add adjacent files from same dir
swayimg.imagelist.adjacent = false       -- add adjacent files from same dir
--swayimg.imagelist.fsmon = true         -- enable file system monitoring

-- Enable adjacent if exactly one file
swayimg.on_initialized(function() if swayimg.imagelist.size == 1 then swayimg.imagelist.add(swayimg.viewer.get_image().path:match '.+/') end end)

-- Text overlay configuration
--swayimg.text.font = "monospace"        -- font name
swayimg.text.size = 18                 -- font size in pixels
swayimg.text.spacing = -6               -- line spacing
swayimg.text.padding = 0              -- padding from window edge
--swayimg.text.color = 0xffcccccc   -- foreground text color
--swayimg.text.background = 0x00000000   -- text background color
--swayimg.text.shadow = 0x0d000000       -- text shadow color
--swayimg.text.timeout = 5               -- layer hide timeout
--swayimg.text.status_timeout = 3        -- status message hide timeout

-- Image viewer mode
--swayimg.viewer.default_scale = "optimal"      -- default image scale
--swayimg.viewer.default_position = "center"    -- default image position
--swayimg.viewer.drag_button = "MouseLeft"      -- mouse button to drag image
--swayimg.viewer.set_window_background(0xff000000) -- window background color
swayimg.viewer.set_image_chessboard(12, 0xff333333, 0xff4c4c4c) -- chessboard
--swayimg.viewer.autocenter = true            -- enable automatic centering
--swayimg.viewer.loop = true                 -- enable image list loop mode
swayimg.viewer.limit_preload = 10                  -- number of images to preload
swayimg.viewer.limit_history = 10                  -- number of the history cache
--swayimg.viewer.mark_color = 0xff808080        -- mark icon color
--swayimg.viewer.pinch_factor = 1.0             -- pinch gesture factor

swayimg.viewer.set_text("topleft", {             -- top left text block scheme
  "File: {name}",
  --"Format: {format}",
  "File size: {sizehr}",
  "Size: {frame.width}x{frame.height}",
  --"File time: {time}",
  "DateTime: {meta.DateTime}",
  --"EXIF camera: {meta.Exif.Image.Model}"
  "Shutter: {meta.Shutter}",
  "Aperture: {meta.Aperture}",
  "ISO: {meta.ISO}",
  "Focal Length: {meta.FocalLength}",
})

swayimg.viewer.set_text("topright", {            -- top right text block scheme
  "Image: {list.index} of {list.total}",
  "Frame: {frame.index} of {frame.total}"
})
swayimg.viewer.set_text("bottomleft", {          -- bottom left text block scheme
  "Scale: {scale}"
})

-- Key and mouse bindings in viewer mode (example only, not all):

swayimg.viewer.on_key("Escape", function() swayimg.exit() end)
swayimg.viewer.on_key("q", function() swayimg.exit() end)
swayimg.gallery.on_key("q", function() swayimg.exit() end)

function move(xPercent, yPercent)
  local wnd = swayimg.get_window_size()
  local pos = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(math.floor(pos.x + wnd.width * xPercent/100), math.floor(pos.y + wnd.height * yPercent/100));
end
swayimg.viewer.on_key("h", function() move( 10, 0) end)
swayimg.viewer.on_key("l", function() move(-10, 0) end)
swayimg.viewer.on_key("k", function() move(0,  10) end)
swayimg.viewer.on_key("j", function() move(0, -10) end)

function zoom(divisor)
  local pos = swayimg.get_mouse_pos()
  local scale = swayimg.viewer.scale
  scale = scale + scale / divisor
  swayimg.viewer.set_abs_scale(scale, pos.x, pos.y);
end
swayimg.viewer.on_mouse("ScrollUp", function() zoom(10) end)
swayimg.viewer.on_mouse("ScrollDown", function() zoom(-11) end)
swayimg.viewer.on_key("Plus", function() zoom(10) end)
swayimg.viewer.on_key("Minus", function() zoom(-11) end)
swayimg.viewer.on_key("z", function() swayimg.viewer.set_fix_scale("fit") end)
swayimg.viewer.on_key("Shift+z", function() swayimg.viewer.set_fix_scale("fill") end)
swayimg.viewer.on_key("Ctrl+z", function() swayimg.viewer.set_fix_scale("real") end)
swayimg.viewer.on_mouse("MouseMiddle", function() swayimg.viewer.set_fix_scale("fit") end)

swayimg.viewer.on_key("Left", function() swayimg.viewer.open("prev") end)
swayimg.viewer.on_key("Right", function() swayimg.viewer.open("next") end)
swayimg.viewer.on_mouse("MouseSide", function() swayimg.viewer.open("prev") end)
swayimg.viewer.on_mouse("MouseExtra", function() swayimg.viewer.open("next") end)
swayimg.viewer.on_key("r", swayimg.viewer.reload)

swayimg.viewer.on_key("i", function() swayimg.text.visible = true end);

swayimg.viewer.on_key("ISO_Level3_Shift", function() end)
swayimg.viewer.on_key("ISO_Level5_Shift", function() end)


-- Slide show mode, same config as for viewer mode with the following defaults:
--swayimg.slideshow.timeout = 5                    -- timeout to switch image
--swayimg.slideshow.default_scale = "fit"          -- default image scale
--swayimg.slideshow.window_background = "auto"     -- window background mode
--swayimg.slideshow.limit_history(0)                  -- number of the history cache
--swayimg.slideshow.set_text("topleft", { "{name}" }) -- top left text block scheme


-- Gallery mode
--swayimg.gallery.aspect = "fill"                  -- thumbnail aspect ratio
swayimg.gallery.thumb_size = 192                 -- thumbnail size in pixels
--swayimg.gallery.padding_size = 5                 -- padding between thumbnails
--swayimg.gallery.border_size = 5                  -- border size for selected thumbnail
--swayimg.gallery.border_color = 0xffaaaaaa        -- border color for selected thumbnail
--swayimg.gallery.selected_scale = 1.15            -- scale for selected thumbnail
--swayimg.gallery.selected_color = 0xff404040      -- background color for selected thumbnail
--swayimg.gallery.unselected_color = 0xff202020    -- background color for unselected thumbnail
--swayimg.gallery.window_color = 0xff000000        -- window background color
--swayimg.gallery.pinch_factor = 100.0             -- pinch gesture factor
--swayimg.gallery.limit_cache(100)                    -- number of thumbnails stored in memory
--swayimg.gallery.preload = false               -- preloading invisible thumbnails
--swayimg.gallery.pstore = false                -- enable persistent storage for thumbnails
--swayimg.gallery.set_text("topleft", {               -- top left text block scheme
--  "File: {name}"
--})
--swayimg.gallery.set_text("topright", {              -- top right text block scheme
--  "{list.index} of {list.total}"
--})

-- Key and mouse bindings in gallery mode (example only, not all):

-- bind Enter key to open image in viewer
--swayimg.gallery.on_key("Return", function()
--  swayimg.mode = "viewer"
--end)
-- bind the left arrow key to select thumbnail on the left side
--swayimg.gallery.on_key("Left", function()
--  swayimg.gallery.switch_image("left")
--end)

--
-- Other configuration examples
--

-- force set scale mode on window resize (useful for tiling compositors)
swayimg.on_window_resize(function()
  if swayimg.mode == "viewer" then
	swayimg.viewer.set_fix_scale("optimal")
  end
end)

-- set a custom window title in gallery mode
swayimg.gallery.on_image_change(function()
  local image = swayimg.gallery.get_image()
  swayimg.title = "Gallery: "..image.path
end)

-- print paths to all marked files by pressing Ctrl-p in gallery mode
swayimg.gallery.on_key("Ctrl-p", function()
  local entries = swayimg.imagelist.get()
  for _, entry in ipairs(entries) do
    if entry.mark then
        print(entry.path)
    end
  end
end)











--function dump(o, indent)
--	indent = indent or 1
--	if type(o) == 'table' then
--		local s = '{\n'
--		for k,v in pairs(o) do
--			if type(k) ~= 'number' then k = '"'..k..'"' end
--			if not k:match '.Sony' and not k:match '.MakerNote' then
--				s = s .. string.rep("  ", indent) .. '['..k..'] = ' .. dump(v, indent + 1) .. ',\n'
--			end
--		end
--		return s .. string.rep("  ", indent-1) .. '} '
--	else
--		return tostring(o)
--	end
--end

swayimg.viewer.on_image_change(function()
	local i = swayimg.viewer.get_image()
	local function fmt(name, key, prefix, suffix, default)
		if key and key:match '%.' then
			val = i[key] or default
		else
			val = i['Exif.Photo.' .. (key or name)] or i['Exif.Image.' .. (key or name)]
			if not val and i["meta"] then
				val = i.meta['Exif.Photo.' .. (key or name)] or i.meta['Exif.Image.' .. (key or name)]
			end
			if val == nil then
				val = default
			end
		end
		if not val then return end

		local a, b = val:match '^(%-?[0-9]+)/([0-9]+)$'
		local year, month, day, hour, minute, second = val:match '^([0-9]+):([0-9]+):([0-9]+) ([0-9]+):([0-9]+):([0-9]+)$'
		if a then
			local x, y = tonumber(a), tonumber(b)
			local n = x / y
			if math.floor(n) == n and n >= 1 then
				if n < 10 then
					val = string.format('%.1f', n)
				else
					val = n
				end
			elseif math.floor(n * 10) == n * 10 and n >= 1 then
				val = string.format('%.1f', n)
			elseif b:match '^10*$' and n >= 1 then
				val = string.format('%.2f', n)
			elseif a:match '^10*$' then
				val = string.format('1/%d', y / x)
			end
		elseif year then
			local year, month, day, hour, minute, second =  tonumber(year), tonumber(month), tonumber(day), tonumber(hour), tonumber(minute), tonumber(second)
			val = string.format('%02d.%02d.%d %02d:%02d:%02d', day, month, year, hour, minute, second)
		end

		val = (prefix or "") .. val .. (suffix or "")

		swayimg.viewer.set_meta("meta." .. name, val)
	end

	fmt('DateTime', 'DateTimeOriginal')
	fmt('Shutter', 'ExposureTime', nil, ' s')
	fmt('Aperture', 'FNumber', 'f/')
	fmt('ISO', 'ISOSpeedRatings')
	fmt('FocalLength', 'FocalLength', nil, ' mm')
end)
