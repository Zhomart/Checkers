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

  update_game_list = (all = false) ->
    $.get "/game_list", {all: all, user_id: $.chess.user._id}, (games) ->
      $('#game_list').html ''

      for game in games
        div = $('<div>',
          class: 'game',
          "data-id" : game._id
        )

        $("<span>",
          class: "label label-inverse"
          html: game.user.name
        ).appendTo div

        $('<span>',
          class: 'label',
          html: game.title
        ).appendTo div

        $('#game_list').append div

      update_game_list()

  select_game = ->
    $('#select_game').modal {backdrop: false}

    update_game_list(true)

    $('#new_game').on 'hidden', ->
      $('#select_game').modal {backdrop: false}

    $('#new_game_button').click ->
      $('#select_game').modal 'hide'
      $('#new_game').modal {show: true}

    $('#create_game_button').click ->
      gametitle = $('#gametitle').val()
      if gametitle.length < 3
        return alert('Title is too short')

      $.post "/new_game", {user_id: $.chess.user._id, title: gametitle}, (data) ->
        data = $.parseJSON data
        if data.result == "ok"
          console.log data
        else
          alert(data.message)

  sign_in = ->
    $('#sign_in').modal {backdrop: false}

    $('#sign_in_button').click ->
      username = $('#username').val()
      $.post "/sign_in", {username: username}, (data) ->
        data = $.parseJSON data
        if data.result == "ok"
          $.chess.user = data.user
          $('#sign_in').modal 'hide'
          select_game()
        else
          alert(data.message)

  sign_in()

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
