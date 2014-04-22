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
            response(data);
          }
        });
      },
      minLength: 1,
      delay: 0,
      focus: function( e, ui ) {
        e.preventDefault();
      },
      select: function( e, ui ) {
        window.location = $('.ui-autocomplete a[href$="'+ ui.item.id +'"]').attr('href');
      }
    }).on('focus', function() {
      $(this).autocomplete('search', $(this).val())
    }).data('ui-autocomplete')._renderItem = function( ul, item ) {
      return $( "<li>" )
        .attr( "data-value", item.value )
        .append( $( "<a>" ).html( item.label ) )
        .appendTo( ul );
    };
    addTogglesToTaxonomy();
    addCollapseTaxonomy();
  });

  var collapseTaxonomy = function() {
    $('.taxonomy > ul > li:first-child a.toggle').click();
  }

  var addCollapseTaxonomy = function() {
    var collapseLink = $('<a/>', { href: '#', class: 'collapse-all' }).prepend('Collapse all');
    collapseLink.on('click', function(e) {
      e.preventDefault();
      collapseTaxonomy();
    });
    collapseLink.appendTo($('.taxonomy'));
  };

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
        addCollapseTaxonomy();
      }
    });
  };

