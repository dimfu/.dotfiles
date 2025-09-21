return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        never_show = { 'node_modules', 'package-lock.json', '.git' },
      },
      window = {
        -- position = 'float',
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
  init = function()
    -- set the FloatBorder highlight globally before plugin runs
  end,
}
