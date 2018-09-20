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
  item = {
    id: SecureRandom.uuid,
    name: new_item['name']
  }
  @@list << item
  respond_with({item: item})
end

def add_items new_item

  num_items = new_item['name'].length
  for i in 0..num_items-1
    item = {
      id: SecureRandom.uuid,
      name: new_item['name'][i],
      price: new_item['price'][i]
    }
    @@list << item
  end
  num_items
end

post '/items' do

  added_items = add_items parsed_body
  respond_with({added_items: added_items})
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
