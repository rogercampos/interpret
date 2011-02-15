Capistrano::Configuration.instance(:must_exist).load do
  namespace :interpret do
    def rails_env
      fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
    end

    def roles
      fetch(:delayed_job_server_role, :app)
    end

    desc "Update translations keys in database"
    task :update, :roles => lambda {roles} do
      run "cd #{current_path};#{rails_env} rake interpret:update"
    end
  end

  after "deploy:update_code", "interpret:update"
end
