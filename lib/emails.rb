require 'nokogiri'
require 'open-uri'

# Méthode pour scraper les informations des mairies
def townhall_scrapper

  url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie'
  townhall_list = []
  mayor_links = []

  begin
    page = Nokogiri::HTML(URI.open(url))
    # je fais une boucle car je n'ai pas trouvé le xpath qui englobe les 20 mairies
    for i in (1..20)
      str = "///*[@id=\"result_#{i}\"]//a"
      mayor_links << page.xpath(str)   
    end
    mayor_links.each do |link|
      townhall_name = link.text.strip.split(" - ")[1]
      puts "> #{townhall_name}"
      # Récupère l'URL de la fiche de la mairie
      townhall_url = link[0]['href']
      email = get_townhall_email(townhall_url)
      townhall_list << {
        "townhall_name" => townhall_name,
        "email" => email
      }
    end

  rescue OpenURI::HTTPError => e
    puts "Erreur HTTP : #{e.message}"
    puts "Le site a peut-être bloqué l'accès. (Code d'erreur : #{e.io.status[0]})"
    return [] # Renvoie un tableau vide en cas d'erreur
  end

  townhall_list
end

# Méthode pour récupérer l'email sur la page d'une mairie
def get_townhall_email(url)
  begin
    page = Nokogiri::HTML(URI.open(url))
    email_link = page.at_css('a.send-mail[href^="mailto:"]')
    return email_link ? email_link.text.strip : "Email non trouvé"
  rescue OpenURI::HTTPError => e
    puts "Erreur lors de l'accès à la page de la mairie #{url}: #{e.message}"
    return "Erreur de récupération"
  end
end

puts(townhall_scrapper.map{ |k,v| "#{k} => #{v}" })
