forge 'http://forge.puppetlabs.com'

# Currently pegged to 2.0.1, as 2.1.0 includes concat and seems to have
# problems with rspec tests, requires further investigation

if ENV['RACK_ENV'] == "development"
  mod 'puppetlabs/java',       '~>0.2.0'
  mod 'maestrodev/rvm',        '~>1.0'
end

mod 'maestrodev/wget',       '>=1.0.0'
mod 'maestrodev/maven',      '>=1.0.0'
mod 'puppetlabs/stdlib',     '>=2.5.1'
mod 'puppetlabs/postgresql', '2.0.1'
