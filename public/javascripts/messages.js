var MessagesUpdate = Class.create({
  // The MessagesUpdate will just sit and wait for juggernaut data to be sent, and will
  // be responsible for updating the page when messages are sent.
  
  messages_element: null,

  initialize: function(messages){
    this.messages_element = $('messages');
    messages = messages.evalJSON();
    console.log(messages);
    messages.each(function(message){
      this.add_to_messages_list(message);
    }.bind(this));
  },

  add_to_messages_list: function(message){
    console.log("Inserting message.");
    this.messages_element.insert(this.message_element_for(message));
  },

  /* <li>
   *   <h3>UserName</h3>
   *   <span>message</span>
   * </li> */
  message_element_for: function(message){
    var li = Builder.node('li', [
               Builder.node('h3', message.from),
               Builder.node('span', message.body)
             ]);
    return li;
  }
});
