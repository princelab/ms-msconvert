
module Ms
  module Msconvert
    MSCONVERT_CMD_WIN = "msconvert.exe"
    MSCONVERT_CMD_LINUX = "wine /usr/local/pwiz-win/msconvert.exe"
    DEFAULT_PORT = 22773

    module_function

    def usage(progname)
      response = <<-ENDIT
      usage: #{progname} /path/to/<file>.raw ...
      outputs: /path/to/<file>.mzML ...
        applicable arguments are passed through to msconvert
        avoid -e/--ext unless necessary to specify file extension (rather than type)
      
      args/flags passed in by default (you don't need to set them):
        --zlib             use --no-compress to remove
        --outdir <String>  defaults to the directory the file sits in
                           (set this value to overide the default)
      
      other options:
        -v --verbose               give some feedback on stdout
        --show-wine-msg            shows all wine output
        --msconvert-usage          show msconvert help message
      
      config options:
      these options can be set in the script itself, in a config file 
      (~/.msconvert_config), in a file whose location is specified by 
      $MSCONVERT_CONFIG, or at the commandline.  (later ones override)
        --config-executable <v>    location of local executable
        --config-multithread <v>   'true/false' or an Integer (thread#)
        --config-server-ip <v>     ip address of server (if applicable)     
        --config-server-port <v>   port server is using (if applicable)     
        --config-mapped-drive <v>  loc of shared mapped drive (if applicable)
      ENDIT
    end

    # takes the argument string and determines what the output file
    # extension will be.
    def expected_extension(args)
      if md = args.match(/(-e|--ext)\s+(\w+)/)
        md[2]
      elsif args["--mzXML"]
        ".mzXML"
      elsif args["--mgf"]
        ".mgf"
      elsif args["--text"]
        ".txt"
      else ; ".mzML"
      end
    end

    def check_no_spaces(path)
      msg = "\n*********************************************************************\n"
      msg << "msconvert cannot handle spaces in the file path (don't blame me)\n"
      msg << "and you have one or more spaces in your path! (look carefully):\n"
      msg << "#{path}\n"
      msg << "*********************************************************************\n"
      raise ArgumentError, msg if (path && path[" "])
    end

  end
end

require 'ms/msconvert/local'
