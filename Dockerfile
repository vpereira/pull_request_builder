FROM opensuse/tumbleweed

RUN zypper -n in osc ruby2.7 ruby2.7-devel git gcc make sudo libxml2-devel zlib-devel libxslt-devel
RUN gem install bundler
RUN bundle config build.nokogiri --use-system-libraries

RUN useradd -ms /bin/bash puller

RUN echo "puller ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && chmod 0440 /etc/sudoers.d/user

RUN mkdir -p /home/puller/.config/osc/
COPY oscrc /home/puller/.config/osc/
RUN chown -R puller:users /home/puller/

USER puller

WORKDIR /home/puller/pull_request_package
