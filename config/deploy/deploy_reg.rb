load File.join(File.dirname(__FILE__),"../../../../third-party-libs/custom-libs/deployment_strategy","deploy_rails.rb")

#Put Capistrano tasks that are shared in both production and staging environments here

#Skip tasks that don't make sense for this app
set :skip_memcache, true
set :skip_generate_assets, true
set :skip_generate_data, true

#This app uses its own Gemfile and not our shared one
set :custom_gemfile, true