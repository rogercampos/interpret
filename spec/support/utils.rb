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
  """

  es_yml = """
es:
  printer: Para imprimir
  comments: Comentarios
  read_more: Leer mas
  """

  file2db en_yml
  file2db es_yml
end
