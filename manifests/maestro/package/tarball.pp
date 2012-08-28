class maestro::maestro::package::tarball(
  $repo,
  $version,
  $base_version,
  $srcdir,
  $homedir,
  $basedir)
{
  if ! defined(File[$srcdir]) {
    file {$srcdir:
      ensure => directory,
      before => Wget::Authfetch["fetch-maestro"],
    }
  }
  wget::authfetch { "fetch-maestro":
     user => $repo['username'],
     password => $repo['password'],
     source => "${repo['url']}/com/maestrodev/maestro/maestro-jetty/$base_version/maestro-jetty-${version}-bin.tar.gz",
     destination => "$srcdir/maestro-jetty-${version}-bin.tar.gz",
   } ->
   exec {"rm -rf $installdir/maestro-${base_version}":
      unless => "egrep \"^${version}$\" $srcdir/maestro-jetty.version",
   } ->
   exec { "maestro":
     command => "tar zxvf $srcdir/maestro-jetty-${version}-bin.tar.gz",
     creates => "$installdir/maestro-$base_version",
     cwd => $installdir,
   } ->
   exec { "chown -R ${user} ${installdir}/maestro-$base_version":
     require => User[$user],
   } ->
   file { "$installdir/maestro-$base_version/bin":
     mode => 755,
     recurse => true,
   } ->
   file { "$homedir":
     ensure => link,
     target => "$installdir/maestro-$base_version"
   } ->   
   file { "${srcdir}/maestro-jetty.version":
     content => "${version}\n",
   } ->
   # Touch the installation package even if current, so that it isn't deleted
   exec { "touch $srcdir/maestro-jetty-${version}-bin.tar.gz":
   } ->
   tidy { "tidy-maestro":
     age => "1d",
     matches => "maestro-jetty-*",
     recurse => true,
     path => $srcdir,
   }

   file { "$basedir/conf/wrapper.conf":
     ensure => link,
     target => "$homedir/conf/wrapper.conf",
     require => File[$homedir,"${basedir}/conf"],
   }
   
   file { "$basedir/conf/webdefault.xml":
     ensure => link,
     target => "$homedir/conf/webdefault.xml",
     require => File[$homedir,"${basedir}/conf"],
   }
   
   file { "$basedir/conf/jetty-jmx.xml":
     ensure => link,
     target => "$homedir/conf/jetty-jmx.xml",
     require => File[$homedir,"${basedir}/conf"],
   }
   
   
}