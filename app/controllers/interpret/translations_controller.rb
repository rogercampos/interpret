module Interpret
  class TranslationsController < Interpret::BaseController
    before_filter :get_tree, :only => :index
    authorize_resource :class => "Interpret::Translation"

    def welcome
      redirect_to root_url
    end

    def index
      key = params[:key]
      t = Interpret::Translation.arel_table
      if key
        @translations = Interpret::Translation.allowed.locale(I18n.locale).where(t[:key].matches("#{CGI.escape(key)}.%")).order("translations.key ASC")
        if I18n.locale != I18n.default_locale
          @references = Interpret::Translation.allowed.locale(I18n.default_locale).where(t[:key].matches("#{CGI.escape(key)}.%")).order("translations.key ASC")
        end
      else
        @translations = Interpret::Translation.allowed.locale(I18n.locale).where(t[:key].does_not_match("%.%")).order("translations.key ASC")
        if I18n.locale != I18n.default_locale
          @references = Interpret::Translation.allowed.locale(I18n.default_locale).where(t[:key].does_not_match("%.%")).order("translations.key ASC")
        end
      end

      # not show translations inside nested folders, \w avoids dots
      @translations = @translations.select{|x| x.key =~ /#{key}\.\w+$/} if key
      @references = @references.select{|x| x.key =~ /#{key}\.\w+$/} if key && @references

      @total_keys_number = Interpret::Translation.locale(I18n.locale).count
    end

    def edit
      @translation = Interpret::Translation.find(params[:id])
    end

    def update
      @translation = Interpret::Translation.find(params[:id])
      old_value = @translation.value

      respond_to do |format|
        if @translation.update_attributes(params[:translation].presence || params[:interpret_translation])
          msg = ""
          msg << "By [#{current_interpret_user}]. " if current_interpret_user
          msg << "Locale: [#{@translation.locale}], key: [#{@translation.key}]. The translation has been changed from [#{old_value}] to [#{@translation.value}]"
          Interpret.logger.info msg

          format.html { redirect_to :back }
          format.xml  { head :ok }
          format.json { head :ok }
        else
          format.html { redirect_to :back }
          format.xml  { render :xml => @translation.errors, :status => :unprocessable_entity }
          format.json { render :status => :unprocessable_entity }
        end
      end
    end

    def create
      @translation = Interpret::Translation.new params[:translation]

      if @translation.save
        flash[:notice] = "New translation created for #{@translation.key}"
        redirect_to :back
      else
        flash[:alert] = "Error when creating a new translation"
        redirect_to :back
      end
    end

    def destroy
      @translation = Interpret::Translation.find(params[:id])

      @translation.destroy
      flash[:notice] = "Translation #{@translation.key} destroyed."
      redirect_to :back
    end

  private
    def get_tree
      @tree ||= Interpret::Translation.get_tree
    end
  end
end
