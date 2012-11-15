class maestro::repository($username, $password) {

  $maestrodev = {
    id       => 'maestro-mirror',
    username => $username,
    password => $password,
    url      => 'https://repo.maestrodev.com/archiva/repository/all',
  }

}
