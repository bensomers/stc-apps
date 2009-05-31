Event.addBehavior.reassignAfterAjax = true;
Event.addBehavior({
  'a.sign_up_link': Remote.Link,
  'a.sign_in_link': Remote.Link,
  'a.late_sign_in_link': Remote.Link,
  '#date_select': DateSelector,

  '#pref_link:click' : function () {
   this.hide();
   Effect.BlindDown('checkbox_div', {duration: 0.2}); 
   $('cancel_pref_link').show();
  },
  '#cancel_pref_link:click': function () {
   $('pref_link').show();
   Effect.BlindUp('checkbox_div', {duration: 0.2});      
  }
  });  
