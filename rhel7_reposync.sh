#!/bin/bash
#set -x

export repo_dir="/repo1"
export todate=`date +%Y%m%d`
export totime=`date +%Y%m%d-%H%M%S`
export repofile="/repo1/logs/reposync7.log.$totime"
export tmppath="/root/bin/temp"
export fpath="/repo1/rhel7.repo"

### yum file check
if [ -f /var/run/yum.pid ]; then
echo "Start Fail.. YUM Run File Found : $repofile " >> $repofile
echo "Time : $totime " >> $repofile
exit 11
fi

### repofile check
if [ -f $repofile ]; then
echo "Found File : $repofile " >> $repofile
else
touch $repofile
fi

echo "Start Time : $totime " >> $repofile

### repo file Create
echo "#### Local Repository ####" > $fpath
echo "#Create by : $(date +%Y%m%d-%H%M)" >> $fpath
echo "" >> $fpath
echo "" >> $fpath



echo "-------------------------------------Start-------------------------------------------" >> $repofile
for repos in $(cat /root/reposync/rhel7_channel.txt)
do
echo "-------------------------------------$repos-------------------------------------------" >> $repofile
### reposync

if [ -d /repo1/$repos ]
then
	/usr/bin/reposync --gpgcheck -l --newest-only --downloadcomps --download-metadata -r $repos --download_path=$repo_dir >> $repofile 2>&1
	echo "" >> $repofile
	#createrepo $repo_dir/$repos >> $repofile 2>&1
else
	/usr/bin/reposync --gpgcheck -l --downloadcomps --download-metadata -r $repos --download_path=$repo_dir >> $repofile 2>&1
	echo "" >> $repofile
	
fi

### repo file Create
  echo "[$repos]" >> $fpath
  echo "name=$repos" >> $fpath
  echo "baseurl=http://$sip/$repos" >> $fpath
  echo "enable=1" >> $fpath
  echo "gpgcheck=0" >> $fpath
  echo "" >> $fpath
  echo "" >> $fpath

done

echo "----------------------------------------END------------------------------------------" >> $repofile

exit;
