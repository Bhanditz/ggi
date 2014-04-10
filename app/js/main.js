//:javascript
  $(function() {
    $("#search_term").autocomplete({
      source: function( request, response ) {
        $.ajax({
          url: "/autocomplete",
          dataType: "jsonp",
          data: {
            search_term: request.term,
            batch_size: 10
          },
          success: function( data ) {
            response( $.map( data, function( item ) {
              return { value: item }
            }));
          },
        });
      },
      minLength: 1,
      select: function(event, ui) {
        $("#search_term").val(ui.item.label);
        $("#search_form").submit();
      },
    });
  });

