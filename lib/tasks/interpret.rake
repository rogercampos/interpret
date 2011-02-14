namespace :interpret do
  desc 'Copy all the translations from config/locales/*.yml into DB backend'
  task :migrate => [:environment, "tmp:cache:clear"] do
    Interpret::Translation.dump
  end

  desc 'Synchronize the keys used in db backend with the ones on *.yml files'
  task :update => [:environment, "tmp:cache:clear"] do
    Interpret::Translation.update
  end
end
