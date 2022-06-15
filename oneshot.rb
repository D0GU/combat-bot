
require "discordrb"

$initiative_final = {}
$initiative_order = []

def get_id(name)
    char_hash = JSON.parse(file.read("char.json"))
    id = char_hash.detect{|client| client.last['name'] == temp[i]}
    if id != nil
        return id
    else
        return "err"
    end       
end

module Oneshot
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    command :add_char do |event,name,strength,defence,dexerity,hp,h_p,ap|
        char= File.read("char.json")
        char_hash = JSON.parse(char)
        id =  char_hash.detect{|client| client.last['name'] == name}
        if id == nil
            char_hash[Time.now.to_f] = {"name" => name, "defence" => defence.to_f, "strength" => strength.to_f, "dexterity" => dexerity.to_f, "hp" => hp.to_f, "h_p" => 0, "h_p_max" => h_p.to_f, "ap" => ap.to_f, "skills" => {}, "debuffs" => {} }
            p JSON.dump(char_hash)
            File.write("char.json",JSON.dump(char_hash))
            event.respond("Character #{name} added!")
        else
            return "Character with name #{name} already exists"
        end
    end

    command :add_skill do |event,name,damage,h_damage,ap_cost,effect_type="none",effect_damage=0,*skill_name|
        puts name
        char= File.read("char.json")
        char_hash = JSON.parse(char)
        skill = skill_name.join(" ")
        id =  char_hash.detect{|client| client.last['name'] == name}
        puts id[0]
        if id != nil
            char_hash[id[0]]["skills"][skill] = {"damage" => damage.to_f, "h-damage" => h_damage.to_f,"ap_cost" => ap_cost.to_f, "effect_type" => effect_type, "effect_damage" => effect_damage.to_f}
            File.write("char.json",JSON.dump(char_hash))
            return "Skill #{skill} added!"
        else
            return "Character with name #{name} does not exist"
        end

    end

    command :edit_stat do |event,name,stat,op,value|
        id = get_id(name)
        char_hash = JSON.parse(File.read("char.json"))

        if op == "add"
            $initiative_final[id][stat] += value.to_f
        elsif op == "subtract"
            $initiative_final[id][stat] -= value.to_f
        elsif op == "set"
            $initiative_final[id][stat] = value.to_f
        end
        
    end

    command :remove_skill do |event,name,*skill|
        id = get_id(name)
        char_hash = JSON.parse(File.read("char.json"))
        skill_name = skill.join(" ")
        puts skill_name
        char_hash[id]["skills"].delete(skill_name)

        File.write("char.json",JSON.dump(char_hash))

        event.respond "Skill removed!"
    end

    command :remove_character do |event,name|
        id = get_id(name)
        char_hash = JSON.parse(File.read("char.json"))

        char_hash.delete(id)

        File.write("char.json",JSON.dump(char_hash))

        event.respond "Character removed!"
    end

    command :view_skills do |event,name|
        id = get_id(name)
        char_hash = JSON.parse(File.read("char.json"))
        response = "```#{name}'s Skills:\n"
        for item in char_hash[id]["skills"].keys
            response.concat("\n#{item}:\n Damage: #{char_hash[id]["skills"][item]["damage"]}\n H-Damage: #{char_hash[id]["skills"][item]["h-damage"]}\n AP Cost: #{char_hash[id]["skills"][item]["ap_cost"]}\n Effect Type: #{char_hash[id]["skills"][item]["effect_type"]}\n Effect Damage: #{char_hash[id]["skills"][item]["effect_damage"]}\n")
        end
        response.concat("```")
        event.respond response
        
    end

    command :party_status do |event|
        response = "```Party Status:"
        for item in $initiative_final.keys
            response.concat("\n\n#{$initiative_final[item]["name"]}:\n HP: #{$initiative_final[item]["hp"]}\n H-P: #{$initiative_final[item]["h_p"]}\n AP: #{$initiative_final[item]["ap"]}")
        end
        response.concat("```")
        event.respond response
    end


    command :set_party1 do |event,mem1,mem2="",mem3="",mem4="",mem5=""|
        party = File.read("party.json")
        party_hash = JSON.parse(party)
        char= File.read("char.json")
        char_hash = JSON.parse(char)
        temp = [mem1,mem2,mem3,mem4,mem5]
        party_hash["members1"] = {}
        5.times do |i|
            if temp[i] != ""
                id = char_hash.detect{|client| client.last['name'] == temp[i]}
                puts id
                if id != nil
                    if party_hash["members1"].has_key? id[0] 
                        return "Multiple of the same character in one party not allowed"
                    else
                        party_hash["members1"][id[0]] = temp[i]
                        
                    end
                else    
                    return "Wrong name entered, please check to make sure all names are spelled correctly"
                end 
            else
                # do nothing 
            end
        end
        File.write("party.json",JSON.dump(party_hash))
        event.respond "New party created!"
    end



    command :set_party2 do |event,mem1,mem2="",mem3="",mem4="",mem5=""|
        party = File.read("party.json")
        party_hash = JSON.parse(party)
        char= File.read("char.json")
        char_hash = JSON.parse(char)
        temp = [mem1,mem2,mem3,mem4,mem5]
        party_hash["members2"] = {}
        5.times do |i|
            if temp[i] != ""
                id = char_hash.detect{|client| client.last['name'] == temp[i]}
                puts id
                if id != nil
                    if party_hash["members2"].has_key? id[0]
                        return "Multiple of the same character in one party not allowed"
                    else
                        party_hash["members2"][id[0]] = temp[i]
                        
                    end
                else    
                    return "Wrong name entered, please check to make sure all names are spelled correctly"
                end 
            else
                # do nothing 
            end
        end
        File.write("party.json",JSON.dump(party_hash))
        event.respond "New party created!"
    end

    command :party1 do |event|
        party = JSON.parse(File.read("party.json"))
        response_temp = "```Current party members:\n"
        for item in party["members1"].keys
            response_temp.concat "\n#{party["members1"][item]}\n"
        end
        response_temp.concat("```")
        event.respond response_temp
    end

    command :party2 do |event|
        party = JSON.parse(File.read("party.json"))
        response_temp = "```Current party members:\n"
        for item in party["members2"].keys
            puts item
            response_temp.concat "\n#{party["members2"][item]}\n"
        end
        response_temp.concat("```")
        event.respond response_temp
    end
    
    command :characters do |event|
        char = File.read("char.json")
        char_hash = JSON.parse(char)
        response_str = "```Available Characters:\n\n"
        for mem in char_hash.keys
            puts mem
            response_str.concat("#{char_hash[mem]["name"]}:\n ID: #{mem}\n Strength: #{char_hash[mem]["strength"]}\n Defence: #{char_hash[mem]["defence"]}\n Dexterity: #{char_hash[mem]["dexterity"]}\n HP: #{char_hash[mem]["hp"]}\n H-P: #{char_hash[mem]['h_p']}\n AP: #{char_hash[mem]['ap']}\n\n")
        end
        response_str.concat("```")
        event.respond response_str
    end

    command :create_initiative do |event,*chars|
        $actions_taken["primary"] = 0
        $actions_taken["secondary"] = 0
        char_hash = JSON.parse(File.read("char.json"))
        party = JSON.parse(File.read("party.json"))
        friendlies = {}
        enemies = {}
        for item in chars
            id = char_hash.detect{|client| client.last['name'] == item}
            enemies[id[0]] = id[1]
            enemies[id[0]]["alignment"] = "foe" 
        end
        for item in party["members1"].keys
            id = char_hash.detect{|client| client.last['name'] == party["members1"][item]}
            friendlies[id[0]] = id[1]
            friendlies[id[0]]["alignment"] = "friend" 
        end
        temp = friendlies.merge(enemies)
        list_initiative= temp
        response = "```Initiative list:\n"
        temp_array = []
        for key in list_initiative.keys
            temp_array.push(key)
        end

        $initiative_final = list_initiative
        $initiative_order = temp_array.shuffle
        i=0
        for item in $initiative_order
            response.concat("\n#{i+1}: #{char_hash[item]["name"]}")
            i+=1
        end
        response.concat "```"
        event.respond response
    end

    command :initiative do |event|
        char_hash = JSON.parse(File.read("char.json"))
        response = "```Initiative list:\n"
        i=0
        for item in $initiative_order
            response.concat("\n#{i+1}: #{char_hash[item]["name"]}")
            i+=1
        end
        response.concat "```"
        event.respond response
    end

    command :reset_initiative do |event|
        $initiative_final = {}
        $initiative_order = []
        $actions_taken["primary"] = 0
        $actions_taken["secondary"] = 0

    end

    command :set_turn do |event,index|
        $initiative_order = index
    end

    command :status_viewer do |event|
        event.respond "Access the status viewer here:\n http://107.152.43.59:8444/combat_bot"
    end
end