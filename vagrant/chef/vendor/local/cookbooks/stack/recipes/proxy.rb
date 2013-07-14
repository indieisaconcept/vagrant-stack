#################################
# PROXY                         #
#################################

proxy = node['stack']['proxy']

if proxy

    template "/etc/apt/apt.conf" do
        source "apt.erb"
        owner "root"
        group "root"
        mode 00644
        variables(
            :proxy => proxy
        )
        action :create
    end

    template "/etc/environment" do
        source "environment.erb"
        owner "root"
        group "root"
        mode 00644
        variables(
            :proxy => proxy
        )
        action :create
    end

    template "/etc/profile.d/proxy.sh" do
        source "proxy.erb"
        owner "root"
        group "root"
        mode 00644
        variables(
            :proxy => proxy
        )
        action :create
    end

end