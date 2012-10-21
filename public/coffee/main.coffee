$ ->

  $.chess = $.chess or {}
  $.chess.dragging = null

  $.current_user = null
  
  $.chess.cell_size = 60

  $.chess.width = $.chess.cell_size * 8
  $.chess.height = $.chess.cell_size * 8

  initModals = ->
    $('#wait_for_opponent').modal {show: false}
    $('#select_game').modal {backdrop: false, show: false}
    $('#new_game').modal {show: false}

    $('#wait_for_opponent').on 'click', '.cancel_game', ->
      $.get '/cancel_game', {game_id: $.chess.game._id}

    $('#new_game').on 'hidden', ->
      $('#select_game').modal 'show'

  initGameStartingLogic = ->
    $('#new_game_button').click ->
      $('.modal').modal 'hide'
      $('#new_game').modal 'show'

    $('#create_game_button').click ->
      gametitle = $('#gametitle').val()
      if gametitle.length < 3
        return alert('Title is too short')

      $.post "/new_game", {user_id: $.chess.user._id, title: gametitle}, (data) ->
        data = $.parseJSON data
        if data.result == "ok"
          $('.modal').modal 'hide'
          $('#wait_for_opponent').modal 'show'
          $.chess.game_id = data.game_id
          $.get '/get_opponent', { user_id: $.chess.user._id, game_id: $.chess.game_id }, (data) ->
            data = $.parseJSON data
            if data.result == 'ok'
              $.chess.opponent = data.opponent
              $.chess.number = data.number
              start_game()
            else
              alert(data.message)
        else
          alert(data.message)

    $('body').on 'click', '.game', ->
      game_id = $(this).attr 'data-id'

      $.get '/start_game', {user_id: $.chess.user._id, game_id: game_id}, (data) ->
        data = $.parseJSON data
        if data.result == 'ok'
          $.chess.game_id = data.game_id
          $.chess.opponent = data.opponent
          $.chess.number = data.number
          start_game()
        else
          alert(data.message)

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
          html: game.username
        ).appendTo div

        $('<span>',
          class: 'label',
          html: game.title
        ).appendTo div

        $('#game_list').append div

      update_game_list()

  sign_in = ->
    $('#sign_in').modal {backdrop: false}

    $('#sign_in_button').click ->
      username = $('#username').val()
      $.post "/sign_in", {username: username}, (data) ->
        data = $.parseJSON data
        if data.result == "ok"
          $.chess.user = data.user

          update_game_list(true)

          $('.modal').modal 'hide'
          $('#select_game').modal 'show'
        else
          alert(data.message)

  redraw_pieces = ->
    $('.piece').remove

    for i in [0..7]
      for j in [0..7]
        piece = $.chess.game.board[i][j]

        if piece > 0
          piece = if piece == 1 then 'white' else 'black'
          $(".checkers").append $("<div>",
            class: "piece #{piece}"
            style: "left: #{5+60*i}px; top: #{5+60*j}px"
          )

  start_game = ->
    $('.modal').modal 'hide'

    initBoard()

    redraw_pieces()

    $('#player_name').html $.chess.user.name
    $('#opponent_name').html $.chess.opponent.name

    $('#play_game').show('')

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

  initBoard = ->
    $(".checkers").html ''
    for i in [1..64]
      $(".checkers").append $("<div>",
        class: "cell"
      )

  initBoard()

  initModals()

  initGameStartingLogic()

  sign_in()

  initDragging()

  # $(".checkers").append $("<div>",
  #   class: "piece white"
  #   style: "left: 5px; top: 5px"
  # )
  # $(".checkers").append $("<div>",
  #   class: "piece black"
  #   style: "left: 65px; top: 5px"
  # )
