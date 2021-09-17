#!/bin/bash
sudo yum -y update
sudo yum install -y httpd
cat <<EOF > /var/www/html/index.html
<html>
 <h1>Deployed via Terraform. Good job <font color="red"> Akumonya) </font></h1><br> 
 Owner ${f_name} ${l_name}<br>
 %{for x in names ~}
 Hello to ${x} from ${f_name} ${l_name}<br>
 %{ endfor ~}
</html>
EOF
sudo systemctl start httpd
sudo systemctl enable httpd
