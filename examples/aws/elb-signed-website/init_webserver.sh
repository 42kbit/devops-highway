#!/bin/bash
yum -y update
yum -y install httpd

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="">
  <head>
    <meta charset="utf-8">
    <title>my little funny website</title>
  </head>
  <body>
  <center>
    <h1 style="font-size:8em;">hello deb 3</p>
  </center>
    <header></header>
    <main></main>
    <footer></footer>
  </body>
</html>
EOF

sudo service httpd start
chkconfig httpd on