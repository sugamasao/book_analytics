require 'sinatra/base'
require 'slim'
require 'active_record'

require_relative 'lib/amazon_api'
require_relative 'lib/db'
require_relative 'lib/model/book'
require_relative 'lib/model/cover'
require_relative 'lib/model/rank'

BOOK_ISBN     = '4774158798'
#BOOK_ISBN     = '477415539X'

class Application < Sinatra::Base
  configure do
    path = Pathname.new(__dir__).join('db', 'database.sqlite3')
    conn = DB.connect_database(path)
  end

  get '/' do
    @rank = []#Rank.order('update_date DESC').load
    @book = Book.last
    redirect '/how_to_start_up' if @book.empty?
    slim :index
  end

  get '/how_to_start_up' do
    'access to /update'
  end

  get '/update' do
    update_date = Time.now
    if Rank.already_create?(update_date).nil?
      res = AmazonAPI.new(ENV['AMAZON_ACCESS_KEY'], ENV['AMAZON_SECRET_KEY'], ENV['AMAZON_ASSOCIATE_TAG']).get_data(BOOK_ISBN)

      book = res[:item]
      book[:link] = res[:link]
      Book.find_or_create_by! book

      Rank.create!(number: res[:rank], update_date: Rank.date_format(update_date))

      unless res[:covers].empty?
        res[:covers].each do |k, v|
          cover = Cover.find_by(:label, k)
          next if cover.nil?
          cover.update!(v)
        end
      end
      'ok'
    else
      'not to do'
    end
  end
end

