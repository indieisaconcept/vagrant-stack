#!/usr/bin/env ruby
#^syntax detection

#################################
# HELPERS                       #
#################################

require './lib/helpers'

Vagrant.require_plugin 'vagrant-berkshelf'
Vagrant.require_plugin 'vagrant-proxyconf'

# configuration

CONFIG_NAME     = 'stack.json'
DEPENDENCY_MODE = File.exist?("../#{CONFIG_NAME}") && "../#{CONFIG_NAME}"
STANDALONE_MODE = File.exist?("#{CONFIG_NAME}") && "#{CONFIG_NAME}"
DEFAULT_MODE    = "chef/node/#{CONFIG_NAME}"

VAGRANT_JSON    = JSON.parse(File.read(DEPENDENCY_MODE || STANDALONE_MODE || DEFAULT_MODE))
SERVER_CONFIG   = VAGRANT_JSON['server']

Vagrant.configure('2') do |config|

    init = ARGV.first == 'up'
    provision = ARGV.first == 'provision'
    reload = ARGV.first == 'reload'

    #################################
    # PLUGINS                       #
    #################################

    ## BERKSHELF ##

    ENV['BERKSHELF_PATH'] = File.expand_path(File.dirname(__FILE__)) + '/chef/vendor/remote'
    config.berkshelf.enabled = true

    #################################
    # Base box and vm configuration #
    #################################

    config.vm.hostname = SERVER_CONFIG['host']  || 'stack'

    # Name of base box to be used
    config.vm.box = SERVER_CONFIG['box'] || 'precise32'

    # Url of base box in case vagrant needs to download it
    config.vm.box_url = SERVER_CONFIG['box_url'] || 'http://files.vagrantup.com/precise32.box'

    #################################
    # Virtual Box                   #
    #################################

    config.vm.provider :virtualbox do |vb|

        # Set the memory size
        vb.customize ['modifyvm', :id, '--memory', '1024']

        # VirtualBox performance improvements
        vb.customize ['modifyvm', :id, '--nictype1', 'virtio']
        vb.customize ['modifyvm', :id, '--nictype2', 'virtio']
        #vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        vb.customize ['storagectl', :id, '--name', 'SATA Controller', '--hostiocache', 'off']
        vb.customize ['setextradata', :id, 'VBoxInternal2/SharedFoldersEnableSymlinksCreate/workspaces', '1']

    end

    #################################
    # Networking                    #
    #################################

    SERVER_PORT = SERVER_CONFIG['port'] || '2912'

    # Use port-forwarding. Web site will be at http://localhost:2912
    config.vm.network :forwarded_port, guest: SERVER_PORT, host: SERVER_PORT, auto_correct: true

    # Use host-only networking. Required for nfs shared folder.
    # Web site will be at http://<config.vm.host_name>.local
    #
    # config.vm.network :hostonly, '172.21.21.21'

    # config.vm.network "private_network", ip: "192.168.50.4"
    # config.vm.network :forwarded_port, guest: 8181, host: 8181
    # config.vm.network "private_network", ip: "192.168.50.4"

    #################################
    # WORKSPACES                   #
    #################################

    config.vm.synced_folder ".", "/vagrant", :disabled => true

    if DEPENDENCY_MODE

        ## DEFAULT
        config.vm.synced_folder '../', '/workspaces', id: 'workspaces-root', :mount_options => ["dmode=777", "fmode=666"]

    end

    ## WORKSPACE FOLDERS FROM CONFIG

    VAGRANT_JSON['workspaces'].each do |item|
        if File.directory?(item['host'])
            config.vm.synced_folder item['host'], item['guest'], :mount_options => ["dmode=777", "fmode=666"]
        end
    end if VAGRANT_JSON['workspaces']

    #################################
    # Provisioners                  #
    #################################

    if init || provision || reload

        CHEF_CONFIG = VAGRANT_JSON['chef']
        CHEF_JSON = CHEF_CONFIG['json']
        PROXY = CHEF_JSON['stack'] && CHEF_JSON['stack']['proxy'];

        if !(PROXY).nil?
            config.proxy.http = PROXY['http']
            config.proxy.https = PROXY['https']
            config.proxy.ftp = PROXY['ftp']
            config.proxy.no_proxy = PROXY['no_proxy']
        end

        if init || provision

            if CHEF_CONFIG

                # BASE:
                # Provides initial configuration for proxies etc, which may
                # be required by subsequent recipies

                config.vm.provision :chef_solo do |chef|

                    chef.cookbooks_path = ['vendor/local/cookbooks', 'vendor/remote/cookbook']
                    chef.roles_path = 'chef/roles'
                    chef.json = CHEF_JSON

                    chef.add_role('base');

                end

                ## PROVISION

                config.vm.provision :chef_solo do |chef|

                    chef.cookbooks_path = ['vendor/local/cookbooks', 'vendor/remote/cookbook']
                    chef.roles_path = 'chef/roles'

                    # To turn on chef debug output, run 'CHEF_LOG=1 vagrant up' from command line
                    chef.log_level = :debug if !(ENV['CHEF_LOG']).nil?

                    ['role', 'recipe'].each do |item|

                        CHEF_CONFIG[item].each do |pkg|
                            chef.send("add_#{item}", pkg)
                        end if CHEF_CONFIG[item]

                    end

                    chef.json = CHEF_JSON

                end

            end

        end

        if init || reload

            # Run any necessary shell commands on the vm
            config.vm.provision :shell, :path => 'bin/post-provision.sh'

        end

    end

end
