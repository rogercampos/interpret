class Interpret::TranslationsController < eval(Interpret.controller.classify)
  layout 'interpret'
  cache_sweeper eval(Interpret.sweeper.to_s.classify) if Interpret.sweeper
  cache_sweeper Interpret::TranslationSweeper
  before_filter :get_tree, :only => :index

  def index
    key = params[:key]
    t = Interpret::Translation.arel_table
    if key
      @translations = Interpret::Translation.locale(I18n.default_locale).where(t[:key].matches("#{key}.%"))
      @translations.select!{|x| x.key =~ /#{key}\.\w+$/}

    else
      @translations = Interpret::Translation.locale(I18n.default_locale).where(t[:key].does_not_match("%.%")).paginate :page => params[:page]
    end
  end

  def edit
    @translation = Interpret::Translation.find(params[:id])
  end

  def update
    @translation = Interpret::Translation.find(params[:id])
    old_value = @translation.value

    respond_to do |format|
      if @translation.update_attributes(params[:interpret_translation])
        msg = respond_to?(:current_user) ? "By [#{current_user}]. " : ""
        msg << "Locale: [#{@translation.locale}], key: [#{@translation.key}]. The translation has been changed from [#{old_value}] to [#{@translation.value}]"
        Interpret.logger.info msg

        format.html { redirect_to(translations_url)}
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @translation.errors, :status => :unprocessable_entity }
        format.json { render :status => :unprocessable_entity }
      end
    end
  end

private
  def get_tree
    session.delete(:tree)
    @tree = session[:tree] ||= Interpret::Translation.get_tree
  end

end
