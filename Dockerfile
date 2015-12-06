
###
### build via:
###   docker build -t kilo/dev -f Dockerfile .
###
### run via:
###   docker run -t -i -p 443 kilo/dev /bin/bash
###

FROM ubuntu:14.04
RUN useradd -d /home/ubuntu -m -s /bin/bash ubuntu
ADD ./ /var/www/kilo
RUN echo "ubuntu:changeme" | chpasswd
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN sed -i s#/home/ubuntu:/bin/false#/home/ubuntu:/bin/bash# /etc/passwd
USER ubuntu
WORKDIR /var/www/kilo
