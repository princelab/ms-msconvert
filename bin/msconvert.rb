#!/usr/bin/env ruby

# see wiki pages for more information on setting things up
# link????

# The following values can be overridden on the command line.
# You can also create a yaml file that will override these variables.  This
# script will look first to see if you have defined an environmental variable
# $MSCONVERT_CONFIG defining the location of a yaml config file.  Then, it
# checks if you have a ~/.msconvert_config file and will use it if you do.
# Otherwise, the following values will be used:

######################################################################
# CONFIGURATION
config =<<ENDCONFIG
# configuration is in YAML (http://www.yaml.org/spec/1.2/spec.html#Preview)
#  
# config_executable: A valid way to execute msconvert.  On linux, you
# will use something like: "wine /usr/local/pwiz-win/msconvert.exe".  If you
# are going to use msconvert through a server interface, leave the value blank
# or comment out the line completely.
config_executable: msconvert.exe

# uncomment this if you know that multithreading is okay to use.  Usually,
# this will only work well on a machine running msconvert locally (but not
# through wine).  If set to true, will use as many threads as the machine has
# processors.  If set to an Integer, will use that many threads.
# config_multithread: true

# If the value for config_executable is blank or commented out, then the
# following section will be used.
config_server_ip: 192.168.101.185

# leave this blank to use the default port
# set it to match the msconvert_server.rb script for custom port numbers.
config_server_port: 

# if your client and server have mounted access to the same drive space, you
# can use the mapping itself instead of transferring the file over the TCP 
# connection.  Set the mount point variable on the server script, too.  Leave
# blank if you are not using a mapped drive.
# config_mapped_drive: /home/jtprince/lab
config_mapped_drive:

ENDCONFIG
######################################################################

require 'yaml'
require 'ms/msconvert'
require 'katamari/util'

def has_args?(array, *others)
  others.any? {|fl| array.include?(fl) }
end

def putsv(*args) ; puts(*args) if $VERBOSE end

if ARGV.size == 0
  puts Ms::Msconvert.usage(File.basename(__FILE__))
  exit
end

## Merge all the possible config files:
config = YAML.load(config)

# do they have a ~/.msconvert_config file?
home_msconvert_config = File.join(ENV['HOME'], '.msconvert_config')
File.exist?(home_msconvert_config) && config.merge!(YAML.load_file(home_msconvert_config))

# do they have MSCONVERT_CONFIG defined?
(mcf = ENV['MSCONVERT_CONFIG']) && File.exist?(mcf) && config.merge!(YAML.load_file(mcf))

# could set to 2 or 4 also

key_to_option = {}
config_args = %w(executable multithread server_ip server_port mapped_drive).map {|v| key_to_option["config_#{v}"] = "--config_#{v}".gsub('_','-') }

(files, options, flags) = Katamari::Util.classify_arguments(ARGV, %w(-f --filelist -o --outdir -c --config -e --ext -i --contactInfo --filter).push(*config_args))

if flags.delete("--msconvert-usage")
  reply = `#{msconvert_command}`
  puts reply 
  exit
end

files.each {|file| Ms::Msconvert.check_no_spaces(file) }

key_to_option.each do |key, optflag|
  if pair = options.find {|pair| pair.first == optflag }
    config[key] = pair.last
    options.delete(pair)
  end
end

verbose_flags = %w(-v --verbose)
if has_args?(verbose_flags, *flags)
  verbose_flags.each {|fl| flags.delete(fl) }
  $VERBOSE = true
end

ext_opt = options.find {|opt,val| opt =~ /^(-e|--ext)/ }

# use mzXML unless another filetype is specified
filetype_flags = %w(mzML mzXML mgf text ms2 cms2).map {|v| "--" << v }
unless has_args?(flags, *filetype_flags)
  flags << "--mzML"
end

# add on -z unless --no-compress is specified
unless has_args?(flags, "-z", "--zlib", "--no-compress")
  flags << "-z"
end

if msconvert_base_cmd = config['config_executable']
  putsv 
  # run local
  msconvert_command = 
    if !flags.delete("--show-wine-msg") && msconvert_base_cmd[/^wine/]
      "#{Ms::Msconvert::Local::QUIET_WINE_PREFIX} #{msconvert_base_cmd}"
    else
      msconvert_base_cmd
    end
  full_cmd = [msconvert_command, flags, options.flatten].join(' ')
  Ms::Msconvert::Local.run(full_cmd, files, config['config_multithread'])
else
  full_cmd = [full_cmd, flags, options.flatten].join(' ')
  Ms::Msconvert::Client.run(full_cmd, files, config['config_multithread'])
end


