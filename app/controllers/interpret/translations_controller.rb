class Interpret::TranslationsController < eval("#{Interpret.controller.classify}Controller")
  layout 'interpret'

  def index
    @originals = Interpret::Translation.locale(I18n.default_locale).where("key NOT LIKE '%.%'").paginate :page => params[:page]
    #unless I18n.locale == I18n.default_locale
      @translations = Interpret::Translation.locale(I18n.locale).where("key NOT LIKE '%.%'").paginate :page => params[:page]
    #else
      #@translations = nil
    #end
  end

  def node
    key = params[:key]
    unless key
      redirect_to translations_url
      return
    end

    @originals = Interpret::Translation.locale(I18n.default_locale).where("key LIKE '#{key}.%'").paginate :page => params[:page]
    #unless I18n.locale == I18n.default_locale
      @translations = Interpret::Translation.locale(I18n.locale).where("key LIKE '#{key}.%'").paginate :page => params[:page]
    #else
      #@translations = nil
    #end
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
        Interpret.backend.reload! if Interpret.backend
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
  cache_sweeper Interpret::TranslationSweeper
  def tree
    get_sidebar_tree
    render :layout => false
  end


private
  def get_sidebar_tree
    all_trans = Interpret::Translation.locale(I18n.locale).select(:key).where("key LIKE '%.%'").all


    @tree = LazyHash.build_hash
    all_trans = all_trans.map{|x| x.key.split(".")[0..-2].join(".")}.uniq
    all_trans.each do |x|
      LazyHash.lazy_add(@tree, x, {})
    end
  end
end
