require 'nokogiri'
require 'open-uri'

def deputy_scrapper
  # URL de la liste des députés
  url = 'https://www2.assemblee-nationale.fr/deputes/liste/alphabetique'

  # Crée un tableau pour stocker les hashes des députés
  deputies_list = []

  begin
    page = Nokogiri::HTML(URI.open(url))

    # Sélectionne tous les liens <a> contenant les noms des députés dans la liste
    deputy_links = page.xpath('//*[@id="deputes-list"]//a')

    deputy_links.first(20).each do |link|

      full_name = link.text.strip
      puts "> #{full_name}"

      # Ignore les entrées vides ou invalides
      next if full_name.empty? || !full_name.start_with?('M. ', 'Mme ')

      # Sépare le prénom et le nom
      parts = full_name.split(' ').drop(1) # Enlève "M." ou "Mme"
      first_name = parts.first
      last_name = parts.drop(1).join(' ')

      # Récupère l'URL relative de la fiche du député et la transforme en URL absolue
      relative_url = link['href']
      deputy_url = "https://www2.assemblee-nationale.fr" + relative_url
      email = deputy_email(deputy_url).split(" ")

      # Initialise un hash pour le député
      deputies_list << {
        "first_name" => first_name,
        "last_name" => last_name,
        "email" => email[1]
      }
    end
  rescue OpenURI::HTTPError => e
    puts "Erreur d'accès à la page principale: #{e.message}"
  end

  deputies_list
end

# récupère les emails
def deputy_email(url)
  begin
    page = Nokogiri::HTML(URI.open(url))
    email_link = page.at_css('a[href^="mailto:"]')
    return email_link ? email_link.text.strip : "Email non trouvé"
  rescue OpenURI::HTTPError => e
    puts "Erreur lors de l'accès à la page du député #{url}: #{e.message}"
    return "Erreur de récupération"
  end
end

puts "Patientez, le traitement est long !"
# Affiche la liste des 20 premiers députés sinon traitement trop long
puts(deputy_scrapper.map{ |k,v| "#{k} => #{v}" })
