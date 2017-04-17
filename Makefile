lint:
	bundler exec rubocop

test:
	bin/anycablebility -c "bundle exec puma lib/anycablebility/dummy/config.ru" --skip-rpc
