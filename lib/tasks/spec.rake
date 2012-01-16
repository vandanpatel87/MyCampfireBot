require 'rake'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = Dir.glob(Rails.root.join(*%w[spec ** ** *_spec.rb]))
  t.spec_files.delete_if { |file| file =~ /bugzilla|jira|our_quotes|beer/ } #dont run specs for these plugins.  They were broken on fork and I'm not currently planning on supporting them.  
  t.spec_opts << '--format specdoc'
end