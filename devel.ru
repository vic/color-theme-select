# -*- ruby -*-
#
# Development environment

require 'rubygems'
require 'sinatra'
require 'open3'

set :environment, :development

class Sinatra::Base

  def coffee?(path)
    source = path.gsub('public/js', 'coffee').gsub(/.js$/, '.coffee')
    path =~ /.js$/ && File.file?(source)
  end

  def coffee!(path)
    source = path.gsub('public/js', 'coffee').gsub('.js', '.coffee')
    out = File.dirname(path)

    node_path = ENV['NODE_PATH'] || 
      File.expand_path('../coffee-script/lib', File.dirname(__FILE__))
    node = ENV['NODE'] || 
      File.expand_path('bin/node', File.dirname(__FILE__))
    coffee = ENV['COFFEE'] || 
      File.expand_path('bin/coffee', File.dirname(__FILE__))

    cmd = "env NODE_PATH=#{node_path.inspect} #{node} #{coffee} -co #{out} #{source}"
    puts cmd
    std = Open3.popen3 cmd
    err = std.last.read
    raise TypeError, err if err =~ /error/i
  end
  
  def static!
    return if (public_dir = settings.public).nil?
    public_dir = File.expand_path(public_dir)

    path = File.expand_path(public_dir + unescape(request.path_info))
    return if path[0, public_dir.length] != public_dir
    
    coffee!(path) if coffee?(path)

    return unless File.file?(path)
    
    env['sinatra.static_file'] = path
    send_file path, :disposition => nil
  end
end


reset = lambda do
 Sinatra::Application::reset!
 
 load 'color-theme-select.rb'
 before(&reset)
end

before(&reset)
run Sinatra::Application
