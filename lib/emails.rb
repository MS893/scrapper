require 'nokogiri'
require 'open-uri'

def get_townhall_urls

  url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie'
  town_hall_urls = {}

  begin
    doc = Nokogiri::HTML(URI.open(url))
    # Sélectionne tous les liens qui se trouvent dans les listes de villes
    doc.css('ul.list-group li a').each do |link|
      # Récupère le nom de la ville et l'URL
      town_name = link.text.strip
      town_url = link['href']
      # Ajoute la paire nom-URL au hash
      town_hall_urls[town_name] = "https://lannuaire.service-public.fr" + town_url
    end
  rescue OpenURI::HTTPError => e
    puts "Erreur HTTP : #{e.message}"
    puts "Le site a peut-être bloqué l'accès. (Code d'erreur : #{e.io.status[0]})"
    return {} # Renvoie un hash vide en cas d'erreur
  end

  town_hall_urls
end

def get_townhall_email(townhall_url)
  begin
    page = Nokogiri::HTML(URI.open(townhall_url))
    # Extrait le nom de la mairie
    name = page.xpath('//h1').text.split(' - ')[0]
    email_node = page.xpath('//h1[@class="primary"]/a[@id="email"]')
    email = email_node ? email_node.text : "Email non trouvé"
    { name => email }
  rescue => e
    puts "Erreur lors de la récupération de l'URL #{townhall_url}: #{e.message}"
    nil
  end
end

def townhall_scrapper
  townhall_urls = get_townhall_urls
  if townhall_urls.empty?
    puts "Impossible de récupérer les données."
  else
    townhall_urls.each do |town, url|
      puts "#{town}: #{url}"
    end
  end
  townhalls_with_emails = []

  townhall_urls.each do |url|
    email_hash = get_townhall_email(url)
    townhalls_with_emails << email_hash if email_hash
  end

  townhalls_with_emails
end

puts townhall_scrapper.inspect