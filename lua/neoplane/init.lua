local M = {}

function M.setup(config)
	local current = require("neoplane.config")
	local merged = vim.tbl_deep_extend("force", current, config or {})
	for k in pairs(current) do
		current[k] = nil
	end
	for k, v in pairs(merged) do
		current[k] = v
	end
end

return M
