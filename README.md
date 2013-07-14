# パーフェクトRuby Analytics

## How To Run

### Set ENV

- [access to amazon associate site](https://affiliate.amazon.co.jp)

#### local

```sh
export AMAZON_ACCESS_KEY=your key
export AMAZON_SECRET_KEY=your secret key
export AMAZON_ASSOCIATE_TAG=your associate name
```

```sh
bundle exec rake db:create_database
bundle exec rake db:seed
```

#### heroku

```sh
heroku config:add AMAZON_ACCESS_KEY=your key
heroku config:add AMAZON_SECRET_KEY=your secret key
heroku config:add AMAZON_ASSOCIATE_TAG=your associate name
```

```sh
heroku run rake db:create_database
heroku run rake db:seed
```

## Get Third Party Files.

### CSS
- [BootStrap Flat-UI](http://designmodo.github.io/Flat-UI/)

