# Unicorn configuration

worker_processes 1
#worker_processes 5

$app_path = File.expand_path(File.dirname(__FILE__))
#working_directory $app_path

tmp_dir = "#{$app_path}/tmp"
log_dir = "#{$app_path}/log"
dirs = []
dirs << log_dir unless (File.directory? log_dir)
dirs << tmp_dir unless (File.directory? tmp_dir)

begin
  require 'fileutils'
  FileUtils::mkdir(dirs) if dirs.length > 0
rescue
  $stderr.puts 'Unable to create directories'
end

pid "#{$app_path}/tmp/unicorn.pid"

listen '127.0.0.1:3300'

stderr_path "#{$app_path}/log/unicorn.stderr.log"
stdout_path "#{$app_path}/log/unicorn.stdout.log"

before_fork do |server, worker|
  old_pid = "#{$app_path}/tmp/unicorn.pid.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
