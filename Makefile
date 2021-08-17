PWD = $(shell pwd)

index:
	cat ./tests/docs.xml | docker run -i -v $(PWD)/tests/sphinx.conf:/opt/sphinx/conf/sphinx.conf -v $(PWD)/tests/data:/opt/sphinx/index \
		macbre/docker-sphinxsearch \
		indexer --config /opt/sphinx/conf/sphinx.conf test_index
