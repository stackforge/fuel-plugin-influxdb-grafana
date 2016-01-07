#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
# == Class: lma_monitoring_analytics::influxdb_create_db

define lma_monitoring_analytics::influxdb_create_db (
  $influxdb_dbname    = undef,
  $influxdb_username  = undef,
  $influxdb_userpass  = undef,
  $influxdb_rootpass  = undef,
) {

  $create_db = $lma_monitoring_analytics::params::influxdb_create_db_script

  file { $create_db:
    owner   => 'root',
    group   => 'root',
    mode    => '0740',
    content => template('lma_monitoring_analytics/create_db.sh.erb'),
  }

  exec { 'create_db_script':
    command => $create_db,
    require => [File[$create_db], Service['influxdb']],
  }
}
