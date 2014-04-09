execute "/usr/local/bin/composer" do
  command "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer"
  creates "/usr/local/bin/composer"
  group "root"
  user  "root"
  not_if "which composer"
end