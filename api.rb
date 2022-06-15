require 'sinatra'
require "json"

set :public_folder, 'public'
set :port, 80

get '/combat_bot' do
    send_file File.join(settings.public_folder, 'index.html')
end

post '/party' do
    # Specify the content type to return, json
    party = JSON.parse(File.read("party.json"))
    content_type :json
    party.to_json
end

post '/chars' do
    # Specify the content type to return, json
    char_hash = JSON.parse(File.read("char.json"))
    content_type :json
    char_hash.to_json
end

post '/initiative' do
    # Specify the content type to return, json
    content_type :json
    $initiative_final.to_json
end
    

