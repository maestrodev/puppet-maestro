class maestro::repository(
  $url = 'https://repo.maestrodev.com/archiva/repository/all',
  $username, 
  $password
) {

  $maestrodev = {
    username => $username,
    password => $password,
    url      => $url,
  }

}
