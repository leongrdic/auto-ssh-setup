#!/bin/bash

function echoexit {
  echo $1
  echo
  exit $2;
}

echo
echo "auto-ssh-setup"

if [ -z `which ssh` ]; then
  echoexit "ssh not found. is it in your PATH?" 1
fi

username="$(whoami)"
keyfile="$HOME/.ssh/id_rsa.pub"
port=22

if [ "$username" == "root" ]; then
  echoexit "please run me as a regular user, not root" 1
fi

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "./setup.sh [options] [user@]hostname"
      echo " "
      echo "options:"
      echo "-h, --help                show this text"
      echo "-k PATH                   specify the ssh public key path"
      echo "-p PORT                   specify the ssh port number"
      echo "-u USERNAME               use a username different than yours"
      echo
      exit 0
      ;;
    -k)
      shift
      if test $# -gt 0; then
        export keyfile=$1
      else
        echoexit "no keyfile specified" 1
      fi
      shift
      ;;
    -p)
      shift
      if test $# -gt 0; then
        export port=$1
      else
        echoexit "no port number specified" 1
      fi
      shift
      ;;
    -u)
      shift
      if test $# -gt 0; then
        export username=$1
      else
        echoexit "no username specified" 1
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

hostname=$1

if [ -z "$hostname" ]; then
  echoexit "missing hostname, if you need help: ./setup -h" 1
fi

key="$(cat $keyfile 2>/dev/null)"

if [ -z "$key" ]; then
  echoexit "keyfile not found, or is empty" 1
fi

echo "connecting..."
ssh -t -p$port $hostname "
echo \"creating a remote user...\";
sudo useradd -m -s /bin/bash $username;
sudo passwd $username;

echo \"configuring user...\";
sudo usermod -a -G sudo $username;
sudo -u$username mkdir -p /home/$username/.ssh;
sudo -u$username touch /home/$username/.ssh/authorized_keys;
echo \"$key\" | sudo -u$username tee /home/$username/.ssh/authorized_keys > /dev/null;

echo \"configuring ssh...\";
sudo perl -pi -e 's/#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config;
sudo perl -pi -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config;
sudo perl -pi -e 's/PermitRootLogin without-password/PermitRootLogin no/g' /etc/ssh/sshd_config;

sudo perl -pi -e 's/#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config;
sudo perl -pi -e 's/PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config;

sudo perl -pi -e 's/#PermitEmptyPasswords/PermitEmptyPasswords/g' /etc/ssh/sshd_config;
sudo perl -pi -e 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config;

sudo perl -pi -e 's/#PasswordAuthentication/PasswordAuthentication/g' /etc/ssh/sshd_config;
sudo perl -pi -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config;

echo \"restarting ssh service...\";
sudo service ssh restart;

echo \"disabling root password...\";
sudo passwd -l root > /dev/null;
"

echo
echoexit "done. if there was no errors above, the server is ready!" 0
