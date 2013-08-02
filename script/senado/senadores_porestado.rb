require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'optparse'
require 'json'
require 'iconv'


def estado(num)
  url = "http://www.senado.gob.mx/library/int/entidad/estados.php?edo="
  members = []  
  open("#{url}#{num}", "User-Agent" => "Ruby/#{RUBY_VERSION}") { |f| 
    response = f.read
    doc = Hpricot(Iconv.conv('utf-8//IGNORE', 'ISO-8859-1', response))
    edo = (doc/"table > tr").first.at("td").inner_html.gsub(/<\/?[^>]*>/, "")
    (doc/"table > tr").each do |tab| 
      (tab/"table").each do |t1|
	      member = {}
        member[:avatar] = (t1/"td:nth-child(1)").first.at("img").attributes['src']
	      info = (t1/"td:nth-child(2)") 
	      img = info.first.at("img")
	      member[:name] = info.inner_html.sub(img.to_s, "").gsub("Sen. ", "").gsub(",<br />","").gsub(/\(.*?\)/, "").gsub(/\s+/, ' ').strip
	      member[:partido] = img.attributes['src'].gsub(/[images\/partido .jpg]/, "")
	      member[:edo] = edo.chop
	      members << member
      end
    end

  }
  members
end

todos = []


arg1 = ARGV[0]
arg2 = ARGV[1].to_i

help = <<eos
USO: \n
ruby senadores_porestado [--opcion]\n
 --todos            Lista completa \n
 --estado <num>     Del num 2 al 32
eos

if  arg1 == "--todos"
   (2..32).each do |e| todos += estado(e) end
elsif arg1 == "--estado" and (arg2 > 1 and arg2 < 32) 
   todos += estado(arg2)
else
   puts help
end

puts todos.to_json unless todos.empty?

