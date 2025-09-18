require_relative '../lib/emails.rb'

# 1) le fonctionnement de base de ton programme (pas d'erreur ni de retour vide)
# 2) que ton programme sort bien un array cohérent (vérifier la présence de Ableiges, vérifier que l’array est de taille cohérente, etc.).
result = townhall_scrapper()

describe 'Basic functionality' do
  # Hint: 'no error, and no empty array'

  it 'tells me if there is no error' do
    expect(result).not_to contain_exactly("err")
  end

  it 'tells me if the array is not empty' do
    expect(result).not_to be_nil
  end

end

describe 'array consistent' do
  # Hint: array seems ok

  it 'tells me if one townhall exist' do
    expect(result.any? { |clé, valeur| clé.key?('Ableiges') }).to eq(true)
  end

  it 'tells me if the array size is consistent' do
    expect(result.length).to be > 10
  end

end
