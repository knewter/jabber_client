var BuddyListUpdate = Class.create({
  // The BuddyListUpdate will just sit and wait for juggernaut data to be sent, and will
  // be responsible for updating the page when presence changes.
  
  buddy_list_element: null,

  initialize: function(people){
    this.buddy_list_element = $('buddy_list');
    people = people.evalJSON();
    console.log(people);
    people.each(function(person){
      this.add_to_buddy_list(person);
    }.bind(this));
  },
  add_to_buddy_list: function(person){
    if(this.element_for(person)){
      console.log("Element exists for " + person[0] + ", updating...");
      this.element_for(person).replace(this.buddy_list_element_for(person));
    }else{
      console.log("Inserting element for " + person[0] + ".");
      this.buddy_list_element.insert(this.buddy_list_element_for(person));
    }
  },
  /* <li class='status' id='user@server.com'>
   *   <h3><a>UserName</a></h3>
   *   <span>message</span>
   * </li> */
  buddy_list_element_for: function(person){
    var li = Builder.node('li', { class: person[1], id: person[0] }, [
               Builder.node('h3', Builder.node('a', { href: '/messages/new?to=' + person[0] }, person[0])),
               Builder.node('span', person[2])
             ]);
    return li;
  },
  // Return the element for this person
  element_for: function(person){
    return $(person[0]);
  }
});
