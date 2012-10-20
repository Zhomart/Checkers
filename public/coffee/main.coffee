$ ->
  $.chess = $.chess or {}
  $.chess.dragging = null

  $.current_user = null
  
  $.chess.cell_size = 60

  $.chess.width = $.chess.cell_size * 8
  $.chess.height = $.chess.cell_size * 8
  
  initBoard = ->
    for i in [1..64]
      $(".checkers").append $("<div>",
        class: "cell"
      )

  initDragging = ->
    $("body").on "mousemove", (e) ->
      if $.chess.dragging
        mx = e.pageX - $.chess.dragging.parent().offset().left
        my = e.pageY - $.chess.dragging.parent().offset().top

        ind_x = Math.floor(mx / $.chess.cell_size)
        ind_y = Math.floor(my / $.chess.cell_size)
        ind_x = Math.max(Math.min(ind_x, 7), 0)
        ind_y = Math.max(Math.min(ind_y, 7), 0)
        
        left = ind_x * $.chess.cell_size + $.chess.cell_size * 0.1
        top = ind_y * $.chess.cell_size + $.chess.cell_size * 0.1
        left += $.chess.dragging.parent().offset().left
        top += $.chess.dragging.parent().offset().top

        $.chess.dragging.offset
          top: top
          left: left

    $(document.body).on "mousedown", ".piece", (e) ->
      $.chess.dragging = $(e.target)

    $(document.body).on "mouseup", (e) ->
      $.chess.dragging = null

  loadBoard = ->
    $.get "/board",
      game_id

  sign_in = ->
    $('#sign_in').modal {backdrop: false}

    $('#sign_in_button').click () ->
      username = $('#username').val()
      $.post "/sign_in", {username: username}, (data) ->
        console.log("data: #{data}")


  sign_in()
  
  # loadBoard()

  # initDragging
  # initBoard


  # $(".checkers").append $("<div>",
  #   class: "piece white"
  #   style: "left: 5px; top: 5px"
  # )
  # $(".checkers").append $("<div>",
  #   class: "piece black"
  #   style: "left: 65px; top: 5px"
  # )
