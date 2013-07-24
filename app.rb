require 'logger'
require 'time'

require 'sinatra/base'
require 'kaminari/sinatra'
require 'slim'

require_relative 'lib/amazon_api'
require_relative 'lib/db'
require_relative 'lib/model/book'
require_relative 'lib/model/cover'
require_relative 'lib/model/rank'

BOOK_ISBN     = '4774158798'
#BOOK_ISBN     = '477415539X'

class Application < Sinatra::Base

  helpers Kaminari::Helpers::SinatraHelpers

  PAGE_COUNT = 72 * 3

  configure do
    enable :logging
    DB.connect_database
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  get '/' do
    @rank = Rank.order('update_date DESC').page(params[:page]).per(PAGE_COUNT)
    @book = Book.last
    @max_rank = Rank.order('update_date DESC').find_by(number: Rank.minimum(:number))
    redirect '/how_to_start_up' if @book.nil?
    slim :index
  end

  get '/how_to_start_up' do
    'access to /update'
  end

  get '/update' do
    update_date = Time.now

    logger.warn %Q(ENV['AMAZON_ACCESS_KEY'] is not set.) if ENV['AMAZON_ACCESS_KEY'].nil?
    logger.warn %Q(ENV['AMAZON_SECRET_KEY'] is not set.) if ENV['AMAZON_SECRET_KEY'].nil?
    logger.warn %Q(ENV['AMAZON_ASSOCIATE_TAG'] is not set.) if ENV['AMAZON_ASSOCIATE_TAG'].nil?

    begin
      if Rank.already_create?(update_date).nil?
        res = AmazonAPI.new(ENV['AMAZON_ACCESS_KEY'], ENV['AMAZON_SECRET_KEY'], ENV['AMAZON_ASSOCIATE_TAG']).get_data(BOOK_ISBN)

        book        = res[:item]
        book[:link] = res[:link]

        Book.find_or_create_by! book
        Rank.create!(number: res[:rank], update_date: Rank.date_format(update_date))

        unless res[:covers].empty?
          res[:covers].each do |k, v|
            cover = Cover.find_by(:label, k)
            next if cover.nil?
            logger.info 'cover set.'
            cover.update!(v)
          end
        end

        logger.info 'ok'
        'ok'
      else
        logger.info 'not to do'
        'not to do'
      end

    rescue => e
      logger.error e.message
      e.message
    end
  end


  get %r{/(\d{8})} do
    d     = params[:captures].first
    date  = "#{d[0..3]}-#{d[4..5]}-#{d[6..7]}"
    query = {start_date: "#{date} 00:00:00", end_date: "#{date} 23:59:59"}

    @rank = Rank.order('update_date DESC').where('update_date >= :start_date and update_date <= :end_date', query).page

    @book = Book.last
    @max_rank = Rank.order('update_date DESC').find_by(number: Rank.minimum(:number))
    redirect '/how_to_start_up' if @book.nil?
    slim :index
  end

#  error do
#  end


end

