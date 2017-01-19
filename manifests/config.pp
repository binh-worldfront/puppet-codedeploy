# == Class codedeploy::config
#
# This class is called from codedeploy for install.
#
class codedeploy::config (
  $log_aws_wire      = $::codedeploy::params::log_aws_wire,
  $log_dir           = $::codedeploy::params::log_dir,
  $pid_dir           = $::codedeploy::params::pid_dir,
  $program_name      = $::codedeploy::params::program_name,
  $root_dir          = $::codedeploy::params::root_dir,
  $verbose           = $::codedeploy::params::verbose,
  $wait_between_runs = $::codedeploy::params::wait_between_runs,
  $max_revisions     = $::codedeploy::params::max_revisions,
  $proxy_uri         = '',
) {
  case $::osfamily {
    'RedHat', 'Amazon', 'Debian': {
      file {
        $::codedeploy::config_location:
          ensure  => file,
          content => template('codedeploy/codedeployagent.yml.erb'),
          mode    => '0644',
          owner   => root,
          group   => root,
          notify  => Service[$::codedeploy::service_name];
      }
    }
    default: {
    }
  }

  if $::codedeploy::user {
    file_line{'set codedeploy user':
      ensure => present,
      path   => '/etc/init.d/codedeploy-agent',
      match  => '^CODEDEPLOY_USER=.*',
      line   => "CODEDEPLOY_USER=\"${::codedeploy::user}\"",
      notify => Service[$::codedeploy::service_name]
    }
  }
}