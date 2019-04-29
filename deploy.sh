set -eu
cd front
elm make src/Main.elm --output dist/index.html
cd ..

sudo cp service/fee.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl restart fee.service
