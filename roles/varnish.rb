name "varnish"
description "varnish for typo3.org"

run_list(
  "recipe[varnish::apt_repo]",
  "recipe[varnish]"
)
