class Interpret::TranslationsController < Interpret::BaseController
  before_filter :get_tree, :only => :index

  def index
    key = params[:key]
    t = Interpret::Translation.arel_table
    if key
      @translations = Interpret::Translation.locale(I18n.locale).where(t[:key].matches("#{CGI.escape(key)}.%")).order("translations.key ASC")
      if I18n.locale != I18n.default_locale
        @references = Interpret::Translation.locale(I18n.default_locale).where(t[:key].matches("#{CGI.escape(key)}.%")).order("translations.key ASC")
      end
    else
      @translations = Interpret::Translation.locale(I18n.locale).where(t[:key].does_not_match("%.%")).order("translations.key ASC")
      if I18n.locale != I18n.default_locale
        @references = Interpret::Translation.locale(I18n.default_locale).where(t[:key].does_not_match("%.%")).order("translations.key ASC")
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

  def create
    @translation = Interpret::Translation.new params[:interpret_translation]

    if @translation.save
      flash[:notice] = "New translation created for #{@translation.key}"
      redirect_to request.env["HTTP_REFERER"]
    else
      flash[:alert] = "Error when creating a new translation"
      redirect_to request.env["HTTP_REFERER"]
    end
  end

  def destroy
    @translation = Interpret::Translation.find(params[:id])

    @translation.destroy
    redirect_to request.env["HTTP_REFERER"]
  end

  def live_edit
    blobs = params[:key].split(".")
    locale = blobs.first
    key = blobs[1..-1].join(".")
    @translation = Interpret::Translation.locale(locale).find_by_key(key)

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

private
  def get_tree
    @tree ||= Interpret::Translation.get_tree
  end

end
