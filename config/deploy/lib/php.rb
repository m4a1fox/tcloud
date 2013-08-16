Capistrano::Configuration.instance.load do
  ###### PHP OVERRIDES
  namespace :deploy do

    task :finalize_update do
      transaction do
        run "chmod -R g+w #{releases_path}/#{release_name}"
      end
    end

    task :migrate do
      # do nothing
    end

    task :restart do
      puts "Drupal cache clean"
      run "cd #{current_release}; sudo /usr/bin/drush cc all"
    end

    task :custom_symlinks do
      run "ln -s #{deploy_to}/shared/config/settings.php #{current_release}/sites/default/settings.php"

      run "rm -f #{current_release}/sites/all/modules/custom/amazon_api_interface/bakend.log"
      run "ln -s  #{deploy_to}/shared/log/bakend.log  #{current_release}/sites/all/modules/custom/amazon_api_interface/bakend.log"
      run "ln -s #{deploy_to}/shared/log/api_backend.log #{current_release}/sites/all/modules/custom/api_backend/api_backend.log"

      run "rm -rf #{current_release}/sites/default/files"
      run "ln -s #{deploy_to}/shared/uploads/files #{current_release}/sites/default/files"
    end
  end

  namespace :db do
	task :deploy do
		puts "Uploading database"
      		run "gunzip -c #{current_release}/dbases/stable/*mysql.gz | mysql -uroot tcloud_drupal"

      		puts "Drupal cache clean"
      		run "cd #{current_release}; sudo /usr/bin/drush cc all"
	end

	task :set_token do
                puts "Setting up token"
                run "token=$(echo 'select token from applications;' | mysql -uroot track_storage | grep -v '^token$');
                        grep -v 'backend_user_token' #{deploy_to}/shared/config/settings.php > /tmp/settings.php;
                        mv /tmp/settings.php #{deploy_to}/shared/config/settings.php;
                        echo >> #{deploy_to}/shared/config/settings.php;
                        echo \"\\$conf['backend_user_token'] = '$token';\" >> #{deploy_to}/shared/config/settings.php;
                        "
        end
  end

  namespace :resque do
    task :restart, :roles => :app, :except => { :no_release => true } do
      # do nothing
    end
  end

  namespace :bundle do
    task :install do
      # do nothing
    end
  end
  ###### PHP OVERRIDES
end
