$(function(){
  for (var i=0;i<64;++i)
    $(".checkers").append($("<div>", {
      'class' : 'cell',
      html: '&nbsp;'
    }));

});
