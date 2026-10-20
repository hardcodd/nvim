return {
  filetypes = { "html", "htmldjango" },
  -- HTML formatting does not understand Django template control flow.
  init_options = { provideFormatter = false },
}
