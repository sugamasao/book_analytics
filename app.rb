require 'logger'
require 'time'
require 'date'

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

  before do
    @book     = Book.last
    @max_rank = Rank.max_rank
  end

  get '/' do
    @rank = Rank.order('update_date DESC').page(params[:page]).per(PAGE_COUNT)
    redirect '/how_to_start_up' if @book.nil?
    slim :index
  end

  get %r{/(\d{4})-?(\d{2})-?(\d{2})} do
    begin
    @date = Date.new(params[:captures][0].to_i, params[:captures][1].to_i, params[:captures][2].to_i)
    @rank = Rank.permalink(@date)
    @next = Rank.permalink(@date + 1).count > 0
    @prev = Rank.permalink(@date - 1).count > 0

    redirect '/how_to_start_up' if @book.nil?
    rescue => e
      logger.error e.message
      logger.error e.backtrace
      error 404
    end

    slim :permalink
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
      unless Rank.already_create?(update_date)
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

        logger.info 'update ok'
        'ok'
      else
        logger.info 'update not to do'
        'not to do'
      end

    rescue => e
      logger.error e.message
      e.message
    end
  end

  not_found do
    slim :not_found
  end
end

