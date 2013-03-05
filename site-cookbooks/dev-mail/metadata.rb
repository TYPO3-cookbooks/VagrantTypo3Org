maintainer       "Christian Zenker"
maintainer_email "christian.zenker@599media.de"
license          "WTFPL v2"
description      "Installs/Configures a mail server for dev environments that does not send out any mails into the web"
long_description ""
version          "1.0.0"

recipe "exim", "Installs the MTA"
recipe "mutt", "Installs a mail reader for the console"
