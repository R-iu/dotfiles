return {
	"folke/snacks.nvim",
	opts = {
		picker = {
			hidden = true,
			ignored = true,
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
		lazygit = {
			configure = true,
		},
	},
}
