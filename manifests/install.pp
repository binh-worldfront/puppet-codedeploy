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
      if ! defined(Package['awscli']) {
        package { 'awscli':
          ensure => present,
        }
      }
      include ::staging
      staging::file {'download_codedeploy_installer':
        source  => "https://aws-codedeploy-${codedeploy::region}.s3.amazonaws.com/latest/install",
      }
      file { "${::staging::path}/install":
        ensure    => file,
        owner     => 'root',
        group     => 'root',
        mode      => '0740',
        subscribe => Staging::File['download_codedeploy_installer'],
        notify    => Exec['install_codedeploy_agent'],
      }
      exec { 'install_codedeploy_agent':
        command     => "${::staging::path}/install auto",
        refreshonly => true,
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
