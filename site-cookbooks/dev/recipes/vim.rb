package "vim"

template "/home/vagrant/.vimrc" do
  source "vim/vimrc"
  owner "vagrant"
  group "vagrant"
  mode "0644"
  action :create_if_missing
end