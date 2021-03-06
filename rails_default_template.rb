# >---------------------------------------------------------------------------<
#
#            _____       _ _   __          ___                  _ 
#           |  __ \     (_) |  \ \        / (_)                | |
#           | |__) |__ _ _| |___\ \  /\  / / _ ______ _ _ __ __| |
#           |  _  // _` | | / __|\ \/  \/ / | |_  / _` | '__/ _` |
#           | | \ \ (_| | | \__ \ \  /\  /  | |/ / (_| | | | (_| |
#           |_|  \_\__,_|_|_|___/  \/  \/   |_/___\__,_|_|  \__,_|
#
#   This template was generated by RailsWizard, the amazing and awesome Rails
#     application template builder. Get started at http://railswizard.org
#
# >---------------------------------------------------------------------------<

# >----------------------------[ Initial Setup ]------------------------------<

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
end
RUBY

@recipes = ["rvmrc-cory", "activerecord", "git", "haml", "heroku", "pow", "rspec", "frontend", "settingslogic"] 

@prefs = {}
def recipes; @recipes end
def recipe?(name); @recipes.include?(name) end
def prefs; @prefs end
def prefer(key, value); @prefs[key].eql? value end

def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end
def say_recipe(name); say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..." end
def say_wizard(text); say_custom(@current_recipe || 'wizard', text) end

def ask_wizard(question)
  ask "\033[1m\033[30m\033[46m" + (@current_recipe || "prompt").rjust(10) + "\033[0m\033[36m" + "  #{question}\033[0m"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question); !yes_wizard?(question) end

def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice,i| 
    values[(i + 1).to_s] = choice[1]
    say_custom (i + 1).to_s + ')', choice[0]
  end
  answer = ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

def copy_from(source, destination)
  begin
    remove_file destination
    get source, destination
  rescue OpenURI::HTTPError
    say_wizard "Unable to obtain #{source}"
  end
end

def copy_from_repo(filename, opts = {})
  repo = 'https://raw.github.com/RailsApps/rails-composer/master/files/'
  repo = opts[:repo] unless opts[:repo].nil?
  if (!opts[:prefs].nil?) && (!prefs.has_value? opts[:prefs])
    return
  end
  source_filename = filename
  destination_filename = filename
  unless opts[:prefs].nil?
    if filename.include? opts[:prefs]
      destination_filename = filename.gsub(/\-#{opts[:prefs]}/, '')
    end
  end
  if (prefer :templates, 'haml') && (filename.include? 'views')
    remove_file destination_filename
    destination_filename = destination_filename.gsub(/.erb/, '.haml')
  end
  if (prefer :templates, 'slim') && (filename.include? 'views')
    remove_file destination_filename
    destination_filename = destination_filename.gsub(/.erb/, '.slim')
  end
  begin
    remove_file destination_filename
    if (prefer :templates, 'haml') && (filename.include? 'views')
      create_file destination_filename, html_to_haml(repo + source_filename)
    elsif (prefer :templates, 'slim') && (filename.include? 'views')
      create_file destination_filename, html_to_slim(repo + source_filename)
    else
      get repo + source_filename, destination_filename
    end
  rescue OpenURI::HTTPError
    say_wizard "Unable to obtain #{source_filename} from the repo #{repo}"
  end
end

def html_to_haml(source)
  html = open(source) {|input| input.binmode.read }
  Haml::HTML.new(html, :erb => true, :xhtml => true).render
end

def html_to_slim(source)
  html = open(source) {|input| input.binmode.read }
  haml = Haml::HTML.new(html, :erb => true, :xhtml => true).render
  Haml2Slim.convert!(haml)
end

def app_name_to_class_name(app_name)
  app_name.split(/-|_/).map {|word| word.capitalize}.join
end

@current_recipe = nil
@configs = {}

@after_blocks = []
def after_bundler(&block); @after_blocks << [@current_recipe, block]; end
@after_everything_blocks = []
def after_everything(&block); @after_everything_blocks << [@current_recipe, block]; end
@before_configs = {}
def before_config(&block); @before_configs[@current_recipe] = block; end


# >-----------------------------[ rvmrc-cory ]------------------------------<
@current_recipe = "rvmrc-cory"
@before_configs["rvmrc-cory"].call if @before_configs["rvmrc-cory"]
say_recipe 'rvmrc-cory'

config = {}
@configs[@current_recipe] = config

# using the rvm Ruby API, see:
# http://blog.thefrontiergroup.com.au/2010/12/a-brief-introduction-to-the-rvm-ruby-api/
if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
  begin
    rvm_path     = File.dirname(File.dirname(ENV['MY_RUBY_HOME']))
    rvm_lib_path = File.join(rvm_path, 'lib')
    require 'rvm'
  rescue LoadError
    raise "RVM ruby lib is currently unavailable."
  end
else
  raise "RVM ruby lib is currently unavailable."
end
say_wizard "creating RVM gemset '#{app_name}'"
RVM.gemset_create app_name
run "rvm rvmrc trust"
say_wizard "switching to gemset '#{app_name}'"
begin
  RVM.gemset_use! app_name
rescue StandardError
  raise "rvm failure: unable to use gemset #{app_name}"
end
say_wizard "Create .rvmrc file for 1.9.3@#{app_name}"
run "rvm rvmrc create 1.9.3@#{app_name} .rvmrc"
run "rvm gemset list"

# >-----------------------------[ ActiveRecord ]------------------------------<

@current_recipe = "activerecord"
@before_configs["activerecord"].call if @before_configs["activerecord"]
say_recipe 'ActiveRecord'

config = {}
# default to postgres, don't waste time asking
# config['database'] = multiple_choice("Which database are you using?", [["MySQL", "mysql"], ["PostgreSQL", "postgresql"], ["SQLite", "sqlite3"]]) if true && true unless config.key?('database')
config['database'] = "postgresql"
config['auto_create'] = true # yes_wizard?("Automatically create database with default configuration?") if true && true unless config.key?('auto_create')
if config['auto_create'] && config['database'] == "postgresql"
  config['create_user'] = true # yes_wizard?("Automatically create postgres superuser '#{app_name}'?")
end
@configs[@current_recipe] = config

if config['database']
  say_wizard "Configuring '#{config['database']}' database settings..."
  old_gem = gem_for_database
  @options = @options.dup.merge(:database => config['database'])
  gsub_file 'Gemfile', "gem '#{old_gem}'", "gem '#{gem_for_database}'"
  template "config/databases/#{@options[:database]}.yml", "config/database.yml.new"
  run 'mv config/database.yml.new config/database.yml'
end

after_bundler do
  if config['create_user']
    say_wizard "Creating postgres user #{app_name}"
    run "createuser -s #{app_name}"
  end
  rake "db:create:all" if config['auto_create']
end

# >----------------------------------[ Git ]----------------------------------<

@current_recipe = "git"
@before_configs["git"].call if @before_configs["git"]
say_recipe 'Git'


@configs[@current_recipe] = config

after_everything do
  git :init
  git :add => '.'
  git :commit => '-m "Initial import."'
end


# >---------------------------------[ HAML ]----------------------------------<

@current_recipe = "haml"
@before_configs["haml"].call if @before_configs["haml"]
say_recipe 'HAML'
prefs[:templates] = 'haml'

@configs[@current_recipe] = config

gem 'haml', '>= 3.1.7'
gem 'haml-rails', '>= 0.3.4', :group => :development
gem 'hpricot', '>= 0.8.6', :group => :development
gem 'ruby_parser', '>= 2.3.1', :group => :development

after_bundler do
  say_wizard "Running 'after bundler' callbacks."
  require 'bundler/setup'
  if prefer :templates, 'haml'
    say_wizard "importing html2haml conversion tool"
    require 'haml/html'
  end
end
# >--------------------------------[ Heroku ]---------------------------------<

@current_recipe = "heroku"
@before_configs["heroku"].call if @before_configs["heroku"]
say_recipe 'Heroku'

config = {}
# don't set up heroku automatically anymore
config['create'] = false # yes_wizard?("Automatically create appname.heroku.com?") if true && true unless config.key?('create')
config['staging'] = yes_wizard?("Create staging app? (appname-staging.heroku.com)") if config['create'] && true unless config.key?('staging')
config['domain'] = ask_wizard("Specify custom domain (or leave blank):") if config['create'] && true unless config.key?('domain')
config['deploy'] = yes_wizard?("Deploy immediately?") if config['create'] && true unless config.key?('deploy')
@configs[@current_recipe] = config

heroku_name = app_name.gsub('_','')

after_everything do
  if config['create']
    say_wizard "Creating Heroku app '#{heroku_name}.heroku.com'"  
    while !system("heroku create #{heroku_name}")
      heroku_name = ask_wizard("What do you want to call your app? ")
    end
  end

  if config['staging']
    staging_name = "#{heroku_name}-staging"
    say_wizard "Creating staging Heroku app '#{staging_name}.heroku.com'"
    while !system("heroku create #{staging_name}")
      staging_name = ask_wizard("What do you want to call your staging app?")
    end
    git :remote => "rm heroku"
    git :remote => "add production git@heroku.com:#{heroku_name}.git"
    git :remote => "add staging git@heroku.com:#{staging_name}.git"
    say_wizard "Created branches 'production' and 'staging' for Heroku deploy."
  end

  unless config['domain'].blank?
    run "heroku addons:add custom_domains"
    run "heroku domains:add #{config['domain']}"
  end

  git :config => 'heroku.remote production'

  git :push => "#{config['staging'] ? 'staging' : 'heroku'} master" if config['deploy']
end


# >----------------------------------[ Pow ]----------------------------------<

@current_recipe = "pow"
@before_configs["pow"].call if @before_configs["pow"]
say_recipe 'Pow'


@configs[@current_recipe] = config

say_wizard "Creating .powrc file"
create_file ".powrc", <<-RUBY
  if [ -f "$rvm_path/scripts/rvm" ] && [ -f ".rvmrc" ]; then
    source "$rvm_path/scripts/rvm"
    source ".rvmrc"
  fi
RUBY

run "ln -s #{destination_root} ~/.pow/#{app_name}"
say_wizard "App is available at http://#{app_name}.dev/"


# >---------------------------------[ RSpec ]---------------------------------<

@current_recipe = "rspec"
@before_configs["rspec"].call if @before_configs["rspec"]
say_recipe 'RSpec'


@configs[@current_recipe] = config
prefs[:rspec] = true

gem 'rspec-rails', '>= 2.0.1', :group => [:development, :test]
gem "factory_girl_rails", "~> 4.0", :group => [:development, :test]

after_bundler do
  generate 'rspec:install'
  say_wizard "Adding factory_girl"
end

# >-------------------------------[ frontend ]--------------------------------<

@current_recipe = "frontend"
@before_configs["frontend"].call if @before_configs["frontend"]
say_recipe 'frontend'


@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/frontend.rb

# prefs[:frontend] = multiple_choice "Front-end framework?", [["None", "none"], ["Twitter Bootstrap", "bootstrap"]] unless prefs.has_key? :frontend
# don't need to ask, use bootstrap
prefs[:frontend] = "bootstrap"
if prefer :frontend, 'bootstrap'
  prefs[:bootstrap] = 'sass'
end

## Front-end Framework
gem 'bootstrap-sass', '>= 2.0.4.0' if prefer :bootstrap, 'sass'
gem 'simple_form'

gem 'simple_form'
inject_into_file "config/initializers/generators.rb", :after => "Rails.application.config.generators do |g|\n" do
  "    g.form_builder = :simple_form\n"
end

after_bundler do
  generate "simple_form:install --bootstrap"

  say_wizard "recipe running after 'bundle install'"
  ### LAYOUTS ###
  copy_from_repo 'app/views/layouts/application.html.erb'
  copy_from_repo 'app/views/layouts/application-bootstrap.html.erb', :prefs => 'bootstrap'
  copy_from_repo 'app/views/layouts/_messages.html.erb'
  copy_from_repo 'app/views/layouts/_messages-bootstrap.html.erb', :prefs => 'bootstrap'
  copy_from_repo 'app/views/layouts/_navigation.html.erb'
  copy_from_repo 'app/views/layouts/_navigation-devise.html.erb', :prefs => 'devise'
  copy_from_repo 'app/views/layouts/_navigation-cancan.html.erb', :prefs => 'cancan'
  copy_from_repo 'app/views/layouts/_navigation-omniauth.html.erb', :prefs => 'omniauth'
  copy_from_repo 'app/views/layouts/_navigation-subdomains_app.html.erb', :prefs => 'subdomains_app'
  ## APPLICATION NAME
  application_layout_file = Dir['app/views/layouts/application.html.*'].first
  navigation_partial_file = Dir['app/views/layouts/_navigation.html.*'].first
  gsub_file application_layout_file, /App_Name/, "#{app_name.humanize.titleize}"
  gsub_file navigation_partial_file, /App_Name/, "#{app_name.humanize.titleize}"
  ### CSS ###
  remove_file 'app/assets/stylesheets/application.css'
  copy_from_repo 'app/assets/stylesheets/application.css.scss'
  copy_from_repo 'app/assets/stylesheets/application-bootstrap.css.scss', :prefs => 'bootstrap'
  if prefer :bootstrap, 'sass'
    insert_into_file 'app/assets/javascripts/application.js', "//= require bootstrap\n", :after => "jquery_ujs\n"
    create_file 'app/assets/stylesheets/bootstrap_and_overrides.css.scss', <<-RUBY
@import "bootstrap";
body { padding-top: 60px; }
@import "bootstrap-responsive";
RUBY
  end
end # after_bundler

# >-----------------------------[ Settingslogic ]-----------------------------<

@current_recipe = "settingslogic"
@before_configs["settingslogic"].call if @before_configs["settingslogic"]
say_recipe 'Settingslogic'


@configs[@current_recipe] = config

gem 'settingslogic'

say_wizard "Generating config/application.yml..."

append_file "config/application.rb", <<-RUBY

require 'settings'
RUBY

create_file "lib/settings.rb", <<-RUBY
class Settings < Settingslogic
  source "#\{Rails.root\}/config/application.yml"
  namespace Rails.env
end

RUBY

create_file "config/application.yml", <<-YAML
defaults: &defaults
  cool:
    saweet: nested settings
  neat_setting: 24
  awesome_setting: <%= "Did you know 5 + 5 = #{5 + 5}?" %>

development:
  <<: *defaults
  neat_setting: 800

test:
  <<: *defaults

production:
  <<: *defaults
YAML


# >---------------------------------[ ActiveAdmin ]----------------------------------<

@current_recipe = "activeadmin"
@before_configs["activeadmin"].call if @before_configs["activeadmin"]
say_recipe 'activeadmin'

if yes_wizard?("Use activeadmin?")
  gem 'activeadmin'
  gem "meta_search", '>= 1.1.0.pre'

  after_bundler do
    generate "active_admin:install"
    run "rake db:migrate"
  end
end

config = {}
@configs[@current_recipe] = config
@current_recipe = nil


# >---------------------------------[ livereload ]----------------------------------<
@current_recipe = "livereload"
@before_configs["livereload"].call if @before_configs["livereload"]
say_recipe 'livereload'
config = {}

prefs[:livereload] = true
gem 'rack-livereload', :group => [:development]

after_bundler do
  inject_into_file "config/environments/development.rb", :after => "#{app_name_to_class_name(app_name)}::Application.configure do\n" do
    "config.middleware.insert_before(Rack::Lock, Rack::LiveReload)\n"
  end
end

@configs[@current_recipe] = config
@current_recipe = nil

# >---------------------------------[ home-controller ]----------------------------------<
@current_recipe = "home-controller"
@before_configs["home-controller"].call if @before_configs["home-controller"]
say_recipe 'home-controller'
config = {}

remove_file 'public/index.html'
remove_file 'app/assets/images/rails.png'
after_bundler do
  generate 'controller home index'
  inject_into_file 'config/routes.rb', :after => "#{app_name_to_class_name(app_name)}::Application.routes.draw do\n" do
    "root :to => 'home#index'\n"
  end
  gsub_file 'config/routes.rb', 'get "home/index"\n', ''
end

@configs[@current_recipe] = config
@current_recipe = nil
# >---------------------------------[ guard ]----------------------------------<
@current_recipe = "guard"
@before_configs["guard"].call if @before_configs["guard"]
say_recipe 'guard'
config = {}

gem 'guard', :group => [:development]
gem 'guard-bundler', :group => [:development]
gem 'guard-pow', :group => [:development]
gem 'growl', :group => [:development]
gem 'growl_notify', :group => [:development]

config[:guards] = ['bundler']

if prefs[:livereload]
  gem 'guard-livereload', :group => [:development]
  config[:guards] << 'livereload'
end
if prefs[:rspec]
  gem 'guard-rspec', :group => [:development]
  config[:guards] << 'rspec'
end

after_bundler do
  run "guard init #{config[:guards].join(' ')}"
end

@configs[@current_recipe] = config
@current_recipe = nil

# >-----------------------------[ Run Bundler ]-------------------------------<

say_wizard "Running Bundler install. This will take a while."
run 'bundle install'
say_wizard "Running after Bundler callbacks."
@after_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

# >----------------------------------

@current_recipe = nil
say_wizard "Running after everything callbacks."
@after_everything_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}
