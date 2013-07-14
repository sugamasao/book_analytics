require 'net/http'
require 'uri'
require 'base64'
require 'openssl'
require 'time'
require 'nokogiri'


# @see http://aws.typepad.com/jp_mws/2012/12/amazon-mws-ruby-sample.html
class AmazonAPI
  METHOD = 'GET'
  ENDPOINT_SCHEME = 'http://'
  ENDPOINT_HOST   = 'ecs.amazonaws.jp'
  ENDPOINT_URI    = '/onca/xml'

  def initialize(key, secret, associate_tag)
    @key           = key
    @secret        = secret
    @associate_tag = associate_tag
  end

  def get_data(isbn)
    params = {}
    params['AssociateTag']   = @associate_tag
    params['AWSAccessKeyId'] = @key
    params['Service']        = 'AWSECommerceService'
    params['Version']        = '2011-08-02'
    params['ResponseGroup']  = 'SalesRank,ItemAttributes,Images'
    params['Operation']      = 'ItemLookup'
    params['ItemId']         = isbn
    params['Timestamp']      = Time.now.utc.iso8601

    query_string = sort_params(params).join('&')
    query_string << '&Signature=' + create_signature(@secret, query_string)

    url = ENDPOINT_SCHEME + ENDPOINT_HOST + ENDPOINT_URI + '?' + query_string
    res = Net::HTTP.get_response(URI::parse(url))
    parse_xml(res.body)
  end

  private

  def create_signature(key, param)
    signtemp = METHOD + "\n" + ENDPOINT_HOST + "\n" + ENDPOINT_URI + "\n" + param
    signature_raw = Base64.encode64(OpenSSL::HMAC.digest('sha256',key,signtemp)).delete("\n")
    URI.escape(signature_raw,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def url_encode(string)
    URI.escape(string,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def sort_params(params)
    params.keys.sort.collect do |key|
      [url_encode(key), url_encode(params[key].to_s)].join('=')
    end
  end

  def parse_xml(str_xml)
    xml = Nokogiri::XML(str_xml, nil, 'UTF-8')
    xml.remove_namespaces!

    item_attr = xml.at_xpath('//ItemAttributes')
    item      = {}
    item[:author]           = item_attr.at_xpath('//Author').text
    item[:binding]          = item_attr.at_xpath('//Binding').text
    item[:isbn]             = item_attr.at_xpath('//ISBN').text
    item[:amount]           = item_attr.at_xpath('//FormattedPrice').text
    item[:page]             = item_attr.at_xpath('//NumberOfPages').text
    item[:publication_date] = item_attr.at_xpath('//PublicationDate').text
    item[:publisher]        = item_attr.at_xpath('//Publisher').text
    item[:title]            = item_attr.at_xpath('//Title').text

    images_attr = xml.at_xpath('//ImageSets')
    covers = {}
    if images_attr
      %i(large medium tiny thumbnail).each do |name|
        image_attr = images_attr.at_xpath("//#{name.to_s.capitalize}Image")
        covers[name] = {
          url:    image_attr.at_xpath('./URL').text,
          witdh:  image_attr.at_xpath('./Width').text,
          height: image_attr.at_xpath('./Height').text
        }
      end
    end
    result = {}
    result[:rank]   = xml.at_xpath('//SalesRank').text
    result[:link]   = xml.at_xpath('//DetailPageURL').text
    result[:item]   = item
    result[:covers] = covers

    result
  end
end

