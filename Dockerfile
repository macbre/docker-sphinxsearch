# Dockerfile for Sphinx SE
# https://hub.docker.com/r/bitnami/minideb
FROM bitnami/minideb:bookworm

# https://sphinxsearch.com/blog/
ENV SPHINX_VERSION=3.8.1-d25e0bb

# install dependencies
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	libgomp1 \
	libmariadb3 libmariadb-dev \
	libpq-dev \
	wget

# set up and expose directories
RUN mkdir -pv /opt/sphinx/logs /opt/sphinx/indexes
VOLUME /opt/sphinx/indexes

# https://sphinxsearch.com/files/sphinx-3.8.1-d25e0bb-linux-amd64-musl.tar.gz - Alpine
# https://sphinxsearch.com/files/sphinx-3.8.1-d25e0bb-linux-amd64.tar.gz - Debian
RUN wget http://sphinxsearch.com/files/sphinx-${SPHINX_VERSION}-linux-amd64.tar.gz -O /tmp/sphinxsearch.tar.gz \
	&& cd /opt/sphinx && tar -xf /tmp/sphinxsearch.tar.gz \
	&& rm /tmp/sphinxsearch.tar.gz

# point to sphinx binaries
ENV PATH="${PATH}:/opt/sphinx/sphinx-3.8.1/bin"
RUN indexer -v

# redirect logs to stdout
RUN ln -sv /dev/stdout /opt/sphinx/logs/query.log \
    	&& ln -sv /dev/stdout /opt/sphinx/logs/searchd.log

# expose TCP port
EXPOSE 36307

VOLUME /opt/sphinx/conf

# allow custom config file to be passed
ARG SPHINX_CONFIG_FILE=/opt/sphinx/conf/sphinx.conf
ENV SPHINX_CONFIG_FILE=${SPHINX_CONFIG_FILE}

# prepare a start script
RUN echo "exec searchd --nodetach --config \${SPHINX_CONFIG_FILE}" > /opt/sphinx/start.sh

CMD ["sh", "/opt/sphinx/start.sh"]
