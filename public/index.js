
let char_hash
let party
let initiative
var refInterval = window.setInterval('update()', 5000);
var refInterval2 = window.setInterval('start()', 5000);


function start() {

  $("#stats").fadeOut(1000)
  $("#skills").fadeOut(1000)

  $("#1").fadeOut(1000)
  $("#2").fadeOut(1000)
  $("#3").fadeOut(1000)
  $("#4").fadeOut(1000)
  $("#5").fadeOut(1000)
  $("#1-1").fadeOut(1000)
  $("#1-2").fadeOut(1000)
  $("#1-3").fadeOut(1000)
  $("#1-4").fadeOut(1000)
  $("#1-5").fadeOut(1000)

  $.post("/initiative", function(data,status){
    initiative = data
    console.log(status)
    state = status
  });
  $.post("/chars", function(data){
    char_hash = data
  });
  $.post("/party", function(data){
    party = data  
  });

  if (initiative != {}) {
    clearInterval(refInterval2)
    $("#stats").fadeIn(1000)
    $("#skills").fadeIn(1000)
    iter = Object.keys(party["members1"])
    let i = 1
    for (const char of iter){
  
      console.log(char)
      console.log(initiative)
  
      $(`#member${i}`).text(char_hash[char]["name"])
      $(`#member${i}_hp`).text(`HP: ${initiative[char]["hp"]}/${char_hash[char]["hp"]}`)
      $(`#member${i}_hp_bar`).attr({'value':initiative[char]["hp"],'max':char_hash[char]["hp"]})
      $(`#member${i}_h_p`).text(`H-P: ${initiative[char]["h_p"]}/${char_hash[char]["h_p_max"]}`)
      $(`#member${i}_h_p_bar`).attr({'value':initiative[char]["h_p"],'max':char_hash[char]["h_p_max"]})
      $(`#member${i}_ap`).text(`AP: ${initiative[char]["ap"]}/${char_hash[char]["ap"]}`)
      $(`#member${i}_ap_bar`).attr({'value':initiative[char]["ap"],'max':char_hash[char]["ap"]})
  
      
      $(`#1-${i}`).fadeIn(1000)
      
      let skills = Object.keys(initiative[char]["skills"])
      let response = ""
      console.log(skills)
      for(const skill of skills){
        console.log(initiative[char]["skills"][skill].ap)
        
        response +=`<p></p><strong style="font-size: 20px">${skill}:</strong><P>Damage: ${initiative[char]["skills"][skill]["damage"]}</p><p>H-Damage: ${initiative[char]["skills"][skill]["h-damage"]}</p><p>AP Cost: ${initiative[char]["skills"][skill].ap_cost}</p><p>E-Type: ${initiative[char]["skills"][skill].effect_type} </p><p>E-Damage: ${initiative[char]["skills"][skill].effect_damage}</p>`
        
      }
      $(`#skill_list${i}`).html(response)
      $(`#${i}`).fadeIn(1000)
      i++
      
    }
  }
  

}

function update() {

  
  let state = ""
  $.post("/initiative", function(data,status){
    initiative = data
    console.log(status)
    state = status
  });
  $.post("/chars", function(data){
    char_hash = data
  });
  $.post("/party", function(data){
    party = data  
  });
  iter = Object.keys(party["members1"])
  let i = 1
  for (const char of iter){

    console.log(char)
    console.log(initiative)

    $(`#member${i}`).text(char_hash[char]["name"])
    $(`#member${i}_hp`).text(`HP: ${initiative[char]["hp"]}/${char_hash[char]["hp"]}`)
    $(`#member${i}_hp_bar`).attr({'value':initiative[char]["hp"],'max':char_hash[char]["hp"]})
    $(`#member${i}_h_p`).text(`H-P: ${initiative[char]["h_p"]}/${char_hash[char]["h_p_max"]}`)
    $(`#member${i}_h_p_bar`).attr({'value':initiative[char]["h_p"],'max':char_hash[char]["h_p_max"]})
    $(`#member${i}_ap`).text(`AP: ${initiative[char]["ap"]}/${char_hash[char]["ap"]}`)
    $(`#member${i}_ap_bar`).attr({'value':initiative[char]["ap"],'max':char_hash[char]["ap"]})

    if(initiative[char]["hp"] <= 0){
      $(`#1-${i}`).css('background-color', 'red')

    }

    $(`#1-${i}`).fadeIn(1000)


    
    let skills = Object.keys(initiative[char]["skills"])
    let response = ""
    console.log(skills)
    for(const skill of skills){
      console.log(initiative[char]["skills"][skill].ap)
      
      response +=`<p></p><strong style="font-size: 20px">${skill}:</strong><P>Damage: ${initiative[char]["skills"][skill]["damage"]}</p><p>H-Damage: ${initiative[char]["skills"][skill]["h-damage"]}</p><p>AP Cost: ${initiative[char]["skills"][skill].ap_cost}</p><p>E-Type: ${initiative[char]["skills"][skill].effect_type} </p><p>E-Damage: ${initiative[char]["skills"][skill].effect_damage}</p>`
      
    }
    $(`#skill_list${i}`).html(response)
    $(`#${i}`).fadeIn(1000)
    i++

  }

}

$(document).ready(function() {
  
  start()
  update()

  

  
    

  
});


  





