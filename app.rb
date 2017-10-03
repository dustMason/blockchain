require 'sinatra'
require 'json'
require_relative 'node'

set public_folder: 'public', port: (ENV['PORT'] || 4567), server: 'thin', connections: []

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
  settings.connections.each { |out| out << "data: added transaction\n\n" }
  redirect '/'
end

post '/mine' do
  NODE.mine!
  redirect '/'
end

post '/resolve' do
  if NODE.resolve(JSON.parse(request.body.read)) 
    status 202
    settings.connections.each { |out| out << "data: resolved\n\n" }
  else 
    status 200
  end
end

post '/peers' do
  NODE.add_peer params[:address]
  redirect '/'
end

get '/events', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    out.callback { settings.connections.delete(out) }
  end
end
