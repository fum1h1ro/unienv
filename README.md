# Ubb

Helper for selecting Unity version.

[![Gem Version](https://badge.fury.io/rb/unienv.png)](http://badge.fury.io/rb/unienv)

## Description



## Installation

Install it yourself as:

```
$ gem install unienv
```

or

```
$ sudo gem install unienv
```

## Usage

```
$ unienv [command]
```

### commands

#### list

Display list of installable Unity versions.

Add `--local` option, display list of installed version.

```
$ unienv list                                                                                                                                                                                                                                                                                                   [master>]
  5.2.0f3
  5.1.3p3
  5.1.3p2
  5.1.3p1
  5.1.2p3
  5.1.2p2
  5.1.2p1
```

#### install

Install Unity Editor to local that specified version.

```
$ unienv install 5.2
$ unienv install 5.1.3p2
```


## Contributing

1. Fork it ( https://github.com/fum1h1ro/unienv/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
