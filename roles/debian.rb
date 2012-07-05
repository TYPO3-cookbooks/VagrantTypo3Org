name "debian"
description "Role applied to all Debian systems."

run_list(
  "recipe[apt]"
)
