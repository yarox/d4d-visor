
# Update the package system
sudo apt-get -y update

# Add some extra repositories
sudo apt-get install -y python-software-properties
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable

# Update the package system
sudo apt-get -y update

# Install packages
sudo apt-get install -y curl
sudo apt-get install -y build-essential
sudo apt-get install -y git
sudo apt-get install -y python
sudo apt-get install -y python-dev
sudo apt-get install -y qgis python-qgis

# Install dependecies
sudo apt-get -y build-dep python-numpy
sudo apt-get -y build-dep python-matplotlib

# Install distribute and pip
if ! command -v pip > /dev/null; then
    curl http://python-distribute.org/distribute_setup.py | sudo python
    curl https://raw.github.com/pypa/pip/master/contrib/get-pip.py | sudo python
fi

# Install python requirements
sudo pip install -r /vagrant/requirements.txt

# "cd" into /vagrant on login
if [ ! -f /home/vagrant/.bash_login ]; then
    echo "cd /d3" >> /home/vagrant/.bash_login
    echo ". /home/vagrant/.bash_aliases" >> /home/vagrant/.bash_login
fi

# Create an IPython notebook alias
if [ ! -f /home/vagrant/.bash_aliases ]; then
    echo "alias notebook='ipython notebook --pylab=inline --ip=0.0.0.0 --port=7070'" >> /home/vagrant/.bash_aliases
fi

# Add some niceties to bash
if [ ! -f /home/vagrant/.inputrc ]; then
    echo "'\e[A': history-search-backward" >> /home/vagrant/.inputrc
    echo "'\e[B': history-search-forward" >> /home/vagrant/.inputrc
    echo "set show-all-if-ambiguous on" >> /home/vagrant/.inputrc
    echo "set completion-ignore-case on" >> /home/vagrant/.inputrc
fi
