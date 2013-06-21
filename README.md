# Welcome to Vines

Vines is a scalable XMPP chat server, using EventMachine for asynchronous IO.
This gem provides support for storing user data in
[MongoDB](http://www.mongodb.org/).

Additional documentation can be found at [getvines.org](http://www.getvines.org/).

## Usage

```
$ gem install vines vines-mongodb
$ vines init wonderland.lit
$ cd wonderland.lit && vines start
```

## Configuration

Add the following configuration block to a virtual host definition in
the server's `conf/config.rb` file.

```ruby
storage 'mongodb' do
  host 'localhost', 27017
  host 'localhost', 27018 # optional, connects to replica set
  database 'xmpp'
  tls true
  username ''
  password ''
  pool 5
end
```

## Dependencies

Vines requires Ruby 1.9.3 or better. Instructions for installing the
needed OS packages, as well as Ruby itself, are available at
[getvines.org/ruby](http://www.getvines.org/ruby).

## Development

```
$ script/bootstrap
$ script/tests
```

## Contact

* David Graham <david@negativecode.com>

## License

Vines is released under the MIT license. Check the LICENSE file for details.
