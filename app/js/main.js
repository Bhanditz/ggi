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
              return { value: item.value, label: item.label }
            }));
          },
        });
      },
      minLength: 1,
      focus: function( event, ui ) {
        $("#search_term").val( ui.item.label );
        return false;
      },
      select: function(event, ui) {
        $("#search_term").val(ui.item.value);
        $("#search_form").submit();
      }
    });
  });

