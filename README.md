# Authoreyes

[![Gem Version](https://badge.fury.io/rb/authoreyes.svg)](https://badge.fury.io/rb/authoreyes) [![Build Status](https://travis-ci.org/tektite-software/authoreyes.svg?branch=master)](https://travis-ci.org/tektite-software/authoreyes) [![Code Climate](https://codeclimate.com/github/tektite-software/authoreyes/badges/gpa.svg)](https://codeclimate.com/github/tektite-software/authoreyes) [![Test Coverage](https://codeclimate.com/github/tektite-software/authoreyes/badges/coverage.svg)](https://codeclimate.com/github/tektite-software/authoreyes/coverage) [![Inline docs](http://inch-ci.org/github/tektite-software/authoreyes.svg?branch=master)](http://inch-ci.org/github/tektite-software/authoreyes)

#### Warning! This gem is an alpha!

_Authoreyes_ (pronounced "authorize") is intended to be a modern, Rails 5 compatible replacement for [Declarative Authorization](https://github.com/stffn/declarative_authorization/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'authoreyes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install authoreyes

## Usage

For Rails authorization in Rails versions 4 and below, please use [Declarative Authorization](https://github.com/stffn/declarative_authorization) or one of its forks.

__Warning! This gem is not finished!__ Although authorization functionality _does_ work, you will need to do a few things to actually use it in your application...

At this point, to use Authoreyes, you must do the following:
  1. Add an `authorization_rules.rb` file.
  2. Create an Authoreyes DSL Parser object.
  3. Use the DSL Parser object to parse your authorization rules.
  4. Create an Authoreyes Authorization Engine object passing in the Parser object.
  5. Use the Engine's `permit!` and `permit?` methods in your application.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tektite-software/authoreyes.

__Please check out the wiki for guides on contributing to this project.__

## Acknowledgements

This gem was originally based on [stffn](https://github.com/stffn)'s gem [Declarative_Authorization](https://github.com/stffn/declarative_authorization).  Many thanks to stffn and all who contributed to Declarative Authorization for a great gem!


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

:copyright: 2016 Tektite Software
