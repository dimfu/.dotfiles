return {
  'mrcjkb/rustaceanvim',
  version = '^6', -- Recommended
  lazy = true, -- This plugin is already lazy
  ['rust-analyzer'] = {
    cargo = {
      allFeatures = true,
    },
  },
}
