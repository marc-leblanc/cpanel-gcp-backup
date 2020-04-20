# cPanel to GCS Backup script

This script is really only meant to be a stopgap and not intended for long term use. cPanel includes functionality for backups to be copied to a GCS bucket, however in use it has been observed that it errors frequently and does not create a complete copy of all accounts. This has been filed as a bug with no progress for quite some time. As a work around I have created this script

Since I wrote this specific to my needs, there are some limitations

1) Your Server must be a hosted GCE Instance
2) Your Server must be given Write access to Google Cloud Storage API
3) The GCS Bucket and path you specify must pre-exist before running the script

## Usage:

`gcp_backup.sh [-r] [-t] [-h] <-b gs://bucket/path> <-p /local_backup_path>`

| Flag | Description | Required |
| --- | --- | --- |
| -r  | Remove local server backups. This will invoke a gsutil mv, which will move the files, but leave the directory structure. If not specified, local copies will be retained. | No |
| -t | Print GCS Troubleshooting tips | No |
| -h | Print Usage menu | No |
| -b | GCS Storage bucket and path. Must be in gs://bucket_name/path format | Yes | 
| -p | Local backup path on your server ie /backups/ | Yes| 

