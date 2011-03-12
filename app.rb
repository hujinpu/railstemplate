# remove files
run "rm README"
run "rm public/index.html"
run "rm public/images/rails.png"
run "cp config/database.yml config/database.yml.example"

# install gems
run "rm Gemfile"
file 'Gemfile', File.read("#{File.dirname(rails_template)}/Gemfile")

# bundle install
run "bundle install"

# generate rspec
generate "rspec:install"
# speed up your test
run "spork --bootstrap"

gsub_file '.rspec', /(--colour)/, '\1 --drb'
gsub_file 'spec/spec_helper.rb', /require 'rubygems'\s*/, ''
gsub_file 'config/environments/test.rb', /(config.cache_classes) = true/, '\1 = false'

# copy files
file 'script/watchr.rb', File.read("#{File.dirname(rails_template)}/watchr.rb")
file 'lib/tasks/dev.rake', File.read("#{File.dirname(rails_template)}/dev.rake")

# remove active_resource and test_unit
gsub_file 'config/application.rb', /require 'rails\/all'/, <<-CODE
require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
CODE

# Replacing fixture generation and test framework
generators = <<-GENERATORS

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end

GENERATORS

application generators

# install jquery
#run "curl -L http://code.jquery.com/jquery.min.js > public/javascripts/jquery.js"
#run "curl -L http://github.com/rails/jquery-ujs/raw/master/src/rails.js > public/javascripts/rails.js"
file 'public/javascripts/jquery.js', File.read("#{File.dirname(rails_template)}/jquery.js")
file 'public/javascripts/rails.js', File.read("#{File.dirname(rails_template)}/rails.js")

gsub_file 'config/application.rb', /(config.action_view.javascript_expansions.*)/, 
                                   "config.action_view.javascript_expansions[:defaults] = %w(jquery rails)"

#add time format
application '  Time::DATE_FORMATS.merge!(:default => "%Y/%m/%d %I:%M %p", :ymd => "%Y/%m/%d")'

# .gitignore
append_file '.gitignore', <<-CODE
config/database.yml
Thumbs.db
.DS_Store
tmp/*
coverage/*
*un~
CODE

# keep tmp and log
run "touch tmp/.gitkeep"
run "touch log/.gitkeep"

# git commit
git :init
git :add => '.'
git :add => 'tmp/.gitkeep -f'
git :add => 'log/.gitkeep -f'
git :commit => "-a -m 'initial commit'"
