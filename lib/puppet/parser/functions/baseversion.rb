module Puppet::Parser::Functions
  newfunction(:baseversion, :type => :rvalue) do |args|
    version = args[0]
    # TODO: put this in a library so it can be reused
     # If the version is a Maven snapshot, transform the base version to it's
     # SNAPSHOT indicator
     regex = /^(.*)-[0-9]{8}\.[0-9]{6}-[0-9]+$/
     if version =~ regex
       base_version = regex.match(version)[1] + "-SNAPSHOT"     
     else
       base_version = version
     end
     base_version
  end
end