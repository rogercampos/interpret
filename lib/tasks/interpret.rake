namespace :interpret do
  desc 'Copy all the translations from config/locales/*.yml into DB backend'
  task :dump => :environment do
    Interpret::Translation.dump
    eval(Interpret.sweeper.classify).instance.send(:run_expiration) if Interpret.sweeper
  end

  desc 'Synchronize the keys used in db backend with the ones on *.yml files'
  task :update => :environment do
    Interpret::Translation.update
    eval(Interpret.sweeper.classify).instance.send(:run_expiration) if Interpret.sweeper
  end
end
