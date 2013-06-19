maintainer       "Arthur Gautier"
maintainer_email "superbaloo@gmail.com"
license          "MIT"
description      "Installs/Configures shinken"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "2.0.0"

depends "apt"
depends "nginx"
depends "mongodb", ">= 0.12"
depends "python"
depends "yum"
