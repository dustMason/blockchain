require 'sinatra'
require 'json'
require_relative 'blockchain'

set :public_folder, 'public'

NODES_COUNT = 3

# each Blockchain instance represents a peer node on a network
NODES = (0..NODES_COUNT-1).to_a.map { Blockchain.new }

get '/' do
  @blockchains = NODES
  erb :index
end

# when transactions enter the network, they are broadcast to all the nodes
post '/transactions' do
  transaction = Transaction.new(params[:from], params[:to], params[:amount].to_i, SecureRandom.uuid)
  NODES.each { |b| b.add_transaction transaction }
  redirect '/'
end

# when any node mines a new block, the rest of the nodes are notified. they each
# decide whether or not to pick up the new chain.
post '/nodes/:id/mine' do
  node = NODES.find { |b| b.id == params[:id] }
  node.create_block!
  NODES.each { |b| b.resolve! node }
  redirect '/'
end
