$hiera_dir = '/etc/hiera/override'
$plugin_name = 'influxdb_grafana'
$plugin_yaml = "${plugin_name}.yaml"
$vip_name = 'influxdb'

$network_metadata = hiera_hash('network_metadata')
if ! $network_metadata['vips'][$vip_name] {
  fail('InfluxDB VIP is not defined')
}

$influxdb_nodes = get_nodes_hash_by_roles($network_metadata, [$plugin_name])
$influxdb_address_map = get_node_to_ipaddr_map_by_network_role($influxdb_nodes, 'influxdb_vip')
$influxdb_nodes_ip = values($influxdb_address_map)
$influxdb_nodes_name = keys($influxdb_address_map)

$influxdb_vip = $network_metadata['vips'][$vip_name]['ipaddr']

$corosync_roles = [$plugin_name]

###################
$calculated_content = inline_template('

lma::influxdb::raft::nodes::name:
<% @influxdb_nodes_name.each do |name| -%>
    - <%= name %>
<% end -%>

lma::influxdb::raft::nodes::ip:
<% @influxdb_nodes_ip.each do |ip_address| -%>
    - <%= ip_address %>
<% end -%>

lma::influxdb::vip: <%= @influxdb_vip %>

corosync_roles:
<% @corosync_roles.each do |crole| -%>
    - <%= crole %>
<% end -%>

')

file {'/etc/hiera/override':
  ensure  => directory,
} ->
file { "${hiera_dir}/${plugin_yaml}":
  ensure  => file,
  content => "${calculated_content}\n",
}

package {'ruby-deep-merge':
  ensure  => 'installed',
}

file_line {"${plugin_name}_hiera_override":
  path  => '/etc/hiera.yaml',
  line  => "  - override/${plugin_name}",
  after => '  - override/module/%{calling_module}',
}
