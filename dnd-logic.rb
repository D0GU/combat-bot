require "discordrb"
require 'discordrb/webhooks'
require "json"

$current_turn = 0
$actions_taken = {"primary" => 0, "secondary" => 0}


def ap_regen()
    char_hash = JSON.parse(File.read("char.json"))
    for char in $initiative_final.keys
        $initiative_final[char]["ap"] = ($initiative_final[char]["ap"] + 15).clamp(0,char_hash[char]["ap"])
    end
end

def initiative_tracker(event,type)
    puts $actions_taken
    if type == "primary"
        $actions_taken["primary"] += 1
    elsif type == "secondary"
        $actions_taken["secondary"] += 1
    end

    if $actions_taken["primary"] + $actions_taken["secondary"] == 2

        $current_turn +=1
        

        if $current_turn >= $initiative_order.length
            $actions_taken["primary"] = 0
            $actions_taken["secondary"] = 0
            $current_turn = 0
            ap_regen()
            event.respond "It's #{$initiative_final[$initiative_order[$current_turn]]["name"]}'s turn!"
        else
            $actions_taken["primary"] = 0
            $actions_taken["secondary"] = 0
            event.respond "It's #{$initiative_final[$initiative_order[$current_turn]]["name"]}'s turn!"
        end
    end
end

def h_p_roll(char1,char2)
    char_hash = JSON.parse(File.read("char.json"))
    attacker = get_id(char1)
    reciever = get_id(char2)
    required = 20 - ($initiative_final[reciever]["h_p"] / char_hash[reciever]["h_p_max"]) * 20
    rolled = rand(20)
    if rolled < required
        return false
    elsif rolled >= required
        return true
    end
end

def get_id(name)
    char_hash = JSON.parse(File.read("char.json"))
    id = char_hash.detect{|client| client.last['name'] == name}
    if id != nil
        return id[0]
    else
        return "err"
    end
end

def combat_roll(char1,action,char2)
    # effect_types=("none","Shock","Fire","Ice")
    char_hash = JSON.parse(File.read("char.json"))
    attacker = get_id(char1)
    reciever = get_id(char2)
    if $initiative_final[attacker]["ap"] < $initiative_final[attacker]["skills"][action]["ap_cost"]
        return [0,0,"impossible"]
    
    else
        attack_roll = rand(20)
        required = (char_hash[reciever]["dexterity"]/100) * 20
        defence_multiplier = ($initiative_final[reciever]["defence"]/100.0)
        attack_modifier = ($initiative_final[attacker]["skills"][action]["damage"] + $initiative_final[attacker]["skills"][action]["effect_damage"])
        if $initiative_final.key?(attacker) && $initiative_final.key?(reciever)
            if attack_roll >= required
                final_damage =  attack_modifier - defence_multiplier * attack_modifier
                final_h_damage = $initiative_final[attacker]["skills"][action]["h-damage"]

                new_hp = ($initiative_final[reciever]["hp"] - final_damage).clamp(0,char_hash[reciever]["hp"])
                new_h_p = ($initiative_final[reciever]["h_p"] + final_h_damage).clamp(0,char_hash[reciever]["h_p_max"])
                new_ap = ($initiative_final[attacker]["ap"] - $initiative_final[attacker]["skills"][action]["ap_cost"]).clamp(0,char_hash[reciever]["ap"])
                $initiative_final[reciever]["hp"] = new_hp
                $initiative_final[reciever]["h_p"] = new_h_p
                $initiative_final[attacker]["ap"] = new_ap
                if new_hp <=0
                    if new_h_p >= char_hash[reciever]["h_p_max"]
                        return [final_damage,final_h_damage,"fainted","h_p_2"]
                    else
                        return [final_damage,final_h_damage,"fainted","h_p_1"]
                    end
                else
                    if new_h_p >= char_hash[reciever]["h_p_max"]
                        return [final_damage,final_h_damage,"alive","h_p_2"]
                    else
                        return [final_damage,final_h_damage,"alive","h_p_1"]
                    end
                end
            else
                return [final_damage,final_h_damage,"failed","h_p_1"]
            end
        else
            return "err"
        end
    end
 end

module Logic
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer
    

    



    command :skill do |event,char1,char2,*action|
        event.message.delete 
        char_hash = JSON.parse(File.read("char.json"))
        attacker = get_id(char1)
        reciever = get_id(char2)
        status = combat_roll(char1,action.join(" "),char2)
        puts status
        if status == "err"
            event.respond "something bad happened"

        elsif status[2] == "failed"

            event.respond "Attack missed"
            
            initiative_tracker(event,"primary")



        elsif status[2] == "alive"
            
            event.respond "Attack connected, #{$initiative_final[reciever]["name"]} has taken #{status[0]} HP damage and #{status[1]} H-P damage"

            initiative_tracker(event,"primary")


        elsif status[2] =="fainted"

            event.respond "Attack connected, #{$initiative_final[reciever]["name"]} has taken #{status[0]} HP damage and #{status[1]} H-P damage"
            event.respond "#{$initiative_final[reciever]["name"]} has fainted"

            initiative_tracker(event,"primary")

        elsif status[2] =="impossible"

            event.respond "Not enough AP for skill"
            
        end
    
    end


    command :action do |event,char1,char2|
        event.message.delete 
        char_hash = JSON.parse(File.read("char.json"))
        attacker = get_id(char1)
        reciever = get_id(char2)
        
        event.respond "#{$initiative_final[attacker]["name"]} has initiated an action on #{$initiative_final[reciever]["name"]}!"

        initiative_tracker(event,"secondary")
  
            
    end

    command :skip do |event|
        
        event.respond "#{$initiative_final[attacker]["name"]} has passed on their turn!"

        $actions_taken["primary"] = 1
        $actions_taken["secondary"] = 0

        initiative_tracker(event,"secondary")
  
            
    end

    command :h_action do |event,char1,char2|
        event.message.delete 
        char_hash = JSON.parse(File.read("char.json"))
        attacker = get_id(char1)
        reciever = get_id(char2)
        
        result = h_p_roll(char1,char2)

        if result
            event.respond "#{$initiative_final[attacker]["name"]} has initiated an h-action on #{$initiative_final[reciever]["name"]}!"
        else
            event.respond "H-Action failed!"
        end

  
            
    end


end 
