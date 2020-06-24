lint:
	bundle exec rubocop

test:
	bundle exec bin/anyt --self-check --require=etc/tests/*.rb
