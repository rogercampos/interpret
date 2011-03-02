class MySweeper < Interpret::ExpirationObserver
  def expire_cache
    puts "Custom app expiration logic"
  end
end
