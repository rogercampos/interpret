class Interpret::TranslationsController < Interpret::BaseController
  before_filter :get_tree, :only => :index

  def index
    key = params[:key]
    t = Interpret::Translation.arel_table
    if key
      @translations = Interpret::Translation.locale(I18n.locale).where(t[:key].matches("#{CGI.escape(key)}.%"))
      if I18n.locale != I18n.default_locale
        @references = Interpret::Translation.locale(I18n.default_locale).where(t[:key].matches("#{CGI.escape(key)}.%"))
      end
    else
      @translations = Interpret::Translation.locale(I18n.locale).where(t[:key].does_not_match("%.%"))
      if I18n.locale != I18n.default_locale
        @references = Interpret::Translation.locale(I18n.default_locale).where(t[:key].does_not_match("%.%"))
      end
    end
    if @interpret_user
      @translations = @translations.where(:protected => false) if !@interpret_admin
      @references = @references.where(:protected => false) if @references && !@interpret_admin
    end

    # not show translations inside nested folders, \w avoids dots
    @translations = @translations.select{|x| x.key =~ /#{key}\.\w+$/} if key
    @references = @references.select{|x| x.key =~ /#{key}\.\w+$/} if key && @references
  end

  def edit
    @translation = Interpret::Translation.find(params[:id])
  end

  def update
    if @interpret_user && !@interpret_admin && params[:interpret_translation].has_key?(:protected)
      head :error
      return
    end
    @translation = Interpret::Translation.find(params[:id])
    old_value = @translation.value

    respond_to do |format|
      if @translation.update_attributes(params[:interpret_translation])
        msg = ""
        msg << "By [#{@interpret_user}]. " if @interpret_user
        msg << "Locale: [#{@translation.locale}], key: [#{@translation.key}]. The translation has been changed from [#{old_value}] to [#{@translation.value}]"
        Interpret.logger.info msg

        format.html { redirect_to(request.env["HTTP_REFERER"]) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { redirect_to(request.env["HTTP_REFERER"]) }
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

  def live_edit
    blobs = params[:key].split(".")
    locale = blobs.first
    key = blobs[1..-1].join(".")
    @translation = Interpret::Translation.locale(locale).find_by_key(key)

    respond_to do |format|
      if @translation
        format.js
      else
        head :ok
      end
    end
  end

private
  def get_tree
    @tree ||= Interpret::Translation.get_tree
  end

end
