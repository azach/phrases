$(function() {
  var phraseUrl = '/api/phrase.json';

  $('#get-phrase').click(function() {
    $(this).attr('disabled', 'disabled');

    $.getJSON(phraseUrl, function(data) {
      $('#current-phrase').text(data.phrase);
      $('#get-phrase').removeAttr('disabled');
    });
  });

  $('#add-phrase').click(function() {
    var newPhrase = $('#add-phrase-value').val();
    if (newPhrase === "") { return; }

    $(this).attr('disabled', 'disabled');

    $.ajax({
      type: 'POST',
      dataType: 'json',
      url: phraseUrl,
      data: {phrase: newPhrase},
      success: function(data) {
        $('#add-phrase').removeAttr('disabled');
        if (data.phrase) {
          $('#phrase-added').text("'" + data.phrase + "' was successfully added");
        } else {
          $('#phrase-added').text('There was an error :(');
        }
      }
    });
  });

  $('#find-phrase').click(function() {
    var searchPhrase = $('#find-phrase-value').val();
    if (searchPhrase === "") { return; }

    $(this).attr('disabled', 'disabled');

    $.getJSON(phraseUrl, {search: searchPhrase}, function(data) {
      $('#find-phrase').removeAttr('disabled');
      if (data.phrase) {
        $('#phrase-status').text('Your phrase exists!');
      } else {
        $('#phrase-status').text('Your phrase does not exist');
      }
    });
  });
});
