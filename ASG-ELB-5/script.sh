		#!/bin/bash
        sudo yum -y update
		sudo yum install -y httpd
		sudo systemctl start httpd
		sudo systemctl enable httpd
		echo "<h1>Deployed via Terraform. Good job Akumonya)vrsion2</h1>" | sudo tee /var/www/html/index.html
	