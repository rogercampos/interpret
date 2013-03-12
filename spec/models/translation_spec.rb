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

  let(:es_2_yml) {"""
es:
  p1: Hola mundo!
    """}

  let(:pt_2_yml) {"""
pt:
  p1: Olá mundo
    """}

  let(:new_en_yml) {"""
en:
  p1: Hello modified world! This new translation should not be copied into database
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
  }

  let(:new_es_yml) {"""
es:
  p1: Hola mon! Esta nueva traduccion al español deberia copiarse en base de datos porque no existe previamente en :es, aunque si en :en
  new_key: Esta nueva clave debe crearse con este texto en español

  folder1:
    pr1: Nueva traduccion que tambien debe copiarse
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

  before do
    Interpret::Translation.delete_all
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

  describe ".update" do
    before do
      # Supose the database has the default contents, look at the top of this
      # file for en_yml simulated locale file
      file2db(en_yml)
      file2db(es_yml)
    end

    before do
      Dir.stub!(:"[]").and_return(['/path/to/en.yml', '/path/to/es.yml'])
      YAML.should_receive(:load_file).twice.and_return(YAML.load(new_en_yml), YAML.load(new_es_yml))
    end

    context "when Interpret.soft is false" do
      before do
        Interpret.soft = false
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
      it "should not override the contents of the existing database translations" do
        Interpret::Translation.update
        translation = Interpret::Translation.locale('en').find_by_key("p1")
        translation.value.should == "Hello world!"
      end

      it "should check if there is a language (other than I18n.default_locale) for which that key is new, and create the entry." do
        Interpret::Translation.update
        translation = Interpret::Translation.locale('es').find_by_key("p1").should_not be_nil
      end
    end
  end

  describe ".dump" do
    context "when Interpret.soft is false" do
      it "should dump all contents from yml files into database" do
        Interpret.soft = false

        # Initial database state
        file2db(en_yml)
        file2db(es_yml)

        Dir.stub!(:"[]").and_return(['/path/to/en.yml', '/path/to/es.yml'])
        YAML.should_receive(:load_file).twice.and_return(YAML.load(new_en_yml), YAML.load(new_es_yml))
        Interpret::Translation.dump

        # We use export to check for the existing database contents, which is
        # also tested in this spec file
        en_trans = Interpret::Translation.locale('en').all
        Interpret::Translation.export(en_trans).should == YAML.load(new_en_yml)

        es_trans = Interpret::Translation.locale('es').all
        Interpret::Translation.export(es_trans).should == YAML.load(new_es_yml)
      end
    end
  end

  describe ".import" do
    before do
      @file = new_en_yml
    end

    it "should update the contents of the database from the given file" do
      Interpret::Translation.delete_all
      file2db(en_yml)
      @file.stub!(:content_type).and_return("text/plain")
      Interpret::Translation.import(@file)

      trans = Interpret::Translation.locale('en').find_by_key("p1")
      trans.value.should == "Hello modified world! This new translation should not be copied into database"
    end

    it "should create new keys" do
      Interpret::Translation.delete_all
      file2db(en_yml)
      Interpret::Translation.locale('en').count

      @file.stub!(:content_type).and_return("text/plain")
      Interpret::Translation.import(@file)

      howm = Interpret::Translation.locale('en').count
      # It should create 2 new translations, from 8 to 10
      howm.should == 10
    end

    it "should not touch translations not present in the file" do
      Interpret::Translation.delete_all
      file2db(en_yml)
      @file.stub!(:content_type).and_return("text/plain")
      Interpret::Translation.import(@file)

      trans = Interpret::Translation.locale('en').find_by_key("folder1.content")
      trans.value.should == "Some large text content"
    end

    it "should not modify the database contents for other languages" do
      Interpret::Translation.delete_all
      file2db(en_yml)
      file2db(es_yml)

      @file.stub!(:content_type).and_return("text/plain")
      Interpret::Translation.import(@file)

      es_trans = Interpret::Translation.locale('es').all
      Interpret::Translation.export(es_trans).should == YAML.load(es_yml)
    end
  end

  describe "set stale" do
    it "should mark sibling translations as stale after editing the one of the app's default_language" do
      Interpret::Translation.delete_all
      file2db(en_yml)
      file2db(es_2_yml)
      file2db(pt_2_yml)

      tr = Interpret::Translation.locale("en").find_by_key("p1")
      tr.value = "New value"
      tr.save!

      Interpret::Translation.locale("es").find_by_key("p1").stale?.should be_true
      Interpret::Translation.locale("pt").find_by_key("p1").stale?.should be_true
    end

    it "should not mark as stale the translation that you're editing when it's in the app's default_language" do
      Interpret::Translation.delete_all
      file2db(en_yml)
      file2db(es_2_yml)

      tr = Interpret::Translation.locale("en").find_by_key("p1")
      tr.value = "New value"
      tr.save!

      tr.stale?.should be_false
    end

    it "should not mark sibling translations as stale after editing some that is not in the app's default_language" do
      Interpret::Translation.delete_all
      file2db(en_yml)
      file2db(es_2_yml)
      file2db(pt_2_yml)

      tr = Interpret::Translation.locale("es").find_by_key("p1")
      tr.value = "New value"
      tr.save!

      Interpret::Translation.locale("en").find_by_key("p1").stale?.should be_false
      Interpret::Translation.locale("es").find_by_key("p1").stale?.should be_false
      Interpret::Translation.locale("pt").find_by_key("p1").stale?.should be_false
    end
  end

  subject { Interpret::Translation.new(:locale => "en", :key => "cuca", :value => "monga") }

  describe "downcase key" do
    it "should be performed before validation" do
      subject.key = "PayPal.resume"
      subject.save!
      subject.key.should == "paypal.resume"
    end
  end

  describe "key format" do
    it "should not allow spaces" do
      subject.key = "not allowed spaces"
      subject.should_not be_valid
    end

    it "should allow _" do
      subject.key = "some_key.other_key"
      subject.should be_valid
    end

    it "support hypens" do
      subject.key = "parent.child-cuca"
      subject.should be_valid
    end
  end
end
