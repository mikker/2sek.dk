(function($) {

  var cl = function log() { if (window.console && console.log) { console.log(arguments.length == 1 ? arguments[0] : arguments); } }

  $(function() {

    var inputElm = $("#word_q");
    var resultsElm = $("#results");

    $("#word_search_form").on('submit', function(event) {
      event.preventDefault();
    });

    inputElm.on('keyup', function(event) {
      var input = $(this);
      var key = event.which || event.keyCode;
      if (input.val().length > 0 && [16,17,18,91,27].indexOf(key) == -1) {
        $.ajax({
          url: '/lookup.json',
          data: { q: input.val() },
          success: parseResultTo(resultsElm)
        });
      }
    }).focus();

    $("body").on('keyup', function(event) {
      var key = event.which || event.keyCode;
      if (key == 27) {
        inputElm.val("").focus();
        resultsElm.html("");
      }
    });

    resultsElm.css({top: '' + $("#word_q").outerHeight() + 'px'});

    inputElm.val('test').trigger('keyup');

  });

  function parseResultTo(resultsElm) {
    return function parseResult(data) {
      var words = data.words;
      var listElements = [];
      for(i in words) {
        var obj = words[i];
        var titleElm = $("<h2 />")
          .html(obj.word);
        var defElm = $("<p />")
          .html(obj.definition);
        var liElm = $("<li />")
          .addClass(obj.lang)
          .html(titleElm)
          .append(defElm);
        listElements.push(liElm);
      }
      var listElm = $("<ul />")
        .html(listElements);
      resultsElm.html(listElm);
    };
  };
})(jQuery);
