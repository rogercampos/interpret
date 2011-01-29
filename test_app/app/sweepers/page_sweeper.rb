class PageSweeper < Interpret::BaseSweeper
  def expire_cache(translation)
    # Because we inherit from a base_sweeper which is inside Interpret
    # namespace, we have to specify "/pages" as controller, otherwise Rails
    # will try to find the inexistent controller "interpret/pages"
    #
    # You can also use the 'translation' object passed as an argument to do a
    # smarter expiration logic. For instance, maybe you want to check translation.key
    # to find out which action inside which controller expire.
    expire_page :controller => "/pages", :action => "index"
  end
end
