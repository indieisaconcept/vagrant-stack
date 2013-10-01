#!/usr/bin/env ruby
#^syntax detection

# ===============================
# HELPERS
# ===============================

require './lib/helpers'

# Shortcuts to ARGV

init        = ARGV.first == 'up'
provision   = ARGV.first == 'provision'
reload      = ARGV.first == 'reload'

# ===============================
# PLUGINS
# ===============================

Vagrant.require_plugin 'vagrant-berkshelf'
Vagrant.require_plugin 'vagrant-proxyconf'

# ===============================
# CONFIG
# ===============================

CONFIG_NAME     = 'vagrant.json'
DEPENDENCY_MODE = File.exist?("../#{CONFIG_NAME}") && "../#{CONFIG_NAME}"
STANDALONE_MODE = File.exist?("#{CONFIG_NAME}") && "#{CONFIG_NAME}"
DEFAULT_MODE    = "chef/node/#{CONFIG_NAME}"

# Obtain default configuration file based on
# file configuration

# Register global config settings

VAGRANT_JSON      = JSON.parse(File.read(DEPENDENCY_MODE || STANDALONE_MODE || DEFAULT_MODE))
SERVER_CONFIG     = VAGRANT_JSON['server']
PROVIDER_CONFIG   = SERVER_CONFIG['provider']

# ===============================
# VAGRANT
# ===============================

VAGRANTFILE_API_VERSION = "2"

provider = ARGV.index{|s| s.include?("--provider=")}
provider = provider ? ARGV[provider].sub('--provider=', '') : 'virtualbox'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.hostname = SERVER_CONFIG['host'] || 'vagrant'

    # ===============================
    # PROVIDERS
    # ===============================
    # Providers are selected using the command line argument
    #
    # --provider={name} => --provider=virtualbox

    ## DEFAULT BOX ##

    config.omnibus.chef_version = '10.14.2'

    config.vm.box       = PROVIDER_CONFIG[provider]['box']
    config.vm.box_url   = PROVIDER_CONFIG[provider]['box_url']

    ## VIRTUALBOX (default) ##

    config.vm.provider :virtualbox do |vb|

        # Set the memory size
        vb.customize ['modifyvm', :id, '--memory', '1024']

        # VirtualBox performance improvements
        vb.customize ['modifyvm', :id, '--nictype1', 'virtio']
        vb.customize ['modifyvm', :id, '--nictype2', 'virtio']
        #vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        vb.customize ['storagectl', :id, '--name', 'SATA Controller', '--hostiocache', 'off']
        vb.customize ['setextradata', :id, 'VBoxInternal2/SharedFoldersEnableSymlinksCreate/workspace', '1']

    end

    ## AWS ##

    config.vm.provider :aws do |aws, override|

        ## load config file ##

        aws_config = PROVIDER_CONFIG["aws"]

        if aws_config["config_path"]
            aws_config = File.exist?(aws_config["config_path"]) ? JSON.parse(File.read(aws_config["config_path"])) : aws_config
        end if

        aws.access_key_id               = aws_config['key']
        aws.secret_access_key           = aws_config['secret_key']
        aws.keypair_name                = aws_config['keypair_name']

        aws.instance_type               = aws_config['instance_type']
        aws.ami                         = aws_config['ami']
        aws.region                      = aws_config['region']
        aws.security_groups             = aws_config['security_groups']

        override.ssh.username           = aws_config['ssh_username']
        override.ssh.private_key_path   = aws_config['ssh_private_key_path']

    end

    # ===============================
    # PLUGINS
    # ===============================

    ## BERKSHELF ##

    ENV['BERKSHELF_PATH'] = File.expand_path(File.dirname(__FILE__)) + '/chef/vendor/remote'
    config.berkshelf.enabled = true

    #################################
    # Networking                    #
    #################################

    SERVER_PORT = SERVER_CONFIG['port'] || '2912'

    # Use port-forwarding. Web site will be at http://localhost:2912
    config.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true

    #################################
    # WORKSPACES                   #
    #################################

    config.vm.synced_folder ".", "/vagrant", :disabled => true

    if DEPENDENCY_MODE

        ## DEFAULT
        config.vm.synced_folder '../', '/workspace', id: 'workspace-root', :mount_options => ["dmode=777", "fmode=666"]

    end

    ## WORKSPACE FOLDERS FROM CONFIG

    VAGRANT_JSON['workspaces'].each do |item|
        if File.directory?(item['host'])
            config.vm.synced_folder item['host'], item['guest'], :mount_options => ["dmode=777", "fmode=666"]
        end
    end if VAGRANT_JSON['workspaces']

    # ===============================
    # PROVISION
    # ===============================

    if init || provision || reload

        CHEF_CONFIG = VAGRANT_JSON['chef']
        CHEF_JSON   = CHEF_CONFIG['json']
        PROXY       = CHEF_JSON['stack'] && CHEF_JSON['stack']['proxy'];

        ## PROXY ##
        # Depending upon the environment a proxy may be required to
        # allow remote resources to be downloaded

        if !(PROXY).nil?
            config.proxy.http       = PROXY['http']
            config.proxy.https      = PROXY['https']
            config.proxy.ftp        = PROXY['ftp']
            config.proxy.no_proxy   = PROXY['no_proxy']
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

        if init || reload || provision

            # Run any necessary shell commands on the vm
            config.vm.provision :shell, :path => 'bin/post-provision.sh'

        end

    end

end
