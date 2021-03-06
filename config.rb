###
# Blog settings
###

Time.zone = "MST"

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true

page "/feed.xml", layout: false
page "/presentations/*/*", :layout => false
page "/stuff/taig-calc.html", :layout => false

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin---"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, "stylesheets"
set :js_dir, "javascripts"
set :images_dir, "images"
set :url_root, "http://array.blue"

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end



# ============================================================
#  PLUGINS
# ============================================================


# --- Syntax ---

activate :syntax, :line_numbers => true


# --- Pretty URL ---

activate :directory_indexes


# --- Blog ---

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  blog.permalink = "blog/{year}/{title}.html"
  blog.sources = "posts/{title}.html"
  blog.taglink = "tags/{tag}.html"
  blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  blog.default_extension = ".md"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # pagination
  blog.paginate = true
  blog.per_page = 20
  blog.page_link = "page/{num}"
end


# --- Deploy ---

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
  deploy.remote = "ghpage"
  deploy.branch = "master"
  # deploy.strategy = :submodule      # commit strategy: can be :force_push or :submodule, default: :force_push
  # deploy.commit_message = "custom-message"      # commit message (can be empty), default: Automated commit at `timestamp` by middleman-deploy `version`
end


# --- Minify HTML ---

activate :minify_html do |html|
  html.remove_multi_spaces        = true   # Remove multiple spaces
  html.remove_comments            = true   # Remove comments
  html.remove_intertag_spaces     = false  # Remove inter-tag spaces
  html.remove_quotes              = true   # Remove quotes
  html.simple_doctype             = false  # Use simple doctype
  html.remove_script_attributes   = true   # Remove script attributes
  html.remove_style_attributes    = true   # Remove style attributes
  html.remove_link_attributes     = false  # Remove link attributes
  html.remove_form_attributes     = false  # Remove form attributes
  html.remove_input_attributes    = true   # Remove input attributes
  html.remove_javascript_protocol = true   # Remove JS protocol
  html.remove_http_protocol       = true   # Remove HTTP protocol
  html.remove_https_protocol      = false  # Remove HTTPS protocol
  html.preserve_line_breaks       = false  # Preserve line breaks
  html.simple_boolean_attributes  = true   # Use simple boolean attributes
end


# --- Open Graph ---

activate :ogp do |ogp|
  ogp.namespaces = { og: data.ogp.og }
  ogp.base_url = "http://array.blue/"
  ogp.blog = true
end


# --- Sitemap ---

activate :search_engine_sitemap, default_priority: 0.5,
                                 default_change_frequency: "monthly"


# --- Related Pages ---

# activate :similar, :algorithm => :"word_frequency/mecab"
