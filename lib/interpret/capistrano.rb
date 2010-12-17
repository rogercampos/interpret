namespace :interpret do
  desc "Update translations keys in database"
  task :update, :roles => :app, :except => { :no_release => true } do
    commands = [
      "RAILS_ENV=#{rails_env} rake interpret:update",
    ]

    run <<-CMD
      cd #{release_path} &&
      #{commands.join(" && ")}
    CMD
  end
end

after "deploy:update_code", "interpret:update"
