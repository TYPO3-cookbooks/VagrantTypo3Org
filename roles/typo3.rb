name "typo3"
description "TYPO3 setup"

run_list(
  "recipe[mysql::server]",
  "recipe[application]"
=begin
  "recipe[typo3::source]",
  "recipe[typo3::introduction]",
  "recipe[typo3::web]"
=end
)

override_attributes({
=begin
  "typo3" => {
    "dir" => "/var/cache/typo3",
    "introduction" => {
      "dir" => "/var/cache/typo3_introduction"
    },
    "web" => {
      "server_name" => "introduction.typo3.dev",
      "server_aliases" => [],
      "owner" => "vagrant",
      "group" => "www-data"
    }
  },
=end
  "mysql" => {
    "server_debian_password" => "",
    "server_root_password" => "root",
    "bind_address" => "localhost"
  }
})
