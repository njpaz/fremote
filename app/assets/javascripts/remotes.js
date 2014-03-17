window['remotes#show'] = function(data) {
  $(document).on('ready', function() {
    var stream = new Stream()
    var remote = new Remote()
    var player = new Player(stream.source, remote)
    var chat = new Chat(stream.source, remote)
    var canvas = new Canvas(stream.source, remote)
    var playlist = new Playlist(stream.source, remote)
    var watcher_list = new WatcherList(stream.source, remote)
  })
}

window['remotes#edit'] = function(data) {
  $(document).on('ready', function() {
    var remote = new Remote()
  })
}

window['remotes#index'] = function(data) {
  window.onload = function() {
    changeWindowHeight()
  }

  window.onresize = function() {
    changeWindowHeight()
  }

  function changeWindowHeight() {
    var windowHeight = $(window).height()
    console.log('changing')
    $('#on_landing').css('padding-top', windowHeight / 3)
  }
}