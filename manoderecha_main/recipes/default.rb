include_recipe "apt"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "php"
include_recipe "apache2::mod_php5"
include_recipe "build-essential"
include_recipe "mysql::server"
include_recipe "nodejs"
include_recipe "phantomjs"

# Install some packages
%w{cron php5-xsl}.each do
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
    sudo npm install -g less
    EOH
end

# Install phpmyadmin
cookbook_file "/tmp/phpmyadmin.deb.conf" do
  source "phpmyadmin.deb.conf"
end
bash "debconf_for_phpmyadmin" do
  code "debconf-set-selections /tmp/phpmyadmin.deb.conf"
end
package "phpmyadmin"


#--- Execute only first time if was successfull, after this comment it

# create all the databases from the Vagrantfile json config
node[:db].each do |env, name|
  execute "create database #{name}" do
    command "mysql -uroot -p#{node[:mysql][:server_root_password]} -e 'create database if not exists #{name}'"
    user "vagrant"
  end
end

#set memory_limit
bash "set memory_limit" do
  code "perl -pi -e 's[memory_limit = -1|memory_limit = 128M ][memory_limit = 512M]g' /etc/php5/*/php.ini"
end

# permit override url
bash "allow override" do
  code "perl -pi -e 's[AllowOverride None][AllowOverride All]g' /etc/apache2/sites-enabled/000-default"
  notifies :restart, resources("service[apache2]"), :immediately
end

# install manoderecha
bash "install manoderecha" do
  cwd "/var/www/manoderecha"
  code "php symfony propel:build-all --no-confirmation && php symfony cc"
end

# Enable default apache site
apache_site "default" do
  enable true
end
