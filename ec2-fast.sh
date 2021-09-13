#!/bin/bash

# Patch instance for security updates
sudo yum update -y

# Set Path
echo "Starting IoT Workshop Script ..."
cd ~

source ~/.bashrc

# Setup a systemd for c9
cd ~
# Update the username/password in the c9.service file
userfile="/home/ec2-user/c9UserName.txt" 
username=$(cat "$userfile")
export username
passfile="/home/ec2-user/c9Password.txt" 
password=$(cat "$passfile")
export password
perl -pi -e 's/aws/$ENV{username}/g' c9.service
perl -pi -e 's/icebreaker/$ENV{password}/g' c9.service
# Setup service
sudo cp ~/c9.service /etc/systemd/system/c9.service
sudo systemctl enable c9.service
sudo systemctl start c9.service

# Upgrade node-red

sudo systemctl stop node-red.service
npm install -g node-red
npm install -g node-red-admin
# Load and then stop to gen settings
sudo systemctl start node-red.service
sudo systemctl stop node-red.service


# Setup the node-red security
cd ~
curl -O --retry 5 https://s3-us-west-2.amazonaws.com/iotworkshop/node-red-settings.js
npm install bcryptjs
# Hash password for node-red
node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" $(cat "$passfile") > /home/ec2-user/c9PasswordHashed.txt
cd ~
passfileHashed="/home/ec2-user/c9PasswordHashed.txt" 
passwordHashed=$(cat "$passfileHashed")
export passwordHashed
perl -pi -e 's/aws/$ENV{username}/g' node-red-settings.js
perl -pi -e 's/icebreaker/$ENV{passwordHashed}/g' node-red-settings.js
cp /home/ec2-user/node-red-settings.js /home/ec2-user/.node-red/settings.js

# Restart node-red to force security reload
sudo systemctl start node-red

# Download and setup the website locally
echo "Installing portal content ..."
curl -O --retry 5 https://s3-us-west-2.amazonaws.com/iotworkshop/iotworkshopsite.zip
sudo mv iotworkshopsite.zip /var/www/html
cd /var/www/html
sudo rm index.html
sudo rm main.css
sudo rm internet-of-things.png
sudo rm countdown.js
sudo unzip iotworkshopsite.zip
sudo rm iotworkshopsite.zip
cd ~
mkdir tools 
cd tools
curl -O --retry 5 https://s3-us-west-2.amazonaws.com/iotworkshop/refreshcontent.sh
chmod +x refreshcontent.sh
cd ~

# Download code and lab assets
cd workspace
curl -O --retry 5 https://s3-us-west-2.amazonaws.com/iotworkshop/iotworkshopassets.zip
unzip iotworkshopassets.zip
rm iotworkshopassets.zip
cd ~

# Setup the CLI default region
echo "Setup CLI credentials ..."
cd ~
mkdir .aws
cd .aws
echo "[default]" > credentials
echo "output = json" >> credentials
cat /home/ec2-user/region.txt >> credentials
cd ~

# Setup node-red extensions
echo "Setup Node-Red extensions ..."
cd ~
mkdir aws
cd aws
curl -O --retry 5 https://s3-us-west-2.amazonaws.com/iotworkshop/sensehatsim.zip
unzip sensehatsim.zip
/home/ec2-user/n/bin/npm link
sudo systemctl restart node-red.service
cd ~

# Cleanup
rm c9.service

# The AMI has a bug in the image code, this will update that.
# When the master AMI is updated this section won't be needed.
# Setup GG support tools
# Remove entire bad folder
rm -fR gg
# continue ....
## GGv1 is gone - moving on with GGv2 in the future
#echo "Setup Greengrass support tools ..."
#mkdir gg
#cd gg
#curl -O --retry 5 https://s3-us-west-2.amazonaws.com/iotworkshop/gg-provisioner.zip
#unzip gg-provisioner.zip
#chmod +x setup.sh
#chmod +x deploy.sh
#cd ~
#cd workspace
#mkdir greengrass
#cd greengrass
#ln -s /home/ec2-user/gg/functions/HelloWorldPython/
#ln -s /home/ec2-user/gg/functions/RatchetHello/
#ln -s /home/ec2-user/gg/functions/RatchetButtonPress/
#cd ~

# Update the Greengrass installation to the latest
# When the AMI master is updated this can be removed

#echo "Setting up the Greengrass bits ..."
cd ~
rm -fR /greengrass
#curl -O --retry 5 https://d1onfpft10uf5o.cloudfront.net/greengrass-core/downloads/1.10.0/greengrass-linux-x86-64-1.10.0.tar.gz
#sudo tar -zxvf greengrass-linux-x86-64-1.10.0.tar.gz -C /
#cd ~

# Update NodeJS to 12
# When the AMI master is updated this can be removed

n 12

# update the symlink for gg
sudo cp /home/ec2-user/n/bin/node /usr/local/bin/nodejs12

# GG/ML stuff
cd /tmp/
wget https://s3-us-west-2.amazonaws.com/iotworkshop/greengrass-ml-ec2.tgz
tar zxf /tmp/greengrass-ml-ec2.tgz -C /home/ec2-user/
sudo usermod -a -G ggc_group ec2-user
sudo mkdir -p -m 775 /greengrass-ml/images/cifar10
sudo chown -R ggc_user:ggc_group /greengrass-ml
sudo chmod g+s /greengrass-ml/images/cifar10
sudo pip3 install greengrasssdk numpy file-magic mxnet==1.2.1 scikit-image

# Signal CF to let the user proceed while the instance reboots
echo "Tell CloudFormation we're done ..."
bash /signal.txt
sudo rm /ec2-fast.sh

# Final reboot and we should be ready
echo "See you soon!"
sudo reboot


