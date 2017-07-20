include_recipe "windows_firewall"

windows_firewall_rule 'Apache' do
    localport '80'
    protocol 'TCP'
    firewall_action :allow
end
