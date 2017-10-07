require "./blockchain-crystal/*"

module Blockchain::Crystal
  # TODO Put your code here
end

require "kemal"

NODE = Node.new

get "/" do
  "Hello World!"
end

post "/peers" do |env|
  NODE.add_peer env.params.body["host"].as(String), env.params.body["port"].to_u16
  env.redirect "/"
end

post "/peers/:index/delete" do |env|
  NODE.remove_peer env.params.url["index"].to_u32
  env.redirect "/"
end

Kemal.run
