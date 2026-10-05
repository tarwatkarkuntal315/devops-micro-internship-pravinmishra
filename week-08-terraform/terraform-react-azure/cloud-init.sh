#!/bin/bash
# Deploys my-react-app on Ubuntu with Nginx (runs as root via cloud-init custom_data)
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive
export HOME=/root

# 1. Update packages and install Node.js and npm
apt-get update -y
apt-get install -y nodejs npm git
node -v
npm -v

# 2. Install, start and enable Nginx
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

# 3. Clone the React application
rm -rf /opt/my-react-app
git clone https://github.com/pravinmishraaws/my-react-app.git /opt/my-react-app
cd /opt/my-react-app

# Personalise App.js with deployer name and date
sed -i "s|Your Full Name|Kuntal Tarwatkar|" src/App.js
sed -i "s|DD/MM/YYYY|$(date +%d/%m/%Y)|" src/App.js

# 4. Install dependencies and build
npm install
npm run build

# 5. Deploy build files to the Nginx web directory
rm -rf /var/www/html/*
cp -r build/* /var/www/html/
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# 6. Configure Nginx for React SPA routing
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    error_page 404 /index.html;
}
EOF

# 7. Test and restart Nginx
nginx -t
systemctl restart nginx

echo "React app deployment completed successfully"
