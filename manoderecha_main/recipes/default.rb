include_recipe "apt"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "php"
include_recipe "apache2::mod_php5"
include_recipe "build-essential"
include_recipe "mysql::server"
include_recipe "nodejs"

# Install packages
%w{build-essential cron php5-xsl}.each do
|pkg|
  package pkg do
    action :install
  end
end

#Install pear libraries
sc = php_pear_channel "pear.symfony-project.com" do
  action :discover
end
php_pear "symfony" do
  version "1.2.12"
  channel sc.channel_name
  action :install
end
php_pear "Structures_Graph" do
	action :install
end

# Install node packages
bash "Install node packages" do
    code <<-EOH
    sudo npm install karma
    EOH
end



#----- Configuration for manoderecha installation

# # Enable default apache site
# apache_site "default" do
#   enable true
# end

# # Create simbolic link to md
# bash "Create simbolic link to md" do
#     code <<-EOH
#     sudo ln -fs /home/vagrant/manoderecha /var/www/manoderecha
#     EOH
# end

# # create all the databases from the Vagrantfile json config
# node[:db].each do |env, name|
# 	execute "create database #{name}" do
# 		command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e 'create database if not exists #{name}'"
# 		user "vagrant"
# 	end
# end

# #set memory_limit
# bash "set memory_limit" do
#   code "sudo perl -pi -e 's[memory_limit = -1|memory_limit = 128M ][memory_limit = 512M]g' /etc/php5/*/php.ini"
# end

# # permit override url
# bash "allow override" do
#   code "sudo perl -pi -e 's[AllowOverride None][AllowOverride All]g' /etc/apache2/sites-enabled/000-default"
#   notifies :restart, resources("service[apache2]"), :delayed
# end

# # install manoderecha
# bash "install manoderecha" do
#   code "cd /home/vagrant/manoderecha && php symfony propel:build-all --no-confirmation && php symfony cc"
# end
