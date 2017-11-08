# auto-ssh-setup

Set up your new server in a matter of seconds.
I found myself always doing the same procedure while setting up a new server, so I wrote this little script that automates it.

Let's say you're on __host A__ and want to set up the __host B__. When you execute the script on __A__, this is what it basically does the remote server (__B__):
-   creates a new user with your username (from __A__)
-   adds the new user to sudo group
-   installs your public SSH key (from __A__; can be specified)
-   configures SSH with secure settings and restarts the service
-   disables root password

So, as you can see, it's simple but effective and saves time.

## Requirements
-   you must NOT run the script as `root` on the local host
-   your account on the local host is required to have an SSH key, if you don't have one use `ssh-keygen`
-   the remote server must have `sudo` installed
-   the remote account you're connecting with has to be in the `sudo` group (or be `root`)


## Installation
```
cd ~
git clone https://github.com/leongrdic/auto-ssh-setup.git
cd auto-ssh-setup
chmod +x setup.sh
```

## Usage
```
./setup.sh [options] [user@]hostname

# to view the full list of options use:
./setup.sh -h
```

## SSH settings
The script modifies the `/etc/ssh/sshd_config` config setting the following options
```
PermitRootLogin no
PubkeyAuthentication yes
PermitEmptyPasswords no
PasswordAuthentication no
```

## Conclusion
Since I've only been able to test this script under Ubuntu/Debian, any feedback would be helpful.

Also, feel free to contribute by opening issues if you found any problems. PRs are welcome!
