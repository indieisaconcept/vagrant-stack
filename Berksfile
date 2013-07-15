#!/usr/bin/env ruby
#^syntax detection

site :opscode

#####################################
# LOCAL                             #
#####################################

cookbook 'stack',       path: "chef/vendor/local/cookbooks/stack"
cookbook 'oh_my_zsh',   path: "chef/vendor/local/cookbooks/oh_my_zsh"
cookbook 'ant',         path: "chef/vendor/local/cookbooks/ant"

#####################################
# REMOTE                            #
#####################################

cookbook 'apt', "1.7.0"
cookbook 'git'
cookbook 'subversion'
cookbook 'build-essential'
cookbook 'nodejs'