return {
	"hat0uma/csvview.nvim",
	---@module "csvview"
	---@type CsvView.Options
	opts = {
		parser = { comments = { "#", "//" } },
		keymaps = {
			-- Text objects for selecting fields
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },
			-- Excel-like navigation:
			-- Use <Tab> and <S-Tab> to move horizontally between fields.
			-- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
			-- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
			jump_next_row = { "<Enter>", mode = { "n", "v" } },
			jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
		},
	},
	config = function(_, opts)
		require("csvview").setup(opts)
		require("config.csvview_tools").setup()

		local group = vim.api.nvim_create_augroup("CsvViewAutoEnable", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = "csv",
			callback = function()
				vim.cmd("CsvViewEnable")
			end,
		})

		if vim.bo.filetype == "csv" then
			vim.cmd("CsvViewEnable")
		end
	end,
	ft = "csv",
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewFilter", "CsvViewRank", "CsvViewSort" },
}
