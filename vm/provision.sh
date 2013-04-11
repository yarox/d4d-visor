
# Update the package system
sudo apt-get -y update

# Add some extra repositories
sudo apt-get install -y python-software-properties

sudo add-apt-repository ppa:kakrueger/openstreetmap
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable

sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main"
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -

# Update the package system
sudo apt-get -y update

# Install packages
sudo apt-get install -y curl
sudo apt-get install -y build-essential
sudo apt-get install -y git
sudo apt-get install -y python
sudo apt-get install -y python-dev
sudo apt-get install -y qgis python-qgis
sudo apt-get install -y postgresql
sudo apt-get install -y postgis
sudo apt-get install -y osm2pgsql

# Install dependecies
sudo apt-get build-dep -y python-numpy
sudo apt-get build-dep -y python-matplotlib
sudo apt-get install -y libxslt1-dev python-shapely python-gdal python-pyproj

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
