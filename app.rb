# .rvmrc
rvmrc = <<-RVMRC
rvm_gemset_create_on_use_flag=1
rvm gemset use #{app_name}
RVMRC

create_file ".rvmrc", rvmrc

# Adding Gems
gem "rspec-rails", :group => :test
gem "factory_girl_rails", :group => :test
gem "capybara", :group => :test
gem "steak", :group => :test
gem "factory_girl_generator", :group => [:test, :development]
gem "haml-rails"
gem "compass"
gem "compass-susy-plugin"
gem "devise"
gem 'delorean', :group => :test
gem 'database_cleaner', :group => :test
gem 'spork', :group => :test

# Add Generators
generators = <<-GENERATORS

    config.generators do |g|
      g.test_framework :rspec, :fixture => true, :views => false
      g.integration_tool :rspec, :fixture => true, :views => true
    end
GENERATORS

application generators

# Gets jquery & rails.js
get "http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js",  "public/javascripts/jquery.js"
get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"

gsub_file 'config/application.rb', 'config.action_view.javascript_expansions[:defaults] = %w()', 'config.action_view.javascript_expansions[:defaults] = %w(jquery.js rails.js)'

# describing of layout application
layout = <<-LAYOUT
!!!
%html
  %head
    %title= h(yield(:title) || "Untitled")
    = stylesheet_link_tag :all
    = javascript_include_tag :defaults
    = csrf_meta_tag
    
    = yield(:head)
  %body
    #container
      - flash.each do |name, msg|
        = content_tag :div, msg, :id => "flash_\#\{name\}", :class => 'flash'
      %nav
        = link_to "Home", root_url
      %header
        - if show_title?
          %h1=h yield(:title)
      %article
        = yield
      %footer
    
LAYOUT

# Layout helpers
layout_helper = <<-LAYOUTHELPER
# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    content_for(:title) { page_title.to_s }
    @show_title = show_title
  end
  
  def show_title?
    @show_title
  end
  
  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end
  
  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end
  
end
LAYOUTHELPER

# removing unused files
remove_file "README"
remove_file "public/index.html"
remove_file "public/images/rails.png"
remove_file "app/views/layouts/application.html.erb"

# removing prototype files
remove_file "public/javascripts/controls.js"
remove_file "public/javascripts/dragdrop.js"
remove_file "public/javascripts/effects.js"
remove_file "public/javascripts/prototype.js"
remove_file "public/javascripts/jrails.js"

# creating the new ones
create_file 'README'
create_file "app/views/layouts/application.html.haml", layout
create_file "app/helpers/layout_helper.rb", layout_helper

create_file "log/.gitkeep"
create_file "tmp/.gitkeep"

# Adding git
git :init
git :add => "."

# Bundle
run 'bundle install'

# Install rspec and steak
run 'rails generate rspec:install'
run 'rails g steak:install'


# Install compass with susy
run "compass init rails . -x scss -r susy --using susy/project --sass-dir app/stylesheets --css-dir public/stylesheets"

# SUSY
susy_screen =<<-SUSYSCREEN
h1,h2,h3,h4,h5 {
  text-shadow: 2px 1px 2px #aaa;
  color: $alt;
}

a {
  @include sans-family;
  @include adjust-font-size-to(13px);
  padding: 1px;
  color: #413630;
  &:link, &:visited {
    color: $alt;
  }
  &:focus, &:hover, &:active {
    color: darken($base,5);
    text-decoration: none;
  }
  img {
    border: none;
  }
}

/* Header --------------------------------------------------------------*/

/* others --------------------------------------------------------------*/
.flash {
  @include sans-family;
  @include adjust-font-size-to(13px);
  text-align: center;
  visibility: visible;
  overflow: visible;
  z-index: 1000;
}

#flash_notice {
  background-color: #ccffcc;
  border: solid 1px #66cc66; }

#flash_error {
  background-color: #ffcccc;
  border: solid 1px #cc6666; }

.active {
  color: red;
}
SUSYSCREEN

susy_app = <<-SUSYAPP
= stylesheet_link_tag 'screen.css', :media => 'screen, projection'
    = stylesheet_link_tag 'print.css', :media => 'print'
    = stylesheet_link_tag 'ie.css', :media => 'screen, projection'
SUSYAPP
  # and inject there
    inject_into_file "app/stylesheets/screen.scss", "\n#{susy_screen}", :after => "/* Styles -------------------------------------------------------------- */"
    gsub_file "app/views/layouts/application.html.haml", "= stylesheet_link_tag :all", "#{susy_app}"
    gsub_file "app/stylesheets/screen.scss", ".container {", "#container {"

docs = <<-DOCS

Run the following commands to complete the setup of #{app_name.humanize}:

% cd #{app_name}
% rails generate devise:install
% rails generate devise MODEL
DOCS

log docs
