#! /bin/bash

set -e
set -u

p=""
b=""
r=""
t=""
usage() {
 echo
 echo " Usage: "
 echo 
 echo " $0 -b <GCS Bucket> -p <local back ups path> [-r -t -h ]"
 echo
 echo "                 -b   GCS Bucket (gs://your_backup_bucket/path)               (required)"
 echo "                 -p   local server back up path ie /backups/                  (required)"
 echo "                 -r   remove local backups (clear /backups/ after move)       (optional)"
 echo "                 -t   print GCS troubleshooting tips                          (optional)"
 echo "                 -h   print usage menu                                        (optional)"
 echo
 echo " Pre-requisite: GCE Instance Service Account must have Write Scope on Google Cloud Storage API"
 echo " Note: By default, this script will only copy files to GCS bucket, retaining a local copy. To remove local copies, use -r"
 echo
 exit 1
}
troubleshooting() {
   echo "Troubleshooting Tips for GCS failures:"
   echo 
   echo "BucketNotFoundException: 404 gs://your_bucket/path bucket does not exist "
   echo "Error: GCS Bucket 'your_bucket' does not exist"
   
   echo 
   echo "AccessDeniedException: 403 user@yourdomain.com does not have storage.objects.list access to your_bucket."
   echo "Error: Access Denied on GCS Bucket. Either the GCE Instance Service Account does not have Write scope on storage API, "
   echo "or the bucket exists outside of your GCP Project."
   

   echo
   echo "CommandException: One or more URLs matched no objects."
   echo "Error: The GCS Bucket is good, the path does not exist. Please verify the /path/ in your GCS Bucket"
   exit
}

# Check for help flags
for arg in "$@"
do 
   case $arg in
       -h)
       usage
       shift
       ;;
       -t)
       troubleshooting
       shift
       ;;
       -r)
       r=1 
       shift
       ;;
    esac
done

# Check for input vars
while getopts ":b:p:" OPT; do
  case ${OPT} in
    b )
      b=$OPTARG
      ;;
    p )
      p=$OPTARG
      ;;
    : )
      echo 
      echo " Error: option -${OPTARG} requires an argument"
      ;;

   \? )
      echo 
      echo " Error: invalid option -${OPTARG}"
      usage
      ;;
  esac
done
shift $((OPTIND -1))


# Check for required input
if [ -z "${b}" ]; then
  echo 
  echo "GCS bucket required"
  usage
fi

if [ -z "${p}" ]; then
  echo 
  echo "Local backups path required"
  usage
fi

# Check back up path

if [[ ! -d $p ]]; then
   echo "local backup path $p does not exist"
   exit
elif [[ $p == "/" ]]; then
   echo "this is not the path you are looking for"
   exit
fi
echo " Local backup path looks good...."
# Check a gs:// was passed
if  [[ ${b} != *"gs://"* ]]; then
   echo
   echo "Error: -b <gcs bucket> must be in the format of gs://your_bucket/your_path"
   exit
fi

echo " Bucket format looks good...."
# Check for bucket/path
BUCKET_CHECK="$(gsutil ls -L ${b} )"
echo " Bucket permissions look good...."

if [ $r ]; then
 # Move backups 
 echo "Move and Remove"
 gsutil -m mv $p $b
 #rm -rf $p/* DANGER DANGER DANGER ****** Make sure you understand the implications before enabling this feature. Uncommenting this line means you assume full responsibility in the event of data loss. This line will forcefully remove the local back up path you have specified, whether it is what you intended or not. Use extreme caution!!!!
else 
 # Copy Backups 
 echo "Copy and retain"
 gsutil -m cp $p $b 
fi

echo "Complete"
