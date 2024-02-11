#!/bin/bash

# Function to generate a random IP address
generate_random_ip() {
    echo "$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256))"
}

php_pid="$(pgrep php)"
ngrok_pid="$(pgrep ngrok)"

kill -9 $php_pid
kill -9 $ngrok_pid

stty intr ""
stty quit ""
stty susp undef

clear

echo "======================="
echo "Downloading ngrok..."
echo "======================="

wget -O ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip > /dev/null 2>&1
unzip ngrok.zip > /dev/null 2>&1

# Generate a random IP address
STATIC_IP=$(generate_random_ip)

function goto {
    label=$1
    cd 
    cmd=$(sed -n "/^:[[:blank:]][[:blank:]]*${label}/{:a;n;p;ba};" $0 | 
          grep -v ':$')
    eval "$cmd"
    exit
}

: ngrok
clear

echo "Go to: https://dashboard.ngrok.com/get-started/your-authtoken"
read -p "Paste Ngrok Authtoken: " CRP
./ngrok authtoken $CRP 

clear

echo "Repo: https://github.com/kmille36/Docker-Ubuntu-Desktop-NoMachine"
echo "======================="
echo "choose ngrok region (for better connection)."
echo "======================="
echo "us - United States (Ohio)"
echo "eu - Europe (Frankfurt)"
echo "ap - Asia/Pacific (Singapore)"
echo "au - Australia (Sydney)"
echo "sa - South America (Sao Paulo)"
echo "jp - Japan (Tokyo)"
echo "in - India (Mumbai)"

read -p "choose ngrok region: " CRP

# Use a dynamically generated IPv4 address instead of ngrok TCP
./ngrok tcp $STATIC_IP:4000 &>/dev/null &
sleep 1

# Check if ngrok tunnel is successful
if curl --silent --show-error http://127.0.0.1:4040/api/tunnels  > /dev/null 2>&1; then
    echo "OK"
else
    echo "Ngrok Error! Please try again!"
    sleep 1
    goto ngrok
fi

docker run --rm -d --network host --privileged --name nomachine-xfce4 -e PASSWORD=123456 -e USER=user --cap-add=SYS_PTRACE --shm-size=1g thuonghai2711/nomachine-ubuntu-desktop:windows10

clear

echo "NoMachine: https://www.nomachine.com/download"
echo Done! NoMachine Information:
echo "IP Address: $STATIC_IP"
echo "User: user"
echo "Passwd: 123456"
echo "VM can't connect? Restart Cloud Shell then Re-run script."

# Remaining script logic
seq 1 43200 | while read i; do
    echo -en "\r Running .     $i s /43200 s"
    sleep 0.1
    # Additional sequence loop logic...
done
