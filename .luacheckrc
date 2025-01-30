-- Rerun tests only if their modification time changed.
cache = true
codes = true

-- Glorious list of warnings: https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
  '631',
}

exclude_files = { '.ci/**/*' }

-- Global objects defined by the C code
read_globals = {
  'vim',
  string = {
    fields = {},
  },
}
