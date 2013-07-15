#!/usr/bin/env ruby
#^syntax detection

#################################
# HELPERS                       #
#################################

module Helpers

    def Helpers.proxy (chef, proxy)

        if chef && proxy
            chef.http_proxy  = proxy
            chef.https_proxy = proxy
        end

    end

end