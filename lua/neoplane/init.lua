local M = {}

local config_ = require("neoplane.config")

function M.setup(config)
	config_ = vim.tbl_deep_extend("force", config_, config or {})
end

return M
