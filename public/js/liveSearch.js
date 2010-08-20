(function($){
// Based on resig's http://ejohn.org/blog/jquery-livesearch
// Adapted by vic.

jQuery.fn.liveUpdate = function(selector, resultsOn) {
  this.unbind('keyup');
  this.bind('keyup', filter(selector, resultsOn));
}

var scoreForTerm = function(term, text){
  var score = 0;
  var terms = term.split(/ +/);
  jQuery.each(terms, function(i){
    score += text.split(terms[i]).length - 1;
  });
  return score;
}

var filter = function(selector, resultsOn){
  var rows,cache;
  var results = jQuery(resultsOn);
  return function(){
    if(!rows){
      rows = jQuery(selector);
      cache = rows.map(function(){
	return this.innerHTML.toLowerCase();
      });
    }
    var term = jQuery.trim(jQuery(this).val().toLowerCase()), 
    scores = [];
    results.html('');
    if ( !term ) {
      jQuery.each(rows, function(i){ 
	var row = rows[i]
	if(row.liveSearchHolder) {
	  $(row.liveSearchHolder).replaceWith(row)
	  delete row.liveSearchHolder
	}
	$(row).show();
      });
    } else {
      rows.hide();
      cache.each(function(i){
	var score = scoreForTerm(term, cache[i]);
	if (score > 0) { scores.push([score, i]); }
      });
      jQuery.each(scores.sort(function(a, b){return (b[0] - a[0])}), function(){
	var row = rows[this[1]];
	if(resultsOn){
	  if(!row.liveSearchHolder){
	    row.liveSearchHolder = row.liveSearchHolder || $('<span/>')[0]
	    $(row).replaceWith(row.liveSearchHolder)
	  }
	  results.append(row);
	}
	$(row).show();
      });
    }
  }
}


})(jQuery);