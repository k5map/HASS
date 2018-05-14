# If RPi is not syncing the time
Use the `systemd-timesyncd` service as explained [here](https://wiki.archlinux.org/index.php/systemd-timesyncd)
Here are the [time servers](https://wiki.archlinux.org/index.php/Network_Time_Protocol_daemon#Connection_to_NTP_servers) that I used.
```
NTP=0.north-america.pool.ntp.org 1.north-america.pool.ntp.org 2.north-america.pool.ntp.org 3.north-america.pool.ntp.org
FallbackNTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
```

# HASS operations
1. To stop HA `sudo systemctl stop home-assistant@homeassistant`
2. To start HA `sudo systemctl start home-assistant@homeassistant`
3. To restart HA `sudo systemctl restart home-assistant@homeassistant`
4. To check realtime logs `sudo journalctl -f -u home-assistant@homeassistant`
5. To check logs `sudo systemctl status -l home-assistant@homeassistant`

# Backing up Configurations on Github
Thanks to @dale3h for assistance with these instructions.

1. Install `git` using `sudo apt-get install git`
2. Go to https://github.com/new and create a new repository. I named mine `HASS`. Initialize with `readme: no` and `.gitignore: none`.
3. Navigate to your `.homeassistant` directory. For AIO, it should be `/home/hass/.homeassistant`, and for HASSbian, it is `/home/homeassistant/.homeassistant`.
4. Run `sudo su -s /bin/bash hass` for AIO and `sudo su -s /bin/bash homeassistant` for HASSbian.
5. Run `wget https://raw.githubusercontent.com/arsaboo/homeassistant-config/master/.gitignore` to get the `.gitignore` file from your repo (replace the link to match your repository). You can add things to your `.gitignore` file that you do not want to be uploaded.
6. Next, we need to add SSH keys to your Github account.
    * Navigate to `cd /home/hass/.ssh` (for AIO). If you don't have `.ssh` directory, create one and change the permission `chmod 700 ~/.ssh`.
    * Run `ssh-keygen -t rsa -b 4096 -C "homeassistant@pi"`. If you want to enter a passphrase, that's up to you. If you do, you'll have to enter that passphrase any time you want to update your changes to github. If you do not want a passphrase, leave it blank and just hit `Enter`.
    * Save the key in the default location (press `Enter` when it prompts for location).
    * When you're finished, run `ls -al ~/.ssh` to confirm that you have both `id_rsa` and `id_rsa.pub` files.
    * Go to https://github.com/settings/keys and click `New SSH key` button at top right. Title: `homeassistant@pi` (or whatever you want, really...it's just for you to know which key it is)
    * Run `cat id_rsa.pub` in the SSH session and copy/paste the output to that github page.
    * Then click `Add SSH key` button.
7. Go back to your repo page on GitHub. It'll be something like https://github.com/yourusernamehere/homeassistant-config. Click the green `Clone or download` button, and then click `Use SSH`.
8. You should see something like this in the textbox: `git@github.com:yourusername/homeassistant-config.git`. Copy that to your clipboard.
9. Now you are ready to upload the files to GitHub.
    * Navigate to `cd ~/.homeassistant`
    * `git init`
    * `git add .`
    * `git commit -m 'initial commit'`
    * If you get an error about `*** Please tell me who you are.`, run `git config --global user.email "your@email.here"` and `git config --global user.name "Your Name"`
    * After that commit succeeds, run: `git remote add origin git@github.com:yourusername/homeassistant-config.git` (make sure you enter the correct repo URL here)
    * Just to confirm everything is right, run `git remote -v` and you should see:
      ```
      hass@raspberrypi:~/.homeassistant$ git remote -v
      origin  git@github.com:arsaboo/homeassistant-config.git (fetch)
      origin  git@github.com:arsaboo/homeassistant-config.git (push)
      ```
    * Finally, run `git push origin master`.

10. For subsequent updates:
    * `cd /home/homeassistant/.homeassistant`
    * `sudo su -s /bin/bash homeassistant`
    * `git add .`
    * `git commit -m 'your commit message'`
    * `git push origin master`
11. To restore from your Github repository (replace the URL):
    ```bash
    sudo su -s /bin/bash homeassistant
    cd /home/homeassistant
    git clone git@github.com:arsaboo/homeassistant-config.git .homeassistant
    ```

# To upgrade HASS manually:

*  Login to system. HASS configuration files are saved in `/home/homeassistant/.homeassistant` and the code files are saved in `/srv/homeassistant/lib/python3.5/site-packages/homeassistant/`.
*  Change to homeassistant user `sudo su -s /bin/bash homeassistant`
*  Change to virtual enviroment `source /srv/homeassistant/bin/activate`
*  Update HA `pip3 install --upgrade homeassistant`. To update to a different branch, use the complete git URL, `pip3 install --upgrade git+git://github.com/home-assistant/home-assistant.git@dev`
*  Type `exit` to logout the hass user and return to the `pi` user.
*  Restart the Home-Assistant Service `sudo systemctl restart home-assistant@homeassistant`

# Miscellaneous Tips/Tricks
* You can test the Read Speed of your SD card using (note, this command takes some time to run):
  ```
  sudo dd if=/dev/mmcblk0 of=/dev/null bs=8M count=100
  sudo hdparm -t /dev/mmcblk0
  ```
* Many of the problems with Pi are related to faulty power supply. You can use `vcgencmd get_throttled` to check if your Pi is getting adequate power supply. You want that to return `throttled=0x0`. If not it means that the Raspberry is throttling itself due to low voltage, or other factors.
* Test Write speed (will create 200MB file in /home/pi/testfile) using `dd if=/dev/zero of=/home/pi/testfile bs=8M count=25`
* To check which files are using up all the space on your SD card, run `sudo du | sort -n`. You can delete the culprits using something like `sudo rm -rf ./.pm2/logs/` (will recursively delete folder /logs/).