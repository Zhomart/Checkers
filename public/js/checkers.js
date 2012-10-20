$(function(){
  $.chess = $.chess || {};
  $.chess.dragging = null;

  $.chess.cell_size = 60;
  $.chess.width = $.chess.cell_size * 8;
  $.chess.height = $.chess.cell_size * 8;

  var initBoard = function(){
    for (var i=0;i<64;++i)
      $(".checkers").append($("<div>", {
        'class' : 'cell'
      }));
  }

  var initDragging = function(){
    $("body").on("mousemove", function(e){
      if ($.chess.dragging) {
        var mx = e.pageX - $.chess.dragging.parent().offset().left;
        var my = e.pageY - $.chess.dragging.parent().offset().top;

        var ind_x = Math.floor(mx / $.chess.cell_size);
        var ind_y = Math.floor(my / $.chess.cell_size);

        ind_x = Math.max(Math.min(ind_x, 7), 0);
        ind_y = Math.max(Math.min(ind_y, 7), 0);

        var left = ind_x * $.chess.cell_size + $.chess.cell_size*0.1;
        var top  = ind_y * $.chess.cell_size + $.chess.cell_size*0.1;

        left += $.chess.dragging.parent().offset().left;
        top += $.chess.dragging.parent().offset().top;

        $.chess.dragging.offset({
          top: top,
          left: left
        });
      }
    });

    $(document.body).on("mousedown", ".piece", function (e) {
      $.chess.dragging = $(e.target);
    });

    $(document.body).on("mouseup", function (e) {
      $.chess.dragging = null;
    });
  }

  initDragging();

  initBoard();

  var loadBoard = function(){
    $.get('/board', {game_id})

  }

  loadBoard();

  $(".checkers").append($("<div>", {
    'class' : 'piece white',
    'style' : 'left: 5px; top: 5px'
  }));

  $(".checkers").append($("<div>", {
    'class' : 'piece black',
    'style' : 'left: 65px; top: 5px'
  }));



});
