# -*- ruby -*-
require 'open3'
require 'net/http'
require 'tempfile'

namespace :colors do
  
  COLORS_DB_URI = "http://www.colorjack.com/labs/galaxy/color_db.php?q=%s"
  COLORS_JS = <<-COLORS_JS
  var colors = %s
  var hex = function(dec){
    var h = dec.toString(16);
    if (h.length == 1){  h = '0'+h; }
    return h;
  }
  java.lang.System.out.println("/* Obtained from %s */");
  java.lang.System.out.println("require.def(\\"%s\\", {");
  for(var name in colors){
    var rgb = colors[name];
    var h = '#'+hex(rgb[0])+hex(rgb[1])+hex(rgb[2])
    var sname = name.replace(/ +/, '').toLowerCase()
    java.lang.System.out.println("\\""+sname+"\\": \\""+h+"\\",");
  }
  java.lang.System.out.println("\\"\\":\\"%s\\"");
  java.lang.System.out.println("})");
  COLORS_JS

  def colors_json(uri)
    resp = Net::HTTP.get_response(URI.parse(uri)).body
    resp.sub(/cDB\['.*'\]=/, '').sub(/\};.*/, "}")
  end

  def colors_db(mod, name)
    uri = COLORS_DB_URI % name
    lambda do |t|
      puts uri
      json = colors_json(uri)
      Tempfile.open('w') do |tmp|
        code = COLORS_JS % [json, uri, mod, name]
        tmp.puts code
        tmp.close
        cmd = "js #{tmp.path}"
        std = Open3.popen3 cmd
        out = std[1].read
        err = std[2].read
        raise err if err.length > 0
        mkdir_p File.dirname(t.to_s)
        File.open(t.to_s, 'w') do |f|
          f.puts out
        end
      end
    end
  end

  dbs = %w{X11 CNE Crayola WWW Mozilla IE}

  all = dbs.map { |c| file("public/js/colors/#{c}.js", &colors_db("colors/#{c}", c)) }
  task :all => all
end

task :colors => 'colors:all'

