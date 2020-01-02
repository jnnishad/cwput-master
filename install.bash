#!/usr/bin/env bash
yum install -y git vim
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp $dir/bin/cwput.bash /usr/bin/cwput
cp $dir/etc/cwput.conf /etc/init
mkdir /etc/cwput
mkdir $dir/etc/checks
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

for toll in ${apps[@]}
do
appname=$(echo $toll|awk -F '/' '{print$NF}'|sed 's/\./_/g')
cp service /etc/cwput/checks/$appname
sed -i "s#SERVICENAME#"$toll"#g" /etc/cwput/checks/$appname

#echo -e "$toll is here"
#chmod ugo+x /etc/cwput/checks/$toll
done
#echo -e "$ports - $apps"


for link in ${url[@]}
do
temp=$(echo $link|sed 's/\./_/g')
cp url /etc/cwput/checks/url_"$temp"
sed -i "s/URLNAME/$link/g" /etc/cwput/checks/url_"$temp"
done


grep -l '/bin/cwput' /var/spool/cron/crontabs/root
if [ $? -ne 0 ]
then
echo "*/5 * * * * /bin/cwput"  >> /var/spool/cron/root
fi
