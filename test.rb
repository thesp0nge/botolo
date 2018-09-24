require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'algorithmia'

uri="https://codiceinsicuro.it/blog/hack-back-machismo-o-necessita/"

doc = Nokogiri::HTML(open(uri))
doc.css('script, link').each { |node| node.remove }
#text=doc.css('#post-content').text.squeeze(" \n").gsub!("\n", ' ')
text=doc.css('body').text.squeeze(" \n")#.gsub!("\n", ' ')

puts text
client = Algorithmia.client('simUPVK3JF2PXaat5cfMMEWTSg41')
algo = client.algo('nlp/Summarizer/0.1.8')
puts algo.pipe(text).result

