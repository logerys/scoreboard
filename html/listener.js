var visable = false;
var currentPage = 1;
let switchBlocked = false
$(function () {
  var currentPage = 1;
  function mycomparator (a, b) {
    return parseInt(a.id, 10) - parseInt(b.id, 10);
  }
  window.addEventListener('message', function (event) {

    switch (event.data.action) {
      case 'toggle':
        if (visable) {
          if ($(".player-list-2").children(".table-item").length > 0) {
            $('.page-switcher').css("display", "unset")
          } else {
            $('.page-switcher').css("display", "none")
          }
          $(".scoreboard").fadeIn(400);
        } else {
          $(".scoreboard").fadeOut(200);
        }

        visable = !visable;
        break;
      case 'nextpage':
        if (!switchBlocked) {
          if (currentPage >= 1 && !visable && $(`.player-list-${currentPage + 1}`).children(".table-item").length > 0) {
            switchBlocked = true
            $(`.player-list-${currentPage}`).fadeOut(400, function () {
              currentPage++;
              $(`.player-list-${currentPage}`).fadeIn(100);
            })
            $(`#switcher-${currentPage}`).removeClass('active');
            $(`#switcher-${currentPage + 1}`).addClass('active');
            setTimeout(() => {
              switchBlocked = false
            }, 500)
          }
        }
        break;
      case 'prevpage':
        if (!switchBlocked) {
          if (currentPage !== 1 && !visable) {
            switchBlocked = true
            $(`.player-list-${currentPage}`).fadeOut(400, function () {
              currentPage--;
              $(`.player-list-${currentPage}`).fadeIn(100);
            });
            setTimeout(() => {
              switchBlocked = false
            }, 500)
            $(`#switcher-${currentPage}`).removeClass('active');
            $(`#switcher-${currentPage - 1}`).addClass('active');

          }
        }
        break;
      case 'close':
        $(".scoreboard").fadeOut(200);
        visable = false;
        break;
      case 'updatePlayerList':
        $('.player-list-1').empty();
        $('.player-list-2').empty();
        $('.player-list-3').empty();
        $('.player-list-4').empty();
        $('.player-list-5').empty();
        $('.player-list-6').empty();
        $('.player-list-7').empty();
        $('.player-list-8').empty();

        function capitalize (s) {
          return s && s[0].toUpperCase() + s.slice(1);
        }
        var showed = false;
        $('#player-count').text(event.data.players.length + "/128")
        for (var i = 0; i < event.data.players.sort(mycomparator).length; i++) {
          var element = '<div id="id-pid" class="table-item" style="border-left:2px solid pingColor!important;"><div class="player-name-column col-md-12" style="margin-left: 0px!important;">playerid<span class="col-md-6 pull-right" id="player-name">playername</span></div></div>';
          var arrayPlayers = JSON.parse(event.data.players.sort()[i]);
          var playerPingColor = null;
          if (arrayPlayers['ping'] >= 1 && arrayPlayers['ping'] <= 80) {
            playerPingColor = 'green';
          } else if (arrayPlayers['ping'] >= 81 && arrayPlayers['ping'] <= 105) {
            playerPingColor = 'yellow';
          } else {
            playerPingColor = 'red';
          }
          var username = arrayPlayers['name'];
          if (username.length > 18) {
            username = username.substring(0, 18) + ".."
          }
          element = element.replace('playerid', arrayPlayers['id']);
          element = element.replace('pid', arrayPlayers['id']);
          element = element.replace('playername', username);
          element = element.replace('pingColor', playerPingColor);
          if (i <= 59) {
            $(".player-list-1").append(element);
          } else {
            let list = ~~(i / 59) + 1;
            $(`.player-list-${list}`).append(element);
          }
        }

        break;

      case 'updatePing':
        updatePing(event.data.players);
        break;

      case 'updateServerInfo':
        if (event.data.maxPlayers) {
          $('#max_players').html(event.data.maxPlayers);
        }

        if (event.data.playTime) {
          $('#play_time').html(event.data.playTime);
        }

        break;

      default:
        console.log('scoreboard: unknown action!');
        break;
    }
  }, false);
});

function applyPingColor () {
  $('.player-list-1 tr').each(function () {
    $(this).find('td:nth-child(3),td:nth-child(6)').each(function () {
      var ping = $(this).html();
      var color = 'green';

      if (ping > 60 && ping < 85) {
        color = 'orange';
      } else if (ping >= 86) {
        color = 'red';
      }

      $(this).css('color', color);
    });

  });
}

function updatePing (players) {

  jQuery.each(players, function (index, element) {
    if (element != null) {
      var color = 'green';
      if (element.ping > 60 && element.ping < 85) {
        color = 'orange';
      } else if (element.ping >= 86) {
        color = 'red';
      }
      $('#id-' + element.id).css('border-left', '2 px solid ' + color)
    }
  });
}

function sortPlayerList () {
  var table = $('#playerlist'),
    rows = $('tr:not(.heading)', table);

  rows.sort(function (a, b) {

    var keyA = $('td', a).eq(1).html();
    var keyB = $('td', b).eq(1).html();

    return (keyA - keyB);
  });

  rows.each(function (index, row) {
    table.append(row);
  });
}

