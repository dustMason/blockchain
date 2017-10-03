require 'sinatra'
require 'json'
require_relative 'node'

set :public_folder, 'public'
set :port, ENV['PORT']

NODE = Node.new

get '/' do
  @node = NODE
  @blockchain = @node.blockchain
  @peers = @node.peers
  @ledger = @node.ledger
  erb :index
end

post '/transactions' do
  NODE.add_transaction params[:from], params[:to], params[:amount].to_i, params[:id]
  redirect '/'
end

post '/mine' do
  NODE.mine!
  redirect '/'
end

post '/resolve' do
  NODE.resolve(JSON.parse(request.body.read)) ? status(202) : status(200)
end

post '/peers' do
  NODE.add_peer params[:address]
  redirect '/'
end
