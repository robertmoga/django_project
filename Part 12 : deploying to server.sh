Part 12 : deploying to server
 - I plan to use aws free tier : let's see how that works 

> hostnamectl set-hosetname django-server
> nano  /etc/hosts 
    - add server ip adress and django-server
> adduser robert
> adduser robert sudo # adding robert to sudo group
> logout

> ssh robert@ip
# creating authetication by key
> mkdir -p ~/.ssh

locally : generating a key
>> ssh-keyget -b 4096 -> will generate a pub and private key. 
    Scp the public one to the vm user@ip:~/.ssh/authorized_keys

back to he vm
> ls .ssh -> to check
> sudo chomd 700 ~/.ssh/
> sudo chomd 600 ~/.ssh/*
> logout

try to ssh again to see if that works 

# disable root and password auth
nano /etc/ssh/sshd_config
    -> PermitRootLogin -> set to no
    -> PasswordAuthentication -> uncomment and set to no

> restart the system
sudo sysctl restart sshd

# setting up a firewall
> sudo apt-get install ufw
> sudo ufw default allow outgoing
> sudo ufw default deny incoming -> this can lock you out without the following rules
> sudo ufw allow ssh
> sudo ufw allow 8000 # for now, and we we'll enable 80 or 446 later
> sudo ufw enable
> sudo ufw status

# deploying the actual app
# locally create a req.txt file -> troublesome in my case
scp -r local_path target_path  # or use git clone

# on the vm
> sudo apt-get install python3-pip
> sudo apt-get install python3-venv # i'd rather go for virtualenvwrapper
> python3 -m venv django_project/venv
> source venv/bin/activate
> pip install -r req.txt
> nano settings.py 
    - ALLOWED_HOSTS = [''] > add vm ip
    - STATIC_ROOT = os.path.join(BASE_DIR, 'static') # right above STATIC_URL
> python3 manage.py collectstatic
> python3 manage.py runserver 0.0.0.0:8000 -> allows us to acess from current ip adress:8000 
    - should be working : finger crossed
    - do a test to create a new user
    - test admin page: check for the new records
    - should establish the reset password env variables

# switch to apache 
> sudo apt-get install apache2
> sudo apt-get install libapache2-mode-wsgi-py3 
> cd /etc/apache2/sites-available/
> sudo cp 000-defaultt.config django_project.config # making a copy of the config tempalte
> nano django_project.config
    - before </virualhost> add :
        Alias /static /home/robert/django_project/static
        <Directory /home/robert/django_project/static>
            Require all granted
        </Directory>

        Alias /media /home/robert/django_project/media
        <Directory /home/robert/django_project/media>
            Require all granted
        </Directory>

        <Directory /home/robert/django_project/django_project>
            <Files wsgi.py>
                Require all granted
            </Files>
        </Directory>

        WSGIScriptAlias / /home/robert/django_project/django_project/wsgy.py
        WSGIDaemonProcess djang_app python-path=/home/robert/django_project python-home=/home/robert/django_project/venv
        WSGIProcessGroup django_app 

>cd ~
> sudo a2ensite #apache2 enable site
    - looking for a confirmation
> sudo a2dissite 000-default.conf
> systemctl reload apache2
> sudo chown :www-data django_project/db.sqlite3 # give permisions to apache on our db
> sudo chmod 664 django_project/db.sqlite3
> sudo chown :www-data django_project/
> sudo chmod 775 django_project/ # later edit to fix err
> ls -la

> sudo chown _r : www-data django_project/media/
> sudo chmod -R 775 django_project/media


> sudo touch /etc/config.json # a config file for credentials and such
# take the secret_key from setting.py  and put it in the config
- in settings also set DEBUG=False

# remove port 8000
> sudo ufw delete allow 8000
> sudo ufw allow http/tcp
> sudo service apache2 restart

# try access via IP
