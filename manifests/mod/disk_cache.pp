class apache::mod::disk_cache (
  $cache_root     = undef,
  $apache_version = undef,
) {
  include ::apache
  include ::apache::mod::cache

  $_apache_version = pick($apache_version, $apache::apache_version)
  if $cache_root {
    $_cache_root = $cache_root
  }
  elsif versioncmp($_apache_version, '2.4') >= 0 {
    $_cache_root = $::osfamily ? {
      'debian'  => '/var/cache/apache2/mod_cache_disk',
      'redhat'  => '/var/cache/httpd/proxy',
      'freebsd' => '/var/cache/mod_cache_disk',
    }
  }
  else {
    $_cache_root = $::osfamily ? {
      'debian'  => '/var/cache/apache2/mod_disk_cache',
      'redhat'  => '/var/cache/mod_proxy',
      'freebsd' => '/var/cache/mod_disk_cache',
    }
  }

  if versioncmp($_apache_version, '2.4') >= 0 {
    apache::mod { 'cache_disk': }
  }
  else {
    apache::mod { 'disk_cache': }
  }

  Class['::apache::mod::cache'] -> Class['::apache::mod::disk_cache']

  # Template uses $_cache_root
  file { 'disk_cache.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/disk_cache.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/disk_cache.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
