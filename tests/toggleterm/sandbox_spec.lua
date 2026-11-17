local T = MiniTest.new_set()

T["invalid varlock path is rejected"] = function()
	local ok = pcall(require("neoplane.middlewares.varlock"), { varlock = true, cmd = { "true" } })
	assert(not ok)
end

T["bwrap sandbox binds linked worktree metadata"] = function()
	local root = vim.fn.tempname()
	local main = root .. "/main"
	local worktree = root .. "/worktree"
	vim.fn.mkdir(main, "p")
	local function git(args)
		local output = vim.fn.system(vim.list_extend({ "git" }, args))
		assert(vim.v.shell_error == 0, output)
	end
	git({ "-C", main, "init", "-q" })
	git({
		"-C",
		main,
		"-c",
		"commit.gpgsign=false",
		"-c",
		"user.name=Test",
		"-c",
		"user.email=test@example.com",
		"commit",
		"-q",
		"--allow-empty",
		"-m",
		"initial",
	})
	git({ "-C", main, "worktree", "add", "-q", "-b", "sandbox-test", worktree })

	local item = require("neoplane.middlewares.sandbox")({
		sandbox = "bwrap",
		agent = "codex",
		cwd = worktree,
		artifacts_dir = root,
		cmd = { "true" },
	})
	local common = main .. "/.git"
	local worktree_git = common .. "/worktrees/worktree"
	local function has_bind(path)
		for i = 1, #item.cmd - 2 do
			if item.cmd[i] == "--bind" and item.cmd[i + 1] == path and item.cmd[i + 2] == path then
				return true
			end
		end
		return false
	end
	assert(has_bind(common))
	assert(has_bind(worktree_git))
	vim.fn.delete(root, "rf")
end

return T
