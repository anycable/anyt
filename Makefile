lint:
	bundle exec rubocop

test:
	bin/anyt --self-check --require=etc/tests/*.rb
