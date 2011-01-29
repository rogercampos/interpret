class Interpret::TranslationsController < eval(Interpret.controller.classify)
  layout 'interpret'
  cache_sweeper eval(Interpret.sweeper.to_s.classify) if Interpret.sweeper
  cache_sweeper Interpret::TranslationSweeper

  def index
    t = Interpret::Translation.arel_table
    @translations = Interpret::Translation.locale(I18n.default_locale).where(t[:key].does_not_match("%.%")).paginate :page => params[:page]
  end

  def node
    key = params[:key]
    unless key
      redirect_to translations_url
      return
    end

    t = Interpret::Translation.arel_table
    @originals = Interpret::Translation.locale(I18n.default_locale).where(t[:key].matches("#{key}.%")).paginate :page => params[:page]
    @translations = Interpret::Translation.locale(I18n.locale).where(t[:key].matches("#{key}.%")).paginate :page => params[:page]
    render :action => :index
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


  caches_action :tree
  def tree
    get_sidebar_tree
    render :layout => false
  end


private
  def get_sidebar_tree
    t = Interpret::Translation.arel_table
    all_trans = Interpret::Translation.locale(I18n.locale).select(t[:key]).where(t[:key].matches("%.%")).all


    @tree = LazyHash.build_hash
    all_trans = all_trans.map{|x| x.key.split(".")[0..-2].join(".")}.uniq
    all_trans.each do |x|
      LazyHash.lazy_add(@tree, x, {})
    end
  end
end
