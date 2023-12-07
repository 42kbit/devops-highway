#!/bin/bash

SNAPSHOT_IDS=$(aws ec2 describe-snapshots --owner self --filters "Name=description,Values=Created by CreateImage* ${AMI_ID}" --query "Snapshots[*].SnapshotId" --output text)

for SNAPSHOT_ID in $SNAPSHOT_IDS; do
    echo "Deleting snapshot $SNAPSHOT_ID"
    aws ec2 delete-snapshot --snapshot-id "$SNAPSHOT_ID"
done
