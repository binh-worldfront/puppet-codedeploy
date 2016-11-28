# == Class codedeploy::config
#
# This class is called from codedeploy for install.
#
class codedeploy::config {
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
    file {[$::codedeploy::base_dir, $::codedeploy::log_dir]:
      ensure  => directory,
      owner   => $::codedeploy::user,
      group   => $::codedeploy::user,
      recurse => true
    }

    file_line{'set codedeploy user':
      ensure => present,
      path   => '/etc/init.d/codedeploy-agent',
      match  => '^CODEDEPLOY_USER=.*',
      line   => "CODEDEPLOY_USER=\"${::codedeploy::user}\"",
      notify => Service[$::codedeploy::service_name]
    }
  }
}