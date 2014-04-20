//:javascript
  $(function() {
    $('#search_term').autocomplete({
      source: function( request, response ) {
        $.ajax({
          url: '/autocomplete',
          dataType: 'json',
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
      delay: 0,
      focus: function( event, ui ) {
        $('#search_term').val( ui.item.label );
        return false;
      },
      select: function( event, ui ) {
        $('#search_term').val( ui.item.value );
        $('#search_form').submit();
      }
    });
    addTogglesToTaxonomy();
  });

  var addTogglesToTaxonomy = function() {
    $('.taxonomy li').each(function() {
      if (parseInt($(this).data('children')) > 0) {
        var toggle = $('<a/>', { class: 'toggle', href: '#' }).prepend('+');
        $(this).append(' ').append(toggle);
        toggle.on('click', function(e) {
          e.preventDefault();
          var taxonId = $(this).closest('li').data('taxon-id');
          loadTaxonomy(taxonId);
        });
      }
    });
  };

  var loadTaxonomy = function( taxon_id ) {
    $.ajax({
      url: '/api/taxonomy/' + taxon_id,
      dataType: 'html',
      success: function( html ) {
        $('.taxonomy').html(html);
        addTogglesToTaxonomy();
      }
    });
  };
