#!/usr/bin/env bash
yum install -y vim
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp $dir/bin/cwput.bash /usr/bin/cwput
cp $dir/etc/cwput.conf /etc/init
mkdir /etc/cwput
mkdir $dir/etc/checks
cp -r $dir/etc/checks /etc/cwput
#cwput

ports=$(cat Service_List|grep PORTS|awk -F '=' '{print$2}'|sed 's/,/ /g')
apps=$(cat Service_List|grep SERVICE|awk -F '=' '{print$2}'|sed 's/,/ /g')
url=$(cat Service_List|grep URL|awk -F '=' '{print$2}'|sed 's/,/ /g')

  for num in ${ports[@]}
    do 
    cp port /etc/cwput/checks/port_"$num"
    sed -i "s/PORTNUMBER/$num/g" /etc/cwput/checks/port_"$num"
    chmod ugo+x /etc/cwput/checks/port_"$num"
    done

  for toll in ${apps[@]}
    do
    name=$(echo $toll|awk -F ':' '{print$1}')
    jar=$(echo $toll|awk -F ':' '{print$2}')
    cp service /etc/cwput/checks/$name
    sed -i 's/METRICNAME/$name/g' /etc/cwput/checks/$name
    sed -i "s#SERVICENAME#"$jar"#g" /etc/cwput/checks/$name
    chmod ugo+x /etc/cwput/checks/$name
    done

  for link in ${url[@]}
    do
    temp=$(echo $link|sed 's/\./_/g')
    cp url /etc/cwput/checks/url_"$temp"
    sed -i "s/URLNAME/$link/g" /etc/cwput/checks/url_"$temp"
    chmod ugo+x /etc/cwput/checks/url_"$temp"
    done

grep -l '/bin/cwput' /var/spool/cron/crontabs/root
  if [ $? -ne 0 ]
    then
    echo "*/5 * * * * /bin/cwput"  >> /var/spool/cron/root
  fi
