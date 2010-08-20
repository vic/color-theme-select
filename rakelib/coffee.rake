# -*- ruby -*- 

require 'open3'

namespace :coffee do

  def node_path
    ENV['NODE_PATH'] || File.expand_path('../../coffee-script/lib', 
                                         File.dirname(__FILE__))
  end
  def node
    ENV['NODE'] || File.expand_path('../bin/node', File.dirname(__FILE__))
  end
  def coffee 
    ENV['COFFEE'] || File.expand_path('../bin/coffee', File.dirname(__FILE__))
  end
  
  def compile(src, out)
    dir = File.dirname(out)
    cmd = "env NODE_PATH=#{node_path.inspect} #{node} #{coffee} -co #{dir} #{src}"
    puts cmd
    std = Open3.popen3 cmd
    err = std.last.read
    raise err if err =~ /error/i
  end
  
  task :compile => Dir['coffee/**/*.coffee'].map { |c|
    o = c.sub('coffee/', 'public/js/').sub('.coffee', '.js')
    file(o => c) { compile(c, o) }
  }

  file('public/js/emacs/theme/less.js' => file('public/js/emacs/theme/normalize.js'))
  file('public/js/emacs/theme/lisp.js' => file('public/js/emacs/theme/normalize.js'))

end
task :coffee => ["coffee:compile"]
