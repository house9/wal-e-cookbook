# ===========================================
# attributes for re-use across recipes
# highly unlikely you would override these values and if you do it will just break things
default["wal_e"]["d_env_path"] = "/etc/wal-e.d/env"
default["wal_e"]["exe"] = "envdir /etc/wal-e.d/env /usr/local/bin/wal-e"


# ===========================================
# common wal_e settings
default["wal_e"]["aws_access_key_id"] = nil
default["wal_e"]["aws_secret_access_key"] = nil
default["wal_e"]["wale_s3_prefix"] = "s3://your-lower-case-bucket-name/server-x/wal-e/"

# override this to install specific tag or git commit, otherwise HEAD from master will be installed
# see https://github.com/wal-e/wal-e/tags for stable builds
# NOTE: re-running the recipe will NOT update wal-e unless this value has changed since the previous run
default["wal_e"]["wale_git_install_reference"] = "HEAD"


# ===========================================
# recover recipe settings
default["wal_e"]["recover"]["recovery_target_timeline"] = "latest"
default["wal_e"]["recover"]["recovery_target_time"] = nil