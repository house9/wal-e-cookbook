name             'wal-e-cookbook'
maintainer       'Jesse House'
maintainer_email 'mail@jessehouse.com'
license          'The MIT License (MIT)'
description      'Enable postgresql WAL archiving to S3 with wal-e'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'

supports "ubuntu"
supports "debian"

depends "postgresql"
depends "python"
depends "git"