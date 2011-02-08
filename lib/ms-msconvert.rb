
require 'sinatra'

MSCONVERT = "wine /usr/local/pwiz-win/msconvert.exe"
SERVER_TMPDIR = "/tmp"

get '/msconvert_server' do
end

# curl -v -F "data=@/home/jtprince/tmp/Liver_sample_lysis.raw" http://localhost:4567/mzML/Liver_sample_lysis.raw
# the little '@' cannot be left out, mind you.

post '/:convert_type/:filename' do
  ext = params[:convert_type]
  tmp_datafile = params[:data][:tempfile]
  renamed_datafile = File.join(SERVER_TMPDIR, params[:filename])
  FileUtils.mv tmp_datafile, renamed_datafile
  cmd = "#{MSCONVERT} -z --#{params[:convert_type]} -o #{SERVER_TMPDIR} #{renamed_datafile}"
  reply = `#{cmd}`
  expected_output = renamed_datafile.sub(/\.raw$/i, '.'+ext)
  send_file(expected_output, :disposition => 'attachment', :filename => File.basename(expected_output))
  reply
end
