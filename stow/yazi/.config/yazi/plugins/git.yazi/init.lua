-- git.yazi - Git status integration for yazi
-- Shows git status indicators (M/A/D/?) in the file list

local function git_status()
	local cwd = cx.active.current.cwd
	if not cwd then return {} end

	local child = Command("git")
		:args({ "-C", tostring(cwd), "status", "--porcelain", "-unormal" })
		:stdout(Command.PIPED)
		:stderr(Command.NULL)
		:spawn()

	if not child then return {} end

	local output, _ = child:wait_with_output()
	if not output or not output.status.success then return {} end

	local statuses = {}
	for line in output.stdout:gmatch("[^\n]+") do
		local status = line:sub(1, 2)
		local name = line:sub(4)
		-- Handle renamed files (old -> new)
		local arrow = name:find(" -> ")
		if arrow then
			name = name:sub(arrow + 4)
		end
		-- Remove trailing slash for directories
		name = name:gsub("/$", "")
		-- Get basename
		local basename = name:match("[^/]+$") or name
		statuses[basename] = status:gsub("%s", "")
	end
	return statuses
end

local save = ya.sync(function(state, statuses)
	state.statuses = statuses
end)

local function fetch_status()
	local statuses = ya.sync(function()
		return git_status()
	end)()
	save(statuses)
end

-- Linemode: show git status badge
local function setup()
	-- Add git status as a linemode component
	Linemode:children_add(function(self)
		local statuses = self._state and self._state.statuses or {}
		local name = self._file.name or tostring(self._file.url):match("[^/]+$")
		local s = statuses[name]
		if s then
			return ui.Line(string.format(" [%s]", s))
		end
		return ui.Line("")
	end, 1000)
end

return { setup = setup, entry = fetch_status }
