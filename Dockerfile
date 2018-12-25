# Dockerfile for Sphinx SE
# https://hub.docker.com/r/bitnami/minideb
FROM bitnami/minideb:stretch

# https://sphinxsearch.com/blog/
ENV SPHINX_VERSION 3.1.1-612d99f

# install dependencies
RUN apt-get update && apt-get install -y \
	default-libmysqlclient-dev \
	libpq-dev \
	wget

# set up and expose directories
RUN mkdir -pv /opt/sphinx/log /opt/sphinx/index
VOLUME /opt/sphinx/index

# http://sphinxsearch.com/files/sphinx-3.0.3-facc3fb-linux-amd64.tar.gz
RUN wget http://sphinxsearch.com/files/sphinx-${SPHINX_VERSION}-linux-amd64.tar.gz -O /tmp/sphinxsearch.tar.gz
RUN cd /opt/sphinx && tar -xf /tmp/sphinxsearch.tar.gz
RUN rm /tmp/sphinxsearch.tar.gz

# point to sphinx binaries
ENV PATH "${PATH}:/opt/sphinx/sphinx-3.1.1/bin"
RUN indexer -v

# redirect logs to stdout
RUN ln -sv /dev/stdout /opt/sphinx/log/query.log
RUN ln -sv /dev/stdout /opt/sphinx/log/searchd.log

# expose TCP port
EXPOSE 36307

VOLUME /opt/sphinx/conf

CMD searchd --nodetach --config /opt/sphinx/conf/sphinx.conf
