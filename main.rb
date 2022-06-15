require "dotenv/load"
require "discordrb"
require "sequel"
require 'sinatra'
require_relative "oneshot.rb"
require_relative "dnd-logic.rb"
require_relative "api.rb"



if File.exists?('.env') != true
    File.open('.env', 'w+') do |env|
        File.write(env,"PREFIX=$\nTOKEN=\nCLIENT_ID=\nSECRET=")
    end
    abort "new .env file created, please enter your bot client id and token and restart server"    
end

if File.exists?("char.json") != true
    File.open("char.json","w+") do |char|
        temp = Hash.new
        File.write(char,temp)
    end
    puts "New char.json file created, please enter party members"
end    

Dotenv.load
PREFIX = ENV['PREFIX']
TOKEN = ENV['TOKEN']
CLIENT_ID = ENV['CLIENT_ID']
SECRET = ENV['SECRET']



$bot = Discordrb::Commands::CommandBot.new token: TOKEN, client_id: CLIENT_ID, prefix: PREFIX
$bot.include! Oneshot
$bot.include! Logic
$bot.run(true)




