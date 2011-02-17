# encoding: utf-8
require 'spec_helper'

describe Interpret::Translation do

  let(:en_yml) {"""
en:
  p1: Hello world!
  folder1:
    pr1: Hi
    content: Some large text content
  folder2:
    pr1: Some other text here
  folder3:
    pr1: More phrases
    sub:
      name: This is a 2 level subfolder
      subsub:
        name: With another nested folder inside
    other:
      name: folder
    """
  }

  let(:es_yml) {"""
es:
  p1: Hola mundo!
  folder2:
    pr1: Algun otro texto aqui
    content: Un largo parrafo con contenido
  folder3:
    pr1: Mas frases aleatorias
    sub:
      name: Esta es una subcarpeta de segundo nivel
      subsub:
        name: Con otra carpeta anidada en su interior
    other:
      name: carpeta
    """
  }

  # Convert a locale file into database translations
  def file2db(string_file)
    def parse_hash(dict, locale, prefix = "")
      res = []
      dict.keys.each do |x|
        if dict[x].kind_of?(Hash)
          res += parse_hash(dict[x], locale, "#{prefix}#{x}.")
        else
          res << Interpret::Translation.new(:locale => locale, :key => "#{prefix}#{x}", :value => dict[x])
        end
      end
      res
    end

    hash = YAML.load string_file
    lang = hash.keys.first
    Interpret::Translation.transaction do
      parse_hash(hash.first[1], lang).map{|x| x.save!}
    end
  end

  before do
    I18n.stub!(:default_locale).and_return('en')
  end

  describe ".get_tree" do
    it "should return a hash representing a tree folder structure of the i18n keys" do
      file2db(en_yml)

      Interpret::Translation.get_tree('en').should == {'index' => {
        'folder1' => {},
        'folder2' => {},
        'folder3' => {
          'sub' => {
            'subsub' => {}
          },
          'other' => {}
        }
      }}
    end
  end

  describe ".export" do
    it "should return a hash representing the yml locale file for the given translations" do
      file2db(en_yml)

      translations = Interpret::Translation.all
      Interpret::Translation.export(translations).should == YAML.load(en_yml)
    end
  end

  describe ".import" do
    pending
  end

  describe ".dump" do
    pending
  end

  describe ".update" do
    before(:all) do
      @new_en_yml = """
en:
  p1: Hello modified world! This new translation should not copied into database
  new_key: This new key should be created with this english text
  new_key_in_en: This new key that only exists in english should be created only in english

  folder1:
    pr1: Hi
  folder2:
    pr1: Some other text here
  folder3:
    pr1: More phrases
    sub:
      name: This is a 2 level subfolder
      subsub:
        name: With another nested folder inside
    other:
      name: folder
      """
      @new_es_yml = """
es:
  p1: Hola mon! Esta nueva traduccion al español no deberia copiarse a base de datos
  new_key: Esta nueva clave debe crearse con este texto en español

  folder1:
    pr1: Hi
  folder2:
    pr1: Some other text here
  folder3:
    pr1: More phrases
    sub:
      name: This is a 2 level subfolder
      subsub:
        name: With another nested folder inside
    other:
      name: folder
      """

      # Supose the database has the default contents, look at the top of this
      # file for en_yml simulated locale file
      file2db(en_yml)
    end

    before do
      Dir.stub!(:"[]").and_return(['/path/to/en.yml', '/path/to/es.yml'])
      YAML.should_receive(:load_file).twice.and_return(YAML.load(@new_en_yml), YAML.load(@new_es_yml))
    end

    context "when a key exists in database but not in yml files [for I18n.default_locale]" do
      it "should remove that key from database for I18n.default_locale" do
        Interpret::Translation.update
        Interpret::Translation.locale('en').find_by_key("folder1.content").should be_nil
      end

      it "should remove that key if it exists for any other language in database" do
        Interpret::Translation.update
        Interpret::Translation.locale('es').find_by_key("folder1.content").should be_nil
      end
    end

    context "when a key exists in yml files but not in database [for I18.default_locale]" do
      it "should create the key for I18n.default_locale with the value from yml files" do
        Interpret::Translation.update
        translation = Interpret::Translation.locale('en').find_by_key("new_key")
        translation.value.should == "This new key should be created with this english text"
      end

      it "should not create an entry for a key in a language that do not have it" do
        Interpret::Translation.update
        Interpret::Translation.locale('es').find_by_key("new_key_in_en").should be_nil
      end

      it "should look for that key in other languages from yml files and create the existing ones." do
        Interpret::Translation.update
        translation = Interpret::Translation.locale('es').find_by_key("new_key")
        translation.value.should == "Esta nueva clave debe crearse con este texto en español"
      end
    end

    context "when a key exists in both yml files and database [for I18n.default_locale]" do
      it "should not override the contents of the existing database translations"
      it "should check if there is a language for which the key exists in yml files but not in database, and create the new entry."
    end
  end
end
