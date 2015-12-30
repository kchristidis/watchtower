# Tracking and Predicting the State of a Building
Author: Andrew Kofink (ajkofink@ncsu.edu)

## Ruby version
ruby-2.1.0.p0

## System dependencies

#### Postgresql

* OS X - [Postgres.app](http://postgresapp.com/)

```sh
ruby -v
	# ruby 2.1.0p0
bundle install
```


## Configuration

```sh
cp config/database.yml.example config/database.yml
```

## Database creation/initialization

```sh
bundle exec rake db:create db:migrate db:test:prepare
```

## How to run the test suite

```sh
bundle exec guard
```
