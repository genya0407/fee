set -eu
cd front
elm make src/Main.elm --output dist/index.html
cd ..

sudo cp service/fee.service /etc/systemd/system
sudo cp service/fee-sendmail.service /etc/systemd/system
sudo cp service/fee-sendmail.timer /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable fee.service
sudo systemctl restart fee.service
sudo systemctl enable fee-sendmail.timer
