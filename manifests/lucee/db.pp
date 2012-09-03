# "database": {
#   "server": "postgres",
#   "host": "localhost",
#   "port": 5432,
#   "user": "<%= db_username %>",
#   "pass": "<%= db_password %>",
#   "database_name": "<%= db_name %>"
# },
class maestro::lucee::db(
  $username = 'maestro',
  $password = 'maestro',
  $type = 'postgres',
  $host = 'localhost',
  $port = 5432,
  $database = 'luceedb') {

  augeas { 'maestro-db':
    changes => [
      "set /files/etc/maestro_lucee.json/dict//entry[.='database']//entry[.='server']/string ${type}",
      "set /files/etc/maestro_lucee.json/dict//entry[.='database']//entry[.='host']/string ${host}",
      "set /files/etc/maestro_lucee.json/dict//entry[.='database']//entry[.='port']/number ${port}",
      "set /files/etc/maestro_lucee.json/dict//entry[.='database']//entry[.='user']/string ${username}",
      "set /files/etc/maestro_lucee.json/dict//entry[.='database']//entry[.='pass']/string ${password}",
      "set /files/etc/maestro_lucee.json/dict//entry[.='database']//entry[.='database_name']/string ${database}",
    ],
    incl    => '/etc/maestro_lucee.json',
    lens    => 'Json.lns',
    require => File['/etc/maestro_lucee.json'],
    notify  => Service['maestro'],
  }

}
