# Harri: HAskell Remove Redundant Imports

Do you ever wish GHC would stop harrying you about unused imports and remove
them for you?

This tool does just that.

## Installation

    $ gem install harri

## Usage

Simply pass a log containing the `STDERR` output from `GHC`, and `harri` will
auto-strip the unused imports from the affected files:

    $ harri -f ghcid.txt

Note that the files mentioned in the log are considered _relative_ to the 
location of the log itself.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/rhizomic/harri. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct](https://github.com/rhizomic/harri/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Harri project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/rhizomic/harri/blob/master/CODE_OF_CONDUCT.md).
