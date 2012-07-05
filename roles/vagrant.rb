name "vagrant"
description "Role for our virtual development environments. Adds more sensitive settings for improving development. These nodes have typically a more open security guideline to allow access for developers."

override_attributes(
   "mysql" => {
     "tunable" => {
       "key_buffer" => "32M",
       "innodb_buffer_pool_size" => "128M"
     }
   },
   "apache" => {
     "prefork" => {
       "startservers"    => 2,
       "minspareservers" => 2,
       "maxspareservers" => 5
     }
   }
)
