//:javascript
  var NO_RESULTS_LABEL = 'No results';

  $(function() {
    if ($('#search_form').length > 0) {
      $('#search_term').autocomplete({
        source: function( request, response ) {
          $.ajax({
            url: '/autocomplete',
            dataType: 'json',
            data: {
              search_term: request.term,
              batch_size: 7
            },
            success: function( data ) {
              if (!data.length) {
                data = [ NO_RESULTS_LABEL ];
              }
              response(data);
            }
          });
        },
        minLength: 1,
        delay: 0,
        // when a user clicks a result, take them to the taxon page immediately
        select: function( e, ui ) {
          if (ui.item.label === NO_RESULTS_LABEL) {
            e.preventDefault();
            return;
          }
          window.location = $(ui.item.label).data('path');
        }
      }).on('focus', function() {
        // when the autocomplete field loses focus the results disappear.
        // this will make sure they come back when the field regains focus
        $(this).autocomplete('search', $(this).val());
      }).data('ui-autocomplete')._renderItem = function( ul, item ) {
        // a custom render of an autocomplete result. This is nearly the same
        // as the default render, except the contents are rendered as HTML not text
        return $( "<li>" )
          .attr( "data-value", item.value )
          .append( $( "<a>" ).html( item.label ) )
          .appendTo( ul );
      };
      addTogglesToTaxonomy();
      addTreeBrowsingActions();
    }
  });

  var collapseTaxonomy = function() {
    loadTaxonomy($('.tree--taxonomy > .tree__item:first-child').data('taxon-id'));
  }

  var addTreeBrowsingActions = function() {
    if ($('.browser__actions').length > 0) return;
    var browserActions = $('<div/>', { class: 'browser__actions' }),
        collapseLink = $('<a/>', { href: '#', class: 'browser__action--collapse' })
          .prepend('Collapse all').appendTo(browserActions);
    collapseLink.on('click', function(e) {
      e.preventDefault();
      collapseTaxonomy();
    });
    browserActions.insertBefore($('.tree__wrapper--taxonomy'));
  };

  var addTogglesToTaxonomy = function() {
    $('.tree__item').each(function() {
      if (parseInt($(this).data('children')) > 0) {
        if ($(this).hasClass('tree__item--expanded')) {
          return true; // next
        }
        var toggle = $('<a/>', { class: 'toggle', href: '#' }).prepend('+');
        $(this).append('&thinsp;').append(toggle);
        toggle.on('click', function(e) {
          e.preventDefault();
          loadTaxonomy($(this).closest('.tree__item').data('taxon-id'));
        });
      }
    });
  };

  var loadTaxonomy = function( taxon_id ) {
    $.ajax({
      url: '/api/taxonomy/' + taxon_id,
      dataType: 'html',
      success: function( html ) {
        $('.tree--taxonomy').replaceWith(html);
        addTogglesToTaxonomy();
        addTreeBrowsingActions();
      }
    });
  };

