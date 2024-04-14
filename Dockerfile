# Dockerfile for Sphinx SE
# https://hub.docker.com/_/alpine/
FROM --platform=linux/amd64 alpine:3.19

# https://sphinxsearch.com/blog/
ENV SPHINX_VERSION 3.7.1-da9f8a4

# install dependencies
RUN apk add --no-cache mariadb-connector-c-dev \
	postgresql-dev \
	wget

# set up and expose directories
RUN mkdir -pv /opt/sphinx/logs /opt/sphinx/indexes
VOLUME /opt/sphinx/indexes

# https://sphinxsearch.com/files/sphinx-3.7.1-da9f8a4-linux-amd64-musl.tar.gz
RUN wget http://sphinxsearch.com/files/sphinx-${SPHINX_VERSION}-linux-amd64-musl.tar.gz -O /tmp/sphinxsearch.tar.gz \
	&& cd /opt/sphinx && tar -xf /tmp/sphinxsearch.tar.gz \
	&& rm /tmp/sphinxsearch.tar.gz

# point to sphinx binaries
ENV PATH "${PATH}:/opt/sphinx/sphinx-3.7.1/bin"
RUN indexer -v

# redirect logs to stdout
RUN ln -sv /dev/stdout /opt/sphinx/logs/query.log \
    	&& ln -sv /dev/stdout /opt/sphinx/logs/searchd.log

# expose TCP port
EXPOSE 36307

VOLUME /opt/sphinx/conf

# allow custom config file to be passed
ARG SPHINX_CONFIG_FILE=/opt/sphinx/conf/sphinx.conf
ENV SPHINX_CONFIG_FILE ${SPHINX_CONFIG_FILE}

# prepare a start script
RUN echo "exec searchd --nodetach --config \${SPHINX_CONFIG_FILE}" > /opt/sphinx/start.sh

CMD sh /opt/sphinx/start.sh
