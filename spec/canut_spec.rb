require 'rspec'
require 'rack/test'
require 'json'
require_relative '../src/canut'

describe 'The Sucre app' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  after do
    delete '/list'
  end

  describe 'GET /tasks' do
    it 'read an item' do

      get '/list'

      expect(last_response).to be_ok
    end

    it 'knows if the list is empty' do
      get 'list'

      expect(last_response).to be_ok
      expect(last_parsed_response['list'].first).to be_nil
    end
  end

  describe 'POST /tasks' do
    it 'add a item' do

      post '/item', payload({name: "Patatas"})

      created_item = last_parsed_response['item']
      expect(created_item['name']).to eq('Patatas')
      expect(created_item['id']).not_to be_nil

    end

    it 'add  two items' do

      post '/item', payload({name: "Patatas",price: 6})
      post '/item', payload({name: "Huevos",price: 4})

      get '/list'
      expect(last_response).to be_ok
      expect(last_parsed_response['list'].length).to eq(2)
    end

    it 'send two items at the same time' do
      post '/items', payload({name: ["Patatas","Huevos"],price: [6,4]})
      expect(last_response).to be_ok
    end

    xit 'returns the first element with the price' do
      post '/items', payload({name: ["Patatas","Huevos"],price: [6,4]})
      expect(last_response).to be_ok
      expect(last_parsed_response['item']['price']).to eq(6)
    end

    it 'add the two elements to the list' do
      post '/items', payload({name: ["Patatas","Huevos"],price: [6,4]})
      expect(last_response).to be_ok
      get '/list'
      expect(last_response).to be_ok
      expect(last_parsed_response['list'].length).to eq(2)
    end

    it 'add the four elements to the list' do
      post '/items', payload({name: ["Patatas","Huevos","Queso","Tomate"],price: [6,4,5,2]})
      expect(last_response).to be_ok
      get '/list'
      expect(last_response).to be_ok
      expect(last_parsed_response['list'].length).to eq(4)
    end

    it 'return how many items you have added' do
      post '/items', payload({name: ["Patatas","Huevos","Queso","Tomate","Perlas"],price: [9,6,4,5,2]})
      expect(last_response).to be_ok
      expect(last_parsed_response['added_items']).to eq(5)
    end
  end

  describe 'PUT /item/:id' do
    
    before do
      post '/item', payload({name: 'Old name'})
      @id = last_parsed_response['item']['id']
    end

    context 'having a stored task' do
      it 'responds with a success code' do
        put "/item/#{@id}", payload({name: 'New name'})
        expect(last_response.status).to eq(200)
      end

      it 'return the update item' do
        put "/item/#{@id}", payload({name: 'New name'})
        expect(last_response.status).to eq(200)
        expect(last_parsed_response['item']['name']).to eq('New name')
      end

      it 'update the item in the list' do
        put "/item/#{@id}", payload({name: 'New name'})
        expect(last_response.status).to eq(200)
        expect(last_parsed_response['item']['name']).to eq('New name')

        get "/list"
        expect(last_response).to be_ok
        expect(last_parsed_response['list'].first['name']).to  eq('New name')
      end
    end
  end

  it 'delete the list' do
    delete '/list'

    get '/list'
    expect(last_response).to be_ok
    expect(last_parsed_response['list'].length).to eq(0)
  end

  def last_parsed_response
    JSON.parse(last_response.body)
  end

  def payload(data)
    JSON.dump(data)
  end
end
