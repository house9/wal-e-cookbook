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

#### wal_e::master
- `['wal_e']['aws_access_key_id']` : AWS Access Key
- `['wal_e']['aws_secret_access_key']` : AWS Secret
- `['wal_e']['wale_s3_prefix']` : S3 url for the bucket where postgres WAL and backups will be stored
  - i.e. s3://your-lower-case-bucket-name/whatever/wal-e/

#### wal_e::recover
- `['wal_e']['aws_access_key_id']` : AWS Access Key
- `['wal_e']['aws_secret_access_key']` : AWS Secret
- `['wal_e']['wale_s3_prefix']` : S3 url for the bucket where postgres WAL and backups will be stored
  - i.e. s3://your-lower-case-bucket-name/whatever/wal-e/
- `['wal_e']['recover']` : add recover options if desired
- `['wal_e']['recover']['recovery_target_timeline']` : default is 'latest'
  - see [http://www.postgresql.org/docs/9.1/static/recovery-target-settings.html#RECOVERY-TARGET-TIMELINE](http://www.postgresql.org/docs/9.1/static/recovery-target-settings.html#RECOVERY-TARGET-TIMELINE)
- `['wal_e']['recover']['recovery_target_time']` : default is nil
  - see [http://www.postgresql.org/docs/9.1/static/recovery-target-settings.html#RECOVERY-TARGET-TIME](http://www.postgresql.org/docs/9.1/static/recovery-target-settings.html#RECOVERY-TARGET-TIME)


Usage
-----
#### wal_e::master

Include `wal_e` in your node's `run_list`:

```
{
  "name":"my_node",
  "run_list": [
    "recipe[wal_e::master]"
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

#### wal_e::recover

Include `wal_e` in your node's `run_list`:

```
{
  "name":"my_node",
  "run_list": [
    "recipe[wal_e::recover]"
  ]
}
```

and specify all 3 of the S3 attributes needed by wal-e

optionally add the recover options

```
"wal_e": {
  "aws_secret_access_key": "SECRET",
  "aws_access_key_id": "ACCESS_KEY",
  "wale_s3_prefix": "s3://your-lower-case-bucket-name/wal-e/or_whatever",
  "recover": {
    "recovery_target_timeline": "latest",
    "recovery_target_time": null
  }
}

```

Bringing a 'Recover' server online
------------
WARNING: the recover recipe will delete all of the pg data directory before pulling WAL-e files from S3, you may want to recover to a new server instead of running recover on your master

* take the master offline
  * ensure that it will no longer write to S3 with WAL-e
* run the recover recipe to bring up a new server in recovery mode
* once the chef script has completed, you will want to manually verify the server is up and has recovered all data
  * ssh onto box and tail postgres log
    * `sudo su - postgres`
    * `tail -f /var/log/postgresql/postgresql-9.1-main.log`
  * once server is online verify data is present
    * `psql -c "\l"`
    * `psql app1 -c "select * from sample_data_1;"`
* Once you have verified the server is up and running and all data is present you will want to 'promote' this server to be the new master
  * change your chef configuration for this node
  * provision it
  * and then verify that it is now writing WAL files to S3


WAL-e Cookbook TODO List
------------
* make installed wal_e version configurable, currently pulls HEAD from master
* add recipe for standby server
* move attributes to encrypted data bag
* allow configuration of cron settings for backup creation

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


Random Notes
-------------------
```
psql -c "show data_directory"
# /var/lib/postgresql/9.1/main

psql -c "show config_file"
# /etc/postgresql/9.1/main/postgresql.conf

/var/log/postgresql/postgresql-9.1-main.log 
```
