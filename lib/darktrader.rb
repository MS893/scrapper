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
  end
  cryptos
end

puts crypto_scrapper
# toutes les valeurs ne sont pas affichées et le sont lorsque l'on scroll la page vers le bas