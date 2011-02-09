require 'spec_helper'

require 'ms/msconvert'

# you can set an env var: $MSCONVERT_CMD
LOCAL_MSCONVERT_CMD = ENV["MSCONVERT_CMD"] || "wine /usr/local/pwiz-win/msconvert.exe"
if `#{LOCAL_MSCONVERT_CMD} 2>&1` =~ /usage:/i

  describe "msconvert with local executable (remote dir and compression by default)" do

    before do
      @rawfile = TESTFILES + "/Liver_sample_lysis_FTMS_860-910.raw"
      @msconvert_rb = "ruby -I #{LIBDIR} #{BINDIR}/msconvert.rb"
      @base_conversion = "#{@msconvert_rb} #{@rawfile} --config-executable '#{LOCAL_MSCONVERT_CMD}'"
      @mzml_file = @rawfile.sub('.raw', '.mzML')
      @mzxml_file = @rawfile.sub('.raw', '.mzXML')
    end

    after do
      [@mzml_file, @mzxml_file].each {|f| File.unlink(f) if File.exist?(f) }
    end

    it "quietly converts raw to mzML (by default)" do
      reply = `#{@base_conversion}`
      reply.size.is 0
      ok File.exist?(@mzml_file)
      xml = IO.read(@mzml_file)
      xml.matches /<spectrumList /m
      xml.matches /name="zlib compression"/m
    end

    it "quietly converts raw to mzXML" do
      reply = `#{@base_conversion} --mzXML`
      reply.size.is 0
      ok File.exist?(@mzxml_file)
      xml = IO.read(@mzxml_file)
      xml.matches /<scan num/m
      xml.matches /compressionType="zlib"/m
    end

    it 'converts verbosely with -v/--verbose' do
      reply = `#{@base_conversion} -v`
      ok(  reply.size > 0 )
      reply = `#{@base_conversion} --verbose`
      ok(  reply.size > 0  )
    end

  end
else
  xdescribe "msconvert with local executable [local executable doesn't exist! for testing set with env var: $MSCONVERT_CMD]"
end

describe "msconvert using server over http" do

  before do
  end

  it 'works' do
    fails until implemented
  end

end
