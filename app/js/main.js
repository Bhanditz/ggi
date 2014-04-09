$(function() {
  $("#search_term").autocomplete({
    source: function( request, response ) {
      $.ajax({
        url: "/autocomplete.json",
        dataType: "jsonp",
        data: {
          search_term: request.search_term,
          batch_size: 10
        },
        success: function( data ) {
          response( $.map( data, function( item ) {
            return { value: item.scientific_name }
          }));
        },
      });
    },
    minLength: 1,
    select: function(event, ui) {
      $("#search_term").val(ui.item.label);
      $(".search_form").submit();
    },
  });
});
