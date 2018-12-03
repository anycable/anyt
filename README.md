[![Gem Version](https://badge.fury.io/rb/anyt.svg)](https://rubygems.org/gems/anyt) [![Circle CI](https://circleci.com/gh/anycable/anycablebility/tree/master.svg?style=svg)](https://circleci.com/gh/anycable/anycablebility/tree/master) [![Gitter](https://img.shields.io/badge/gitter-join%20chat%20%E2%86%92-brightgreen.svg)](https://gitter.im/anycable/anycablebility)

# AnyCable Conformance Testing Tool

AnyT is a command-line tool to test your [AnyCable](http://anycable.io)-compatible WebSocket servers.
It contains a set of tests to determine which features are supported by the implementation under consideration.

## Installation

```sh
gem install anyt
```

## Usage

You should provide a command to run the server and the target URL for WebSocket clients:

```sh
anyt -c "anycable-go" --target-url="ws://localhost:8080/cable"
```

By default it launches gRPC server on `localhost:50051` and use local Redis instance for broadcasts (`localhost:6379`).

For more options run:

```sh
anyt -h
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/anycable/anyt/issues.

## License
The library is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
