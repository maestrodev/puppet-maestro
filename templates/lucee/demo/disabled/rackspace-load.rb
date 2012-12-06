#! /usr/bin/env ruby

# Script to generate multiple compositions for load testing
# Copy the output to MAESTRO_HOME/apps/lucee/WEB-INF/config/demo
# and Maestro will import it on the next restart

require 'rubygems'
require 'json'

json = JSON.parse(File.read('rackspace-load.json'))

maven_composition = json['compositions'].find{|c| c['name']=='Centrepoint with Maven'}
# repo = maven_composition['composition_configurations'].find{|cc| cc['name']=='repo'}
# repo['value'] = 'http://localhost:8082/archiva'

bootstrap_composition = json['compositions'].find{|c| c['name']=='Start'}
schedule_list = bootstrap_composition['composition_tasks'].find{|ct| ct['name']=='schedule multiple'}['options']['compositions']['value']

(1..30).each do |i|
  new_composition = maven_composition.clone
  new_composition['name'] = "#{maven_composition['name']} #{i}"
  schedule_list << new_composition['name']
  json['compositions'] << new_composition
end

puts JSON.pretty_generate(json)
