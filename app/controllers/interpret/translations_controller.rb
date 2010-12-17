class Interpret::TranslationsController < ApplicationController

  # GET /translations
  # GET /translations.xml
  def index
    @translations = Translation.where(:locale => I18n.locale).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @translations }
    end
  end

  # GET /translations/1
  # GET /translations/1.xml
  def show
    @translation = Translation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @translation }
    end
  end

  # GET /translations/1/edit
  def edit
    @translation = Translation.find(params[:id])
  end

  # PUT /translations/1
  # PUT /translations/1.xml
  def update
    @translation = Translation.find(params[:id])
    old_value = @translation.value

    respond_to do |format|
      if @translation.update_attributes(params[:translation])
        expire_action :controller => 'static', :action => 'index'
        expire_action :controller => 'static', :action => 'contact'
        expire_action :controller => 'static', :action => 'gallery'

        format.html { redirect_to(translations_url)}
        TRANSLATION_LOGGER.info("by [#{current_user}]. Locale: [#{@translation.locale}], key: [#{@translation.key}]. The translation has been changed from [#{old_value}] to [#{@translation.value}]")

        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @translation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def fetch
    translations = Translation.locale(I18n.locale)
    hash = Translation.as_hash(translations)
    text = hash.ya2yaml

    send_data text[5..text.length], :filename => "#{I18n.locale}.yml"
  end

  def change_role
    @new_role = params[:translation][:role]
    @translation = Translation.find(params[:id])
    @translation.update_attribute :role, @new_role
  end

  def upload_locale
    unless params.has_key? :file
      flash[:alert] = "Tienes que subir un archivo"
      redirect_to translations_url
      return
    end

    file = params[:file]
    if file.content_type && file.content_type.match(/^text\/.*/).nil?
      flash[:alert] = "Tienes que subir un archivo en formato de texto"
      redirect_to translations_url
      return
    end

    begin
      hash = YAML.load file
      unless hash.keys.count == 1
        flash[:alert] = "El archivo YAML debe tener una sola clave inicial con el nombre del idioma"
        redirect_to translations_url
        return
      end

      unless hash.keys.first.to_s == I18n.locale.to_s
        flash[:alert] = "Estas subiendo un archivo de traducciones en un idioma que no coincide con el actual"
        redirect_to translations_url
        return
      end

      require 'translations_utils'
      changes = update_locale_from_hash(I18n.locale, hash.values[0])
      flash[:notice] = "#{changes} Traduccions actualitzades correctament"
    rescue ArgumentError => e
      flash[:alert] = "Formato de archivo no valido"
    end

    redirect_to translations_url
  end
end
