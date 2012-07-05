name "base"
description "Base role applied to all nodes."

run_list(
#  "recipe[travis_build_environment]",
  "recipe[chef_handler]",
#  "recipe[minitest-handler]",
  "recipe[ohai]",
  "recipe[build-essential]",
  "recipe[git]",
  "recipe[rsync]"
)

override_attributes(
  'locales' => [
    "en_EN.UTF-8",
    "fr_CH.UTF-8",
    "de_CH.UTF-8",
    "de_DE.UTF-8"
  ]
)
