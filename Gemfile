source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.7"

gem "rails", "7.0.2.4"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails", "3.5.1"

# Use postgresql as the database for Active Record
gem "pg", "1.5.6"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "5.6.8"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "1.18.3", require: false

# Fix for Rails 7.0 with concurrent-ruby >= 1.3.5 (same pin as the base project)
gem "concurrent-ruby", "1.3.4"

# Slim templates (layout application_vue.html.slim)
gem "slim-rails", "3.6.3"

# Tailwind CSS, same versions as the base project
gem "tailwindcss-rails", "3.3.2"
gem "tailwindcss-ruby", "3.4.17"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
