-- fzf.yazi - fzf integration for yazi
-- Usage: Press 'Z' to search directories with fzf

return {
	entry = function()
		local child = Command("sh")
			:args({
				"-c",
				"fd --type d --hidden --exclude .git | fzf --preview 'eza -la --color=always {}'",
			})
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
