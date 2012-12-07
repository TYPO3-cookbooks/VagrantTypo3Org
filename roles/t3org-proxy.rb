name "t3org-proxy"
description "typo3.org proxy"

run_list(
  "role[varnish]"
)

override_attributes(
  "varnish" => {
  	"version" => "2.1",
  	"vcl_cookbook" => "t3org-varnish",
  	"listen_port" => 80,
  	"backend_host" => "192.168.156.122",
  	"backend_port" => 80
  }
)