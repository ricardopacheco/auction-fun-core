# AuctionFunCore

This lib contains all the business logic necessary to run the auctions. A principle and standard must be strictly followed: The [SRP principle](https://en.wikipedia.org/wiki/Single_responsibility_principle)The principle of single responsibility and some standard [clean architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) concepts.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'auction_fun_core'
```

And then execute:

```sh
user@host:~$ bundle install
```

Or install it yourself as:

```sh
user@host:~$ gem install auction_fun_core
```

## Getting Started

Initially, download the project remotely and copy the templates from the project's environment variables:

```sh
user@host:~$ git clone git@github.com:ricardopacheco/auction-fun-core.git core
user@host:~$ cd core
user@host:~$ cp .env.development.template .env.development
user@host:~$ cp .env.test.template .env.test
```

> As the idea of this project is to be a lib, it was decided to use a specific environment variable called `APP_ENV`, so as not to conflict with others if the lib is used by a framework.

## Development

Configure the `.env.development` file with the values according to your machine or network.

Run the commands below to create the database and its structure, remembering to replace
the `userdb` by the user of your postgresql service. By default, if `APP_ENV` is not provided
is considered the value `development` by default.

### OS dependencies

- [ASDF](https://asdf-vm.com/#/core-manage-asdf)

#### Ruby

```
    user@host:~$ sudo apt install autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
    user@host:~$ asdf plugin add ruby
    user@host:~$ asdf install ruby 3.3.0
    user@host:~$ gem install pg -v 1.4.5 --verbose -- --with-pg-config=$HOME/.asdf/installs/postgres/14.2/bin/pg_config # Fix pg_config
    user@host:~$ bundle install
```

### Interactive prompt

## Test

Configure the `.env.test` file with the values according to your machine or network.

Run the test suite with the coverage report using the command:

```sh
user@host:~$ CI=true APP_ENV=test bundle exec rspec .
```

## Documentation

This project uses `yadr` as a documentation tool. To generate documentation and view it, run

```sh
    user@host:~$ bundle exec yard server --reload
```

Documentation will be available at `http://localhost:8808`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
