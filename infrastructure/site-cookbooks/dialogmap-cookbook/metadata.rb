name             'dialogmap-cookbook'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures dialogmap-cookbook'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apt'
depends 'sudo'
depends 'user'
depends 'curl'
depends 'git'

depends 'database'
depends 'mysql'

depends 'rbenv'

depends 'nginx'

depends 'nodejs'

depends 'swap'
