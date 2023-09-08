#! /bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo service httpd start  
sudo echo '<h1>Welcome to our  grad-proj  EC2 instance</h1>' > /var/www/html/index.html
#sudo echo '<<br>' >> /var/www/html/index.htm
sudo echo "<h1>HostName = $(hostname -f) </h1>" >> /var/www/html/index.html
sudo echo "<br>" >> /var/www/html/index.html
sudo echo "<br>" >> /var/www/html/index.html
sudo echo "<br>" >> /var/www/html/index.html
sudo echo "<h5>Dr.Rizk s Team </h5>" >> /var/www/html/index.html

cd /home/ec2-user/
docker-compose up
