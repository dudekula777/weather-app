# weather-app
1. Generate EC2 SSH Key

If you haven’t already created a key:

ssh-keygen -t rsa -b 4096 -f my-ec2-key

This creates:

my-ec2-key → private key

my-ec2-key.pub → public key

Upload the public key (my-ec2-key.pub) into AWS → EC2 → Key Pairs (or via Terraform).