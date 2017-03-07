###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.txt', layout: false

# General configuration
set :fonts_dir,  'fonts'

# Enable middleman-protect-emails
activate :protect_emails

# Enable robot friendly site maps
activate :sitemap

###
# Helpers
###

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

# Build-specific configuration
configure :build do
  # Minify CSS on build
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript
end

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

