# Dockerfile for Sphinx SE
# https://hub.docker.com/_/alpine/
FROM alpine:3.12

# https://sphinxsearch.com/blog/
ENV SPHINX_VERSION 3.3.1-b72d67b

# install dependencies
RUN apk add --no-cache mariadb-connector-c-dev \
	postgresql-dev \
	wget

# set up and expose directories
RUN mkdir -pv /opt/sphinx/log /opt/sphinx/index
VOLUME /opt/sphinx/index

# http://sphinxsearch.com/downloads/sphinx-3.3.1-b72d67b-linux-amd64-musl.tar.gz
RUN wget http://sphinxsearch.com/files/sphinx-${SPHINX_VERSION}-linux-amd64-musl.tar.gz -O /tmp/sphinxsearch.tar.gz
RUN cd /opt/sphinx && tar -xf /tmp/sphinxsearch.tar.gz
RUN rm /tmp/sphinxsearch.tar.gz

# point to sphinx binaries
ENV PATH "${PATH}:/opt/sphinx/sphinx-3.3.1/bin"
RUN indexer -v

# redirect logs to stdout
RUN ln -sv /dev/stdout /opt/sphinx/log/query.log
RUN ln -sv /dev/stdout /opt/sphinx/log/searchd.log

# expose TCP port
EXPOSE 36307

VOLUME /opt/sphinx/conf

CMD searchd --nodetach --config /opt/sphinx/conf/sphinx.conf
