#!/usr/bin/env ruby

require 'yaml'
require 'socket'
require 'ms/msconvert/server'

################################################################################
# SETTINGS:
settings =<<END_YAML
# if you have a different command than: #{Ms::Msconvert::MSCONVERT_CMD_WIN}
# uncomment and put it here
# server_config_msconvert_cmd: <msconvert command>

# if you are going to use a shared mounted directory, uncomment and put the
# server side location here:
# server_config_mount_dir: /home/jtprince/lab

# if you want to use a particular subdirectory under the shared mounted directory
# for temporary files
# server_config_relative_tmp: tmp

# if you want to use a different port than the default: #{Ms::Msconvert::DEFAULT_PORT} set it here
# server_config_port: 99999
END_YAML


Ms::Msconvert::MSCONVERT_CMD_WIN

# you can change this if you like, just make sure the client knows
PORT = Ms::Msconvert::DEFAULT_PORT
################################################################################

puts "starting up #{File.basename(__FILE__)} and listening..."

server = Katamari::Msconvert::MountedServer::Server.new(MSCONVERT_CMD, PORT, BASE_DIR)
server.run

