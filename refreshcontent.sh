#!/bin/bash
echo "Refreshing your workshop content ...."

sudo wget https://emtech2021cloud.s3.ap-southeast-1.amazonaws.com/iotworkshopsite.zip
sudo rm -fR /var/www/html
sudo mkdir /var/www/html
sudo mv iotworkshopsite.zip /var/www/html
cd /var/www/html
sudo unzip iotworkshopsite.zip
sudo rm iotworkshopsite.zip
cd ~

echo "Completed!"
