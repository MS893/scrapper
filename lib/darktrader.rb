require 'http'
require 'nokogiri'
require 'open-uri'

def crypto_scrapper

  cryptos = []

  begin
    
    url = "https://coinmarketcap.com/all/views/all/"
    page = Nokogiri::HTML(URI.open(url))
    
    # Sélectionne toutes les lignes <tr> dans le corps du tableau <tbody>
    rows = page.xpath('//table/tbody/tr')

    rows.each do |row|
      # Pour chaque ligne, trouve le nom et la valeur en utilisant des XPaths relatifs
      name = row.xpath('.//td[2]//a[1]').text
      price = row.xpath('.//td[5]//span').text
      cryptos << { name => price } unless name.empty?
    end

  rescue => e
    puts "Erreur : #{e}"
    cryptos[0] = "err"
  end

  cryptos

end



# Pour éviter que RSPEC exécute le code ci-dessus.
if __FILE__ == $0
  result = crypto_scrapper()
  if (result[0] == "err") || (result.empty?)
    puts "Impossible d'afficher les cryptos, le site internet est peut-être en maintenance"
  else
    puts result.map{ |k,v| "#{k} => #{v}" }
    puts "NB : seules les valeurs générées la 1ere fois sont affichées, il faudrait scroller pour afficher la suite"
  end
end
