# encoding: utf-8
# Convert a locale file into database translations
def file2db(string_file)
  def parse_hash(dict, locale, prefix = "")
    res = []
    dict.keys.each do |x|
      if dict[x].kind_of?(Hash)
        res += parse_hash(dict[x], locale, "#{prefix}#{x}.")
      else
        res << Interpret::Translation.create!(:locale => locale, :key => "#{prefix}#{x}", :value => dict[x])
      end
    end
    res
  end

  hash = YAML.load string_file
  lang = hash.keys.first
  parse_hash(hash.first[1], lang).map{|x| x.save!}
end

def load_integration_data
  en_yml = """
en:
  printer: Printer Friendly
  comments: Comments
  read_more: Read more
  phrase: This is a rare phrase with non ascii chars

  section1:
    printer: Another printer

  blacklist:
    black_p1: A forbidden phrase

  missings:
    p1: Missing one
    p2: Missing two
    black: A one blacklisted
  """

  es_yml = """
es:
  printer: Para imprimir
  comments: Comentarios
  read_more: Leer mas
  phrase: Esta és una extraña frase con carácteres no ascii

  section1:
    printer: Otra impresora

  blacklist:
    black_p1: Una frase prohibida
  """

  file2db en_yml
  file2db es_yml
end

def change_translation(scope, new_value)
  bip_id = ""
  within(scope) do
    bip_id = page.all("span.best_in_place").first[:id]
  end
  bip_id = bip_id.scan(/translation_\d+/).first

  bip_area bip_id, :value, new_value
end
