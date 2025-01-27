# AWS SSO Token Checker

To download this script run:
```bash
curl -O https://raw.githubusercontent.com/spenc-r/misc-scripts/main/aws-sso/aws-sso-token-checker.sh
```

To run this script:
```bash
chmod +x aws-sso-token-checker.sh
./aws-sso-token-checker.sh
```

To add this script to your PATH:
```bash
sudo mv aws-sso-token-checker.sh /usr/local/bin/aws-sso-token-checker
```

To run this script from anywhere:
```bash
aws-sso-token-checker
```

Run script on bash startup:
```bash
printf "\naws-sso-token-checker" >> ~/.bashrc
```