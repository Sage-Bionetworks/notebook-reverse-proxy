FROM ubuntu

# Update the repository sources list
RUN apt-get update

# Install and run apache
RUN apt-get install -y apache2 && apt-get clean
RUN apt-get install -y curl


# Install mod_python
WORKDIR  /tmp/mod_python_source/
RUN git clone --depth=1 --branch 3.5.0.1 https://github.com/grisha/mod_python.git
WORKDIR  /tmp/mod_python_source/mod_python/
RUN ./configure && make install
# add mod_python as an available module to enable later
RUN echo 'LoadModule python_module /usr/lib/apache2/modules/mod_python.so' >> /etc/apache2/mods-available/python.load

# Add JWT and instance tag verifying script
COPY access.py /usr/lib/cgi-bin/access.py

# Add config for local rev proxy to internal port
COPY proxy.conf /etc/apache2/sites-available/proxy.conf


# Enable modules
command: a2enmod ssl proxy proxy_http proxy_wstunnel rewrite python headers
# Enable proxy site
command: a2ensite proxy
# Disable default
command: a2dissite 000-default

# TODO Remove dead code:
# from https://www.digitalocean.com/community/tutorials/how-to-use-apache-http-server-as-reverse-proxy-using-mod_proxy-extension-ubuntu-20-04
# RUN a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests


EXPOSE 80

COPY startup.sh /startup.sh

CMD /startup.sh
