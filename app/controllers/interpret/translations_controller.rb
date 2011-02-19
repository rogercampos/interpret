class Interpret::TranslationsController < Interpret::BaseController
  cache_sweeper eval(Interpret.sweeper.to_s.classify) if Interpret.sweeper
  cache_sweeper Interpret::TranslationSweeper
  before_filter :get_tree, :only => :index

  def index
    key = params[:key]
    t = Interpret::Translation.arel_table
    if key
      @translations = Interpret::Translation.locale(I18n.locale).where(t[:key].matches("#{key}.%"))
      @translations = @translations.select{|x| x.key =~ /#{key}\.\w+$/}
      if I18n.locale != I18n.default_locale
        @references = Interpret::Translation.locale(I18n.default_locale).where(t[:key].matches("#{key}.%"))
      end
    else
      @translations = Interpret::Translation.locale(I18n.locale).where(t[:key].does_not_match("%.%")).paginate :page => params[:page]
      if I18n.locale != I18n.default_locale
        @references = Interpret::Translation.locale(I18n.default_locale).where(t[:key].does_not_match("%.%")).paginate :page => params[:page]
      end
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

  def new
    @reference = Interpret::Translation.find(params[:translation_id])
    if @reference.locale === I18n.locale.to_s
      redirect_to interpret_root_path
      return
    end
    @translation = Interpret::Translation.new :locale => I18n.locale, :key => @reference.key
  end

  def create
    @reference = Interpret::Translation.find(params[:translation_id])
    if @reference.locale == I18n.locale.to_s
      redirect_to interpret_root_path
      return
    end
    @translation = Interpret::Translation.new params[:interpret_translation].merge(:locale => I18n.locale, :key => @reference.key)

    if @translation.save
      redirect_to interpret_root_path(:locale => I18n.locale), :notice => "New translation created"
    else
      render :action => :new
    end
  end

private
  def get_tree
    @tree = session[:tree] ||= Interpret::Translation.get_tree
  end

end
