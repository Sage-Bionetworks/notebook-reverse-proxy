FROM ubuntu
# notebook_type is jupyter or rstudio
ARG notebook_type=jupyter

# Update the repository sources list
RUN apt-get update

# Install  apache
RUN apt-get install -y apache2 apache2-dev curl libapache2-mod-python pip && apt-get clean

# Install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install install -r requirements.txt

# Add JWT and instance tag verifying script
COPY access.py /usr/lib/cgi-bin/access.py
COPY access_helpers.py /usr/lib/cgi-bin/access_helpers.py

# Add config for local rev proxy to internal port
COPY ${notebook_type}_proxy.conf /etc/apache2/sites-available/proxy.conf

# Enable modules
RUN a2enmod ssl proxy proxy_http proxy_wstunnel rewrite python headers
# Enable proxy site
RUN a2ensite proxy
# Disable default
RUN a2dissite 000-default

COPY startup.sh /startup.sh

CMD /startup.sh
