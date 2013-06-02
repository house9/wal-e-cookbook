default["wal_e"]["aws_access_key_id"] = nil
default["wal_e"]["aws_secret_access_key"] = nil
default["wal_e"]["wale_s3_prefix"] = "s3://your-lower-case-bucket-name/server-x/wal-e/"

# attributes for re-use across recipes, highly unlikely you would override these values
default["wal_e"]["d_env_path"] = "/etc/wal-e.d/env"
default["wal_e"]["exe"] = "envdir /etc/wal-e.d/env /usr/local/bin/wal-e"

default["wal_e"]["recover"]["recovery_target_timeline"] = "latest"
default["wal_e"]["recover"]["recovery_target_time"] = nil