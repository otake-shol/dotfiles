-- zoxide.yazi - zoxide integration for yazi
-- Usage: Press 'z' to jump to a directory with zoxide

local selected = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

return {
	entry = function()
		local cwd = selected()
		local child = Command("zoxide")
			:args({ "query", "-i", "--", cwd })
			:stdin(Command.INHERIT)
			:stdout(Command.PIPED)
			:stderr(Command.INHERIT)
			:spawn()

		local output, err = child:wait_with_output()
		if output and output.status.success then
			local target = output.stdout:gsub("\n", "")
			if target ~= "" then
				ya.manager_emit("cd", { target })
			end
		end
	end,
}
