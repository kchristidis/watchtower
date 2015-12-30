//= require browser_timezone_rails/application.js
//= require jquery
//= require jquery_ujs
//= require tipsy
//= require bootstrap-sprockets
//= require turbolinks
//= require d3
//= require_tree .

$(document).on("page:load", function() {
  Global = {
    show_item: function(target) {
      $(target).hide();
      $(target).parent('div').find('.to-show').show();
    },
    hide_item: function(target){
      $(target).parent('.to-show').hide();
      $(target).parent('.to-show').parent('div').find('.btn-show').show();
    }
  };

  $('.btn-show').click(function(){
    Global.show_item(this);
  });
  $('.btn-hide').click(function(){
    Global.hide_item(this);
  });
});
