require 'sinatra'
require 'securerandom'

@@list = []

get '/' do
  "Hello, World!"
end

get '/list' do
  respond_with({ list: @@list })
end

post '/item' do
  new_item = parsed_body
  add_item new_item
end

def add_item new_item
  item = {
    id: SecureRandom.uuid,
    name: new_item['name']
  }
  @@list << item
  respond_with({item: item})
end

post '/items' do
  recieve_items ||= parsed_body
  item = {name: recieve_items['name'][0], price: recieve_items['price'][0]}
  num_items = recieve_items['name'].length
  for i in 0..num_items-1
    item = {
      id: SecureRandom.uuid,
      name: recieve_items['name'][i],
      price: recieve_items['price'][i]
    }
    @@list << item
  end
end

delete '/list' do
  @@list = []
end

put '/item/:id' do
  id = params[:id]
  item = @@list.find { |item| item[:id] == id}
  item['name'] = parsed_body['name']

  respond_with({item: item})
end


def parsed_body
  JSON.parse(request.body.read)
end

def respond_with(message)
  :ok
  content_type :json

  JSON.dump(message)
end
