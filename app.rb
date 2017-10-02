require 'sinatra'
require_relative 'blockchain'

BC = Blockchain.new

get '/' do
  @transactions = BC.pending
  @chain = BC.chain
  @wallets = BC.ledger.wallets
  erb :index
end

post '/transactions' do
  BC.create_transaction! params[:from], params[:to], params[:amount].to_i
  redirect '/'
end

post '/mine' do
  BC.create_block!
  redirect '/'
end
