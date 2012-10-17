// Thales JavaScript
//
// Copyright (C) 2012, The University of Queensland.

var thales = (function() {

    function replicateField(name_base) {
//	itemDiv = $(this).parent().parent()
//node = itemDiv.find("label").each(function(i) {
//	    $(this).append("foo"+i);
//	});

	itemDiv = $("#" + name_base)
	dlElement = itemDiv.find('dl')

	// Generate identity for new field

        var num = dlElement.find("dt").length.toString();
	ident = 'collection_' + name_base + '_' + num;

	// Add label

	label_text = dlElement.find('dt').first().find('label').text();

	newText = $(document.createTextNode(label_text));
	newLabel = $(document.createElement("label"));
	newLabel.attr('for', ident);
	newLabel.append(newText);

	newDT = $(document.createElement("dt"));
	newDT.append(newLabel);
	dlElement.append(newDT);

	// Add input field

	t = $(document.createTextNode("World"));
	newInput = $(document.createElement("input"));
	newInput.attr('id', ident);
	newInput.attr('maxlength', 42);
	newInput.attr('name', 'collection[' + name_base + '][' + num + ']');
	newInput.attr('type', 'text');
	newDD = $(document.createElement("dd"));
	newDD.append(newInput);
	dlElement.append(newDD);

	event.preventDefault();
    }

  /* Public functions */

  var instance = {};
  instance.replicateField = replicateField;
  return instance;
}());

//$(document).ready(function(){
// $("a").click(function(event){
//});
//));

//EOF
