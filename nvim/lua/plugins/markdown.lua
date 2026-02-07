return {
	{ "markdown-preview.nvim", enabled = true },

	-- {
	--     "toppair/peek.nvim",
	--     build = "deno task --quiet build:fast",
	--     -- config = function()
	--     --     require("peek").setup()
	--     --     vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
	--     --     vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
	--     -- end,
	--     opts = {
	--         theme = "dark",
	--     },
	--     keys = {
	--         {
	--             "<leader>cp",
	--             function()
	--                 require("peek").open()
	--             end,
	--             desc = "markdown-preview",
	--         },
	--     },
	-- },
}
