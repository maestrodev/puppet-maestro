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
  $database = 'luceedb') inherits maestro::params {
}
