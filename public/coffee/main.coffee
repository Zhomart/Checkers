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

  redraw_pieces = (board) ->
    $('.piece').remove()

    $.chess.board = board

    for i in [0..7]
      for j in [0..7]
        piece = board[i][j]
        if piece > 0
          color = if piece == 1 then 'white' else 'black'
          # console.log piece, color
          $(".checkers").append $("<div>",
            class: "piece #{color}"
            "data-number" : piece
            style: "left: #{5+60*j}px; top: #{5+60*i}px"
          )

  redraw_turn_info = ->
    $('#player_turn').removeClass 'btn-danger'
    $('#player_turn').removeClass 'btn-info'
    if $.chess.my_turn
      $('#player_turn').addClass 'btn-info'
      $('#player_turn').html 'your turn'
    else
      $('#player_turn').addClass 'btn-danger'
      $('#player_turn').html "opponent's turn"

  start_game = ->
    $('.modal').modal 'hide'

    initBoard()

    $.get '/game_info', {user_id: $.chess.user._id, game_id: $.chess.game_id}, (data) ->
      data = $.parseJSON data

      $.chess.my_turn = data.current_player == $.chess.number

      redraw_pieces data.board
      redraw_turn_info()

      if $.chess.my_turn
        enableDragging()
      else
        wait_for_opponents_turn()

      $('#player_name').html $.chess.user.name
      $('#opponent_name').html $.chess.opponent.name

      $('#play_game').show('')

  disableDragging = ->
    $.chess.my_turn = false

  enableDragging = ->
    $.chess.my_turn = true

  get_xy = ($piece) ->
    mx = $piece.offset().left - $('.checkers').offset().left
    my = $piece.offset().top - $('.checkers').offset().top

    ind_x = Math.floor(mx / $.chess.cell_size)
    ind_y = Math.floor(my / $.chess.cell_size)

    return [ind_x, ind_y]

  piece_exists  = ([x, y]) ->
    return $.chess.board[y][x] > 0

  possible_to_go = (old_state, new_state) ->
    [x, y] = old_state
    [wx, wy] = new_state
    return false if piece_exists(new_state)
    return true if x - 1 == wx and y - 1 == wy
    return true if x + 1 == wx and y - 1 == wy
    return false

  highlight_available_cells = (highlight, $piece) ->
    if not highlight
      $('.cell').removeClass('highlight')
    else
      [x, y] = get_xy $piece
      return if y == 0
      if possible_to_go([x, y], [x - 1, y - 1])
        n = (y - 1)*8 + x - 1
        $(".cell:nth(#{n})").addClass('highlight')
      if possible_to_go([x, y], [x + 1, y - 1])
        n = (y - 1)*8 + x + 1
        $(".cell:nth(#{n})").addClass('highlight')

  wait_for_opponents_turn = ->
    $.get '/wait_for_opponents_turn', { game_id: $.chess.game_id, user_id: $.chess.user._id }, (data) ->
      data = $.parseJSON data
      if data.result == 'ok'
        enableDragging()
        redraw_turn_info()
        redraw_pieces(data.board)
      else
        alert(data.message)

  initDragging = ->
    $("body").on "mousemove", (e) ->
      if $.chess.dragging
        mx = e.pageX - $.chess.dragging.parent().offset().left
        my = e.pageY - $.chess.dragging.parent().offset().top

        ind_x = Math.floor(mx / $.chess.cell_size)
        ind_y = Math.floor(my / $.chess.cell_size)
        ind_x = Math.max(Math.min(ind_x, 7), 0)
        ind_y = Math.max(Math.min(ind_y, 7), 0)

        back = false # $.chess.old_state[0] == ind_x and $.chess.old_state[1] == ind_y
        return if not possible_to_go($.chess.old_state, [ind_x, ind_y]) and not back

        left = ind_x * $.chess.cell_size + $.chess.cell_size * 0.1
        top = ind_y * $.chess.cell_size + $.chess.cell_size * 0.1
        left += $.chess.dragging.parent().offset().left
        top += $.chess.dragging.parent().offset().top

        $.chess.dragging.offset
          top: top
          left: left

    $(document.body).on "mousedown", ".piece", (e) ->
      e.preventDefault()
      piece_number = parseInt $(this).attr('data-number')
      if $.chess.my_turn == true
        if piece_number == $.chess.number
          $.chess.old_state = get_xy($(e.target))
          highlight_available_cells(true, $(e.target))
          $.chess.dragging = $(e.target)
      # $.chess.old_state = get_xy($(e.target))
      # highlight_available_cells(true, $(e.target))
      # $.chess.dragging = $(e.target)
      return false

    $(document.body).on "mouseup", (e) ->
      highlight_available_cells(false)
      if $.chess.dragging != null
        piece_old = $.chess.old_state
        piece_new = get_xy $.chess.dragging

        return if piece_old[0] == piece_new[0] and piece_old[1] == piece_new[1]

        disableDragging()
        redraw_turn_info()

        $.get '/turn_done', {old: piece_old, "new" : piece_new, game_id: $.chess.game_id, user_id: $.chess.user._id}, (data) ->
          data = $.parseJSON data
          if data.result == 'ok'
            redraw_pieces(data.board)
            wait_for_opponents_turn()
          else
            alert(data.message)

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

  # $('#play_game').show()

  # $(".checkers").append $("<div>",
  #   class: "piece black"
  #   style: "left: #{5+60*4}px; top: #{5+60*2}px"
  #   "data-number" : -1
  # )

  initDragging()

  # $(".checkers").append $("<div>",
  #   class: "piece white"
  #   style: "left: 5px; top: 5px"
  # )
  # $(".checkers").append $("<div>",
  #   class: "piece black"
  #   style: "left: 65px; top: 5px"
  # )
