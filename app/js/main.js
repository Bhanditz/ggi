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
    addPlusesToTaxonomy();
  });

  var addPlusesToTaxonomy = function() {
    $('.hierarchy--root li').append($('<a/>', { class: 'plus', href: '#' }).prepend(' +'));
    $('.hierarchy--root li a.plus').on('click', function(e) {
      e.preventDefault();
      var taxon_id = $(this).closest('li').data('taxon-id');
      loadTaxonomy(taxon_id);
    });
  };

  var loadTaxonomy = function(taxon_id) {
    $.ajax({
      url: '/api/taxonomy/' + taxon_id,
      dataType: 'html',
      success: function(html) {
        $('.hierarchy--root').html(html);
        addPlusesToTaxonomy();
      }
    });
  };
