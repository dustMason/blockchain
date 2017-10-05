require 'sinatra'
require 'json'
require_relative 'lib/node'

# TODO add metadata `source_node` to transactions, use it to avoid posting them
# back to the originating nodes (which ignore them anyway).

set public_folder: 'public', port: (ENV['PORT'] || 4567), server: 'thin', connections: []

NODE = Node.new

get '/' do
  @node = NODE
  erb :index
end

post '/send' do
  NODE.send params[:to], params[:amount].to_i
  settings.connections.each { |out| out << "data: added transaction\n\n" }
  redirect '/'
end

post '/transactions' do
  if NODE.create_transaction(
    params[:from],
    params[:to],
    params[:amount].to_i,
    params[:public_key],
    params[:id],
    params[:signature]
  )
    settings.connections.each { |out| out << "data: added transaction\n\n" }
  end
  redirect '/'
end

post '/mine' do
  NODE.mine!
  redirect '/'
end

post '/resolve' do
  chain_data = JSON.parse(request.body.read)
  if chain_data['chain'] && NODE.resolve(chain_data['chain']) 
    status 202
    settings.connections.each { |out| out << "data: resolved\n\n" }
  else 
    status 200
  end
end

post '/peers' do
  NODE.add_peer params[:host], params[:port].to_i
  redirect '/'
end

get '/events', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    out.callback { settings.connections.delete(out) }
  end
end
