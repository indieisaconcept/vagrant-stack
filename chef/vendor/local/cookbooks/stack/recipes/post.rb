#################################
# WORKSPACE                     #
#################################

#bash "set default workspace" do
#    user "root"
#    code "echo 'cd /workspaces' >> ~/.bash_profile"
#end

#################################
# NODE.JS - GLOBAL INSTALLS     #
#################################


npm_packages = node['nodejs'] && node['nodejs']['modules']

npm_packages.each do | node_module |
  bash "npm install -g #{node_module}" do
    user "root"
    code "npm install -g #{node_module}"
    not_if "npm ls -g | grep ' #{node_module}@'"
  end
end if npm_packages

#################################
# RUBY - GLOBAL INSTALLS        #
#################################

gem_packages = node['ruby'] && node['ruby']['gems']

gem_packages.each do |pkg|
  gem_package pkg[:name] do
    action :install
  end
end if gem_packages