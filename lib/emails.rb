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
      print "*" # sorte de barre de progression (traitement long)
      next if townhall_name.empty?
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
    townhall_list[0] = "err"
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
    return "Pas d'email disponible"
  end
end



# NB : pour afficher toutes les mairies du Val d'Oise, il faudrait faire un POST sur le bouton NEXT et recommencer
# Pour éviter que RSPEC exécute le code ci-dessus.
if __FILE__ == $0
  result = townhall_scrapper()
  if (result[0] == "err") || (result.empty?)
    puts "Impossible d'afficher les mairies, le site internet est peut-être en maintenance"
  else
    puts " Liste des 20 premières villes du Val d'Oise :"
    puts(result.map{ |k,v| "#{k} => #{v}" })
  end
end
