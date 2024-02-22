lint:
	bundle exec rubocop

test:
	bundle exec bin/anyt --self-check --require=etc/tests/*.rb

release:
	gem release anyt-core
	gem release anyt -t
	git push
	git push --tags
