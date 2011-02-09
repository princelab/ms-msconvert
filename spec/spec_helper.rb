require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'spec/more'

Bacon.summary_on_exit

TESTFILES = File.dirname(__FILE__) + "/testfiles"
BINDIR = File.dirname(__FILE__) + "/../bin"
LIBDIR = File.dirname(__FILE__) + "/../lib"
