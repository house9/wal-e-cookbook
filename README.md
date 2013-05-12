wal-e-cookbook
=======================
chef cookbook for installing wal-e (postgres continuous archiving to s3)

* [https://github.com/wal-e/wal-e](https://github.com/wal-e/wal-e)
* [http://www.postgresql.org/docs/9.1/static/continuous-archiving.html](http://www.postgresql.org/docs/9.1/static/continuous-archiving.html)
* This recipe automates many of the steps from this excellent article: [http://blog.opbeat.com/2013/01/07/postgresql-backup-to-s3-part-one/](http://blog.opbeat.com/2013/01/07/postgresql-backup-to-s3-part-one/)

See sample usage: [here](https://github.com/house9/use_wal_e)

Requirements
------------
This cookbook has been developed and tested on ubuntu servers only

#### packages
- `postgresql` - optionally use [databox-cookbook](https://github.com/teohm/databox-cookbook) which includes postgresql
- `python` - wal-e is installed using python pip (package management system)
- `git` - required to install wal-e using pip over git 

Attributes
----------

#### wal_e::default
- `['wal_e']['aws_access_key_id']` : AWS Access Key
- `['wal_e']['aws_secret_access_key']` : AWS Secret
- `['wal_e']['wale_s3_prefix']` : S3 url for the bucket where postgres WAL and backups will be stored
  - i.e. s3://your-lower-case-bucket-name/whatever/wal-e/

Usage
-----
#### wal_e::default

Include `wal_e` in your node's `run_list`:

```
{
  "name":"my_node",
  "run_list": [
    "recipe[wal_e]"
  ]
}
```

and specify all 3 of the S3 attributes needed by wal-e

```
"wal_e": {
  "aws_secret_access_key": "SECRET",
  "aws_access_key_id": "ACCESS_KEY",
  "wale_s3_prefix": "s3://your-lower-case-bucket-name/wal-e/or_whatever"
}

```


TODO List
------------
* add configuration option to bring up a standby server or new server in recovery mode
* move attributes to encrypted data bag
* allow configuration of cron settings

Contributing
------------
- Fork the repository on Github
- Create a named feature branch (like `add_component_x`)
- Write your changes
- Submit a Pull Request using Github

License
-------------------
wal-e cookbook is released under the [MIT License](http://www.opensource.org/licenses/MIT).

See the [LICENSE](./LICENSE) file
