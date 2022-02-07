# frozen_string_literal: true

source 'https://rubygems.org'

ruby RUBY_VERSION

gemspec

DECIDIM_VERSION = '<= 0.24.3'
gem 'decidim', DECIDIM_VERSION

# Security fixes
# nokogiri: GHSA-2rr5-8q37-2w7h
gem "nokogiri", ">= 1.12.5"
# puma: GHSA-48w2-rm65-62xx
gem "puma", ">= 5.5.1"

group :development, :test do
  gem 'byebug', '~> 11.0', platform: :mri
  gem 'bootsnap', require: true
  gem 'faker', '~> 1.8'
  gem 'listen'
  gem 'i18n-tasks', '~> 0.9.28'
end

group :development do
  gem 'letter_opener_web', '~> 1.3.3'
  gem 'web-console', '~> 3.5'
end
