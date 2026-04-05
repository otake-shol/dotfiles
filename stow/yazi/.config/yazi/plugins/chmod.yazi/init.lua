-- chmod.yazi - Interactive permission change for yazi
-- Usage: Select files, press 'cm' to change permissions

return {
	entry = function()
		local value, event = ya.input {
			title = "chmod (e.g. 755, +x, u+rw):",
			pos = { "top-center", y = 3, w = 40 },
		}

		if event ~= 1 or not value or value == "" then
			return
		end

		local selected = ya.sync(function()
			local files = {}
			for _, u in pairs(cx.active.selected) do
				files[#files + 1] = tostring(u)
			end
			-- If nothing selected, use hovered file
			if #files == 0 then
				local hovered = cx.active.current.hovered
				if hovered then
					files[#files + 1] = tostring(hovered.url)
				end
			end
			return files
		end)()

		if not selected or #selected == 0 then
			ya.notify {
				title = "chmod",
				content = "No files selected",
				level = "warn",
				timeout = 3,
			}
			return
		end

		local args = { value }
		for _, f in ipairs(selected) do
			args[#args + 1] = f
		end

		local child = Command("chmod")
			:args(args)
			:stdout(Command.PIPED)
			:stderr(Command.PIPED)
			:spawn()

		if child then
			local output = child:wait_with_output()
			if output and output.status.success then
				ya.notify {
					title = "chmod",
					content = string.format("Changed %d file(s) to %s", #selected, value),
					level = "info",
					timeout = 3,
				}
			else
				ya.notify {
					title = "chmod",
					content = "Failed: " .. (output and output.stderr or "unknown error"),
					level = "error",
					timeout = 5,
				}
			end
		end
	end,
}
