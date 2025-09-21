return { -- Add indentation guides even on blank lines
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  -- Enable `lukas-reineke/indent-blankline.nvim`
  -- See `:help ibl`
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    -- indent = {
    --   char = { '', '', '', '' },
    --   tab_char = { '', '', '', '' },
    -- },
    indent = {
      char = { '│' },
      tab_char = { '│' },
    },
    exclude = {
      filetypes = {
        'startify',
        'dashboard',
        'dotooagenda',
        'log',
        'fugitive',
        'gitcommit',
        'packer',
        'vimwiki',
        'markdown',
        'json',
        'txt',
        'vista',
        'help',
        'todoist',
        'NvimTree',
        'neo-tree',
        'peekaboo',
        'git',
        'TelescopePrompt',
        'undotree',
        'flutterToolsOutline',
        '', -- for all buffers without a file type
      },
      buftypes = {
        'terminal',
        'nofile',
      },
    },
  },
}
