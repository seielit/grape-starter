[![Build Status](https://travis-ci.org/LeFnord/grape-starter.svg?branch=master)](https://travis-ci.org/LeFnord/grape-starter)
[![Gem Version](https://badge.fury.io/rb/grape-starter.svg)](https://badge.fury.io/rb/grape-starter)
[![Inline docs](http://inch-ci.org/github/LeFnord/grape-starter.svg?branch=master)](http://inch-ci.org/github/LeFnord/grape-starter)


# Grape Starter

Is a tool to help you to build up a skeleton for a [Grape](http://github.com/ruby-grape/grape) API mounted on [Rack](https://github.com/rack/rack) ready to run.
[grape-swagger](http://github.com/ruby-grape/grape-swagger) would be used to generate a  [OAPI](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md) compatible documentation, which could be shown with [ReDoc](https://github.com/Rebilly/ReDoc).

![ReDoc demo](doc/re-doc.png)

## Why the next one?

- build up a playground for your ideas, prototypes, testing behaviour … whatever
- ~~no assumtions about~~ you can choose, if you want to use a backend/ORM, ergo no restrictions, only a pure grape/rack skeleton with a nice documentation

## Usage

#### Install it
```
$ gem install grape-starter
```


#### Create a new project
```
$ grape-starter new awesome_api
```
with following options:
```
-f, --force                # overwrites existend project
-p foobar, --prefix=foobar # provide a prefix under which the API can be accessed, default: api
-o sequel, --orm=sequel    # create also needed files and folders for the specified ORM
```

This command creates a folder named `awesome_api` containing the skeleton. With following structure:

```
├── <Standards>
├── api
│   ├── base.rb        # the main API class, all other endpoints would be mounted in it
│   ├── endpoints      # contains the endpoint file for a resource
│   │   └── root.rb    # root is always available, it exposes all routes/endpoints, disable by comment it out in base.rb
│   └── entities       # contains the entity representation of the reource, if wanted
│       └── route.rb
├── config             # base configuration
│   └── …
├── config.ru          # Rack it up
├── lib                # contains the additional lib file for a resource
│   ├── models
│   │   └── version.rb
│   └── models.rb
├── public             # for serving static files
│   └── redoc.html     # provides the ReDoc generated oapi documentation
├── script             # setup / server / test etc.
│   └── …
└── spec               # RSpec
    └── …
```

… using `--orm` flag adds follwing files and directories to above project structure:
```
├── .config
├── config
│   …
│   ├── database.yml
│   └── initializer
│       └── database.rb
…
├── db
│   └── migrations
…
```

Don't forget to adapt the `config/database.yml` to your needs
and also to check the Gemfile for the right gems.

In `.config` the choosen ORM would be stored.

To run it, go into awesome_api folder, start the server
```
$ cd awesome_api
$ ./script/server *port
```
the API is now accessible under: [http://localhost:9292/api/v1/root](http://localhost:9292/api/v1/root)  
the documentation of it under: [http://localhost:9292/](http://localhost:9292/).

More could be found in [README](template/README.md).


#### Add resources
```
$ grape-starter add foo
```
with following options:
```
-e, --entity # a grape entity file will also be created
```
to add CRUD endpoints for resource foo. For more options, see `grape-starter add -h`.
This adds endpoint and lib file and belonging specs, and a mount entry in base.rb.


#### Remove a resource
```
$ grape-starter rm foo
```
to remove previous generated files for a resource.


## Contributing

Any contributions are welcome on GitHub at https://github.com/LeFnord/grape-starter.

### Adding a new ORM template

To add an new ORM, it needs following steps:

1. A template class, with predefined methods …

  ```ruby
  module Starter
    module Templates
      module <YOUR NAME>
        def initializer
          # provide your string
        end

        def config
          # provide your string
        end

        def rakefile
          # provide your string
        end

        def gemfile
          # provide your string
        end
      end
    end
  end
  ```

  see as example [sequel.rb](lib/starter/builder/templates/sequel.rb), there the return value of each method would be written into the
  corresponding file (see: [orms.rb](lib/starter/builder/orms.rb)).

2. An additional switch in the [`Starter::Orms.build`](https://github.com/LeFnord/grape-starter/blob/67738438ba9278b280a6eac402096fcb74526ab3/lib/starter/builder/orms.rb#L7-L13) method to choose the template.
3. An entry in the description of the [`add` command](https://github.com/LeFnord/grape-starter/blob/master/bin/grape-starter#L30), when it would be called with `-h`

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
