# Book Analytics

AmazonのAPIから取得できる、本カテゴリーの中での順位を取得するよ。
とはいえ、著者セントラルに登録すると順位が見れるのであまり意味が無かった……。

## How To Run

### Set ENV

- [access to amazon associate site](https://affiliate.amazon.co.jp)
- app.rb の BOOK_ISBN の値は好きな本のISBNに変えてね

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

 add New Relic

```sh
% heroku config:set NEW_RELIC_APP_NAME="book_analytics"
% heroku config:add NEW_RELIC_LICENSE_KEY=your new relic key
```

## How To Use

cronなどで /update にアクセスしてください。一時間に一回だけデータを取得しにいきます（例えば13:20にデータを取得したら13:40にアクセスしてもデータの取得は行わないで、14時台にアクセスするとデータを取得します）。

## Get Third Party Files.

### CSS
- [BootStrap Flat-UI](http://designmodo.github.io/Flat-UI/)

