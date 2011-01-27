class Interpret::ToolsController < eval("#{Interpret.controller.classify}Controller")
  layout 'interpret'

  def migrate
    Interpret::Translation.import

    redirect_to interpret_tools_url, :notice => "Migracio realitzada"
  end

  def fetch
    require 'ya2yaml'

    translations = Interpret::Translation.locale(I18n.locale).all
    hash = Interpret::Translation.as_hash(translations)
    text = hash.ya2yaml

    send_data text[5..text.length], :filename => "#{I18n.locale}.yml"
  end

  def upload
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

      changes = Interpret::Translation.update_from_hash(I18n.locale, hash.values[0])
      Interpret.backend.reload! if Interpret.backend

      flash[:notice] = "#{changes} Traduccions actualitzades correctament"
    rescue ArgumentError => e
      flash[:alert] = "Formato de archivo no valido"
    end

    redirect_to translations_url
  end
end

