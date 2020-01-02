#!/usr/bin/env bash
yum install -y git vim
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp $dir/bin/cwput.bash /usr/bin/cwput
cp $dir/etc/cwput.conf /etc/init
mkdir /etc/cwput
cp -r $dir/etc/checks /etc/cwput
#cwput

ports=$(cat Service_List|grep PORTS|awk -F '=' '{print$2}'|sed 's/,/ /g')
#apps=$(cat Service_List|grep SERVICE|awk -F '=' '{print$2}'|sed 's/,/ /g')
url=$(cat Service_List|grep URL|awk -F '=' '{print$2}'|sed 's/,/ /g')

for num in ${ports[@]}
do 
cp port /etc/cwput/checks/port_"$num"
sed -i "s/PORTNUMBER/$num/g" /etc/cwput/checks/port_"$num"
chmod ugo+x /etc/cwput/checks/port_"$num"
done

#for toll in ${apps[@]}
#do
#cp service /etc/cwput/checks/$toll
#sed -i "s/SERVICENAME/$toll/g" /etc/cwput/checks/$toll
#chmod ugo+x /etc/cwput/checks/$toll
#done
#echo -e "$ports - $apps"

for link in ${url[@]}
do
temp=$(echo $link|sed 's/\./_/g')
cp url /etc/cwput/checks/url_"$temp"
sed -i "s/URLNAME/$link/g" /etc/cwput/checks/url_"$temp"
done


echo "*/5 * * * * /bin/cwput"  >> /var/spool/cron/root
