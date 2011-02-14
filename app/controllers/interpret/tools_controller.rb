class Interpret::ToolsController < Interpret::BaseController

  def dump
    Interpret::Translation.dump

    session.delete(:tree)
    Interpret.backend.reload! if Interpret.backend
    redirect_to interpret_tools_url, :notice => "Dump done."
  end

  def export
    require 'ya2yaml'

    translations = Interpret::Translation.locale(I18n.locale).all
    hash = Interpret::Translation.export(translations)
    text = hash.ya2yaml

    send_data text[5..text.length], :filename => "#{I18n.locale}.yml"
  end

  def import
    unless params.has_key? :file
      redirect_to interpret_tools_url, :alert => "You have to select a file to import."
      return
    end

    begin
      Interpret::Translation.import(params[:file])
    rescue Exception => e
      redirect_to interpret_tools_url, :alert => e
    end

    session.delete(:tree)
    Interpret.backend.reload! if Interpret.backend

    redirect_to interpret_tools_url, :notice => "Import successfully done."
  end
end

