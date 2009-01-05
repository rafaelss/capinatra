require 'erb'

Capistrano::Configuration.instance(:must_exist).load do
  after "deploy:update_code", "capinatra:config"
  
  namespace :capinatra do
    desc "Sets up apache vhost"
    task :vhost do
      if exists? :apache_vhost_dir
        logger.info 'compiling vhost template'
        template = File.read(File.join(File.dirname(__FILE__), '..', 'templates', 'vhost.conf.erb'))

        logger.info 'uploading vhost file'
        put ERB.new(template).result(binding), "#{application}.conf"

        logger.info 'moving vhost file to ' + apache_vhost_dir
        send fetch(:run_method), "mv #{application}.conf #{apache_vhost_dir}"

        logger.info 'restarting apache'
        send fetch(:run_method), "sudo apache2ctl graceful"
      end
    end

    desc "Adds config.ru file"
    task :config do
      logger.info 'compiling config.ru template'
      template = File.read(File.join(File.dirname(__FILE__), '..', 'templates', 'config.ru.erb'))

      logger.info 'uploading config.ru file'
      put ERB.new(template).result(binding), "config.ru"

      if exists? :apache_vhost_dir
        logger.info 'moving vhost file to ' + apache_vhost_dir
        send fetch(:run_method), "mv config.ru #{release_path}"
      end
    end
  end
end
