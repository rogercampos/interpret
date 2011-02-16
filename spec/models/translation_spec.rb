require 'spec_helper'

describe Interpret::Translation do

  let(:en_yml) {"""
en:
  p1: Hello world!
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
  }

  let(:es_yml) {"""
es:
  p1: Hola mundo!
  folder1:
    pr1: hola
  folder2:
    pr1: Algun otro texto aqui
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

  def file2db(string_file)
    hash = YAML.load string_file

    lang = hash.keys.first
    records = Interpret::Translation.send(:parse_hash, hash.first[1], lang)
    Interpret::Translation.transaction do
      records.each {|x| x.save!}
    end
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
    pending
  end
end
