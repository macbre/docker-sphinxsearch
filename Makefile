PWD = $(shell pwd)

index:
	cat ./tests/docs.xml | docker run -i \
		-v $(PWD)/tests/sphinx.conf:/opt/sphinx/conf/sphinx.conf \
		-v $(PWD)/tests/data:/opt/sphinx/index \
		macbre/docker-sphinxsearch \
		indexer --config /opt/sphinx/conf/sphinx.conf test_index

start:
	docker run --detach --rm \
                -v $(PWD)/tests/sphinx.conf:/opt/sphinx/conf/sphinx.conf \
                -v $(PWD)/tests/data:/opt/sphinx/index \
                -p 36307:36307 \
		--name sphinx_test \
                macbre/docker-sphinxsearch

query:
	mysql -h0 -P36307 -e 'show tables'
	mysql -h0 -P36307 -e "select * from test_index where match('tags')"
