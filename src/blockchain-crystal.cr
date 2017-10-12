require "./blockchain-crystal/*"
require "kemal"

NODE = Node.new

get "/" do
  node = NODE
  render "src/views/index.ecr"
end

post "/send" do |env|
  NODE.send env.params.body["to"], env.params.body["amount"].to_u64
  env.redirect "/"
end
# 
# post '/transactions' do
#   if NODE.create_transaction(
#     params[:from],
#     params[:to],
#     params[:amount].to_i,
#     params[:public_key],
#     params[:id],
#     params[:signature]
#   )
#     settings.connections.each { |out| out << "data: added transaction\n\n" }
#   end
#   redirect '/'
# end
# 
post "/mine" do |env|
  NODE.mine!
  env.redirect "/"
end
# 
# post '/resolve' do
#   chain_data = JSON.parse(request.body.read)
#   if chain_data['chain'] && NODE.resolve(chain_data['chain']) 
#     status 202
#     settings.connections.each { |out| out << "data: resolved\n\n" }
#   else 
#     status 200
#   end
# end

post "/peers" do |env|
  NODE.add_peer env.params.body["host"].as(String), env.params.body["port"].to_u16
  env.redirect "/"
end

post "/peers/:index/delete" do |env|
  NODE.remove_peer env.params.url["index"].to_u32
  env.redirect "/"
end

Kemal.run
