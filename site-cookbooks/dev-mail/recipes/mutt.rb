# install Mutt, a console email reader
package "mutt"

template "/etc/Muttrc.d/maildir.rc" do
  action :create_if_missing
  source "mutt-maildir.rc"
  owner "root"
  group "root"
  mode "0644"
end