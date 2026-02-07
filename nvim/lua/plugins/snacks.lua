return {
	"folke/snacks.nvim",
	opts = {
		-- dashboard = {
		-- 	sections = {
		-- 		{ section = "header" },
		-- 		{ section = "keys", gap = 1, padding = 1 },
		-- 		{ section = "startup" },
		-- 		{
		-- 			section = "terminal",
		-- 			cmd = "ascii-image-converter ~/Pictures/wallpaper/skadi.jpg -C; sleep .1",
		-- 			pane = 2,
		-- 			indent = 4,
		-- 			height = 30,
		-- 		},
		-- 	},
		-- },
		picker = {
			hidden = true,
			sources = {
				explorer = {
					layout = {
						layout = {
							position = "right",
						},
					},
				},
			},
		},
		explorer = {
			replace_netrw = true,
		},
	},
}
