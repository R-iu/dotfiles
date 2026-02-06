return {
	{
		"chomosuke/typst-preview.nvim",
		cmd = { "TypstPreview", "TypstPreviewToggle", "TypstPreviewUpdate" },

		init = function()
			vim.g.maplocalleader = "\\"
		end,

		keys = {
			{
				"<localleader>lv",
				ft = "typst",
				"<cmd>TypstPreviewToggle<cr>",
				desc = "Toggle Typst Preview",
			},
			{
				"<localleader>ll",
				ft = "typst",
				":w<CR>:!typst compile %<CR>",
				desc = "Compile Typst Document",
			},
		},
		opts = {
			dependencies_bin = {
				tinymist = "tinymist",
			},
		},
	},
	{
		"folke/ts-comments.nvim",
		opts = {
			lang = {
				typst = { "// %s", "/* %s */" },
			},
		},
	},
}
