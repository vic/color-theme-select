# -*- ruby -*- 

namespace :less do

  lessify = lambda do |t|
    input = t.prerequisites.first
    output = t.to_s
    sh 'bin/theme2less.sh', input, output
  end

  colors_js = file('public/js/colors.js')
  less_js = file('public/js/emacs/theme/less.js')
  all = Dir.glob('public/themes/*/json/*.json').sort.map {|f|
    file(f.gsub(/json/, 'less') => 
         [f, less_js, colors_js], &lessify)
  }

  task :all => all

  task :light => 'public/themes/base/less/base-light.less'
  task :dark => 'public/themes/base/less/base-dark.less'
  task :base => [:light, :dark]

  task :themes => task(:all).prerequisites - 
    task(:light).prerequisites - 
    task(:dark).prerequisites

end

task :less => ["less:base"]
