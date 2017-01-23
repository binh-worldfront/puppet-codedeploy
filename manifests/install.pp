# == Class codedeploy::install
#
# This class is called from codedeploy for install.
#
class codedeploy::install {

  case $::osfamily {
    'RedHat', 'Amazon': {
      package { $::codedeploy::package_name:
        ensure   => present,
        provider => 'rpm',
        source   => $::codedeploy::package_url,
      }
    }
    'windows': {
      package { $::codedeploy::package_name:
        ensure => present,
        source => $::codedeploy::package_url,
      }
    }
    'Debian': {
      if $::codedeploy::user {
        file {[$::codedeploy::base_dir, $::codedeploy::log_dir]:
          ensure  => directory,
          owner   => $::codedeploy::user,
          group   => $::codedeploy::user,
          before  => Exec['install_codedeploy_agent'],
        }
      }

      if ! defined(Package['awscli']) {
        package { 'awscli':
          ensure => present,
        }
      }
      include ::staging
      staging::file {'install':
        source  => "https://aws-codedeploy-${codedeploy::region}.s3.amazonaws.com/latest/install",
        owner   => 'root',
        group   => 'root',
        mode    => '0740',

      }

      Class['staging'] -> Class['codedeploy::install']
      File<| $title == "${::staging::path}/codedeploy/install" |> ~> Exec['install_codedeploy_agent']

      exec { 'install_codedeploy_agent':
        command     => "${::staging::path}/codedeploy/install auto",
        refreshonly => true,
      }

      ~> exec { 'stop_codeploy_agent_after_install':
        command     => "service ${::codedeploy::service_name} stop",
        refreshonly => true
      }

      ~> exec { 'update_codedeploy_direcotries':
        command     => "chown -R ${::codedeploy::user}: ${::codedeploy::base_dir}",
        refreshonly => true
      }

      ~> exec { 'update_codedeploy_log_direcotries':
        command     => "chown -R ${::codedeploy::user}: ${::codedeploy::log_dir}",
        refreshonly => true
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
