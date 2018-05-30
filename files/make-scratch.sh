#!/bin/bash

echo "purging old mdraid devices..."
mdadm --stop /dev/md*; mdadm --remove /dev/md* 2>/dev/null

# determine suitable devices
DEVICES=()
for i in $(lsblk -o NAME| grep ^sd); do
  # check for the device in mtab
  grep $i /etc/mtab > /dev/null
  if [[ $? -eq 0 ]]; then
    echo "device $i in /etc/mtab. skipping..."
    continue
  fi

  # check the size of the device, bail if its smaller than 
  SIZE=$(blockdev --getsize64 /dev/$i)
  if [[ $SIZE -lt '10737418240' ]]; then
    echo "device $i is less than minimum 10GB. skipping..."
    continue
  fi
  # otherwise, add the disk
  DEVICES+=($i)
done

echo "wiping and creating RAID from following devices: $DEVICES ..."

for device in $DEVICES; do 
  echo "wiping device: $device ..."
  wipefs -a /dev/$device
done

# horrible shell array stuff be here.  thanks, mdraid!
/usr/sbin/mdadm --create --verbose /dev/md0 --level=stripe --raid-devices=${#DEVICES[@]} ${DEVICES[@]/#/\/dev\/} --force

echo "creating XFS filesystem on /dev/md0 ..." 
mkfs.xfs -f /dev/md0

mkdir -p "/run/slate/ephemeral"
mount /dev/md0 /run/slate/ephemeral
