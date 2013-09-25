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

node_config = node['nodejs'];

if node_config

    package "libfontconfig1"

    npm_packages = node_config['modules'];

    npm_packages.each do | node_module |
      bash "npm install -g #{node_module}" do
        user "root"
        code "npm install -g #{node_module}"
        not_if "npm ls -g | grep ' #{node_module}@'"
      end
    end if npm_packages

    node_path = "/usr/local/lib/node_modules"

    bash "export NODE_PATH=#{node_path}" do
        user "root"
        code "echo 'export NODE_PATH=#{node_path}' >> /etc/environment"
        not_if "grep '#{node_path}' /etc/environment"
    end

end if

#################################
# RUBY - GLOBAL INSTALLS        #
#################################

gem_packages = node['ruby'] && node['ruby']['gems']

gem_packages.each do |pkg|
  gem_package pkg[:name] do
    action :install
  end
end if gem_packages