#!/usr/bin/env bash
INSTANCE_ID=$(curl 169.254.169.254/1.0/meta-data/instance-id)
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
CWPUT_NAMESPACE=${CWPUT_NAMESPACE:-"System/Linux"}
CWPUT_CONFIG_DIR=${CWPUT_CONFIG_DIR:-"/etc/cwput/checks"}
CWPUT_GROUP=${CWPUT_GROUP:-"$INSTANCE_ID"}
CWPUT_DIM_ID=${CWPUT_DIM_ID:-"[ {\"Name\": \"InstanceId\", \"Value\": \"$INSTANCE_ID\"} ]"}
CWPUT_DIM_GROUP=${CWPUT_DIM_GROUP:-"[ {\"Name\": \"AutoScalingGroupName\", \"Value\": \"$CWPUT_GROUP\"} ]"}

if [ -z $INSTANCE_ID ]; then
    echo "InstanceID could not be determined"
    exit 1
fi

if [ -z $EC2_REGION ]; then
    echo "Region could not be determined"
    exit 1
fi

metrics=

for file in $( ls $CWPUT_CONFIG_DIR );
do
    data=$($CWPUT_CONFIG_DIR/$file)
    # A check may echo multiple lines, one per metric
    for line in $data; do
        if [ -n "$metrics" ]; then
            metrics="$metrics,"
        fi
        metric_name=${line%%;*}
        metric_name_and_unit=${line%;*}
        unit=${metric_name_and_unit##*;}
        value=${line##*;}
        # Submit value for instance and for autoscaling group
        part="{\"MetricName\": \"$metric_name\", \"Dimensions\": $CWPUT_DIM_ID, \"Value\": $value, \"Unit\": \"$unit\"}, \
              {\"MetricName\": \"$metric_name\", \"Dimensions\": $CWPUT_DIM_GROUP, \"Value\": $value, \"Unit\": \"$unit\"}"

        metrics="$metrics$part"
    done
done

# Jitter around API call to avoid rate limiting when running lots of EC2s
sleep $[ ( $RANDOM % 8 )  + 1 ]

aws cloudwatch put-metric-data \
--region $EC2_REGION \
--namespace $CWPUT_NAMESPACE \
--metric-data "[ $metrics ]"
