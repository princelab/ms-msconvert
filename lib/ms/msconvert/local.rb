require 'babypool'
require 'katamari/util'

module Ms
  module Msconvert
    module Local
      QUIET_WINE_PREFIX = "export WINEDEBUG=fixme-all,err-all,warn-all,trace-all &&"

      # will add -o File.dirname(file) for each file unless -o/--outdir or
      # -f/--filelist are present
      # if multithread specifies a number, that many threads will be used at a
      # time.  if multithread is true, the method will use as many threads as
      # the machine has cores. 
      def self.run(cmd, files, multithread=false)

        cmds = files.map do |file|
          final_cmd = 
            if cmd["--outdir"] or cmd["-o"] or cmd["-f"] or cmd["--filelist"] 
              cmd
            else
              [cmd, '-o', File.dirname(file)].join(' ')
            end
          [final_cmd, file].join(" ")
        end

        if multithread
          threads_to_use = 
            if multithread.is_a?(Integer)
              multithread
            else
              Katamari::Util.number_of_processors
            end

          putsv "using a #{threads_to_use} count thread-pool"
          pool = Babypool.new(:thread_count => threads_to_use)
          cmd_reply = {}
          files.zip(cmds) do |file, cmd|
            putsv "pushing #{file} onto the multithread queue"
            pool.work(cmd) do |_cmd|
              reply = `#{_cmd}`
              cmd_reply[_cmd] = reply
            end
          end
          pool.drain
          cmd_reply.each do |cmd,reply|
            putsv "executed: #{cmd}"
            putsv reply
          end
        else
          files.zip(cmds) do |file,cmd|
            putsv "working on: #{file}"
            reply = `#{cmd}` 
            putsv reply
          end
        end
      end

      def self.putsv(*args)
        puts(*args) if $VERBOSE
      end

    end
  end
end
