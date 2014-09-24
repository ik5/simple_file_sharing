
# copyright (c) Ido Kanner idokan at@at gmail dot.dot com
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


class App < Sinatra::Base
  UPLOAD_DIR = '' # Place here were to store the information  ''
  BASE_URL   = '' # place here the full URL to redirect to
  configure do
    enable :logging, :sessions
    set :root, $app_path
    set :public_folder, 'public'
    set :views, 'views'

    register Sinatra::Partial
    set :partial_template_engine, :erb
  end

  def self.new(*)
    app = Rack::Auth::Digest::MD5.new(super) do |username|
      {'username' => 'password'}[username]
    end
    app.realm = 'Welcome'
    app.opaque = '' # place here some crypt key
    app
  end

  helpers do

    def human_size(size, si = false)
      return '0' if size == 0
      base = si ? 1000 : 1024
      bytes = %w(B KB MB GB TB PB EB ZB YB)

      cnt  = Math.log(size, base).floor
      size = size / (base * 1.0) ** cnt

      fmt  = size < 10 ? '%.1f %s' : '%i %s'
      sprintf(fmt, size, bytes[cnt])
    end

  end

  def get_files
    files = []
    Dir[UPLOAD_DIR + '*'].each do |f|
      stat = File.new(f).stat
      file = {name: File.basename(f), size: stat.size, date: stat.mtime}
      files << file
    end

    files.sort { |a,b| b[:date] <=> a[:date] }
  end

  def set_uploadname(ext)
    num  = sprintf('%02d', Dir[UPLOAD_DIR + "upload*#{ext}"].length + 1)
    file = UPLOAD_DIR + "upload#{num}#{ext}"
    file
  end

  get '/' do
    @files = get_files
    erb :index
  end

  post '/uf' do
    fname = params[:file][:filename] rescue ''

    if fname.empty?
      status 400
      return body "Bad request, no file was given. <a href=\"#{BASE_URL}\">Press here to return</a>"
    end

    ext   = File.extname(fname)
    file  = set_uploadname(ext)
    # try to make sure that the file does not exists ...
    while (File.exists?(file)) do
      file = set_uploadname(ext)
    end

    File.open(file, 'w') do |f|
      f.write(params[:file][:tempfile].read)
    end

    redirect to(BASE_URL)
  end

  get '/files/:name' do |name|
    n = name.gsub(/[^a-zA-Z0-9\.\-_\s\p{Hebrew}]/, '')
    unless File.exists?(UPLOAD_DIR + n)
      status 404
      body "Requested file was not found"
    end

    send_file(UPLOAD_DIR + n, disposition: :attachment)
  end

end
