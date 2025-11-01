-- TODO: Review if still usable
return {
  "xbase-lab/xbase",
  ft = { "swift", "xcodeproj" }, -- etc
  build = "make install",
  init = function()
    require("xbase").setup({}) -- see default configuration bellow
  end,
}
