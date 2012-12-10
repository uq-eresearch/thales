// Thales JavaScript
//
// Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

var thales = (function() {

    function replicateField(name_base) {

	var dl = $("#" + name_base + ">dl:eq(0)")

	// Generate identity for new field

        var num = dl.find('dt').length.toString();
	var ident = 'collection_' + name_base + '_' + num;

	// Add label

	var label_text = dl.find('dt:eq(0) > label').get(0).textContent;

	var newText = $(document.createTextNode(label_text));
	var newLabel = $(document.createElement("label"));
	newLabel.attr('for', ident);
	newLabel.append(newText);

	var newDT = $(document.createElement("dt"));
	newDT.append(newLabel);
	dl.append(newDT);

	// Add input field

	var t = $(document.createTextNode("World"));
	newInput = $(document.createElement("input"));
	newInput.attr('id', ident);
	newInput.attr('maxlength', 42); /* TODO */
	newInput.attr('name', 'collection[' + name_base + '][' + num + ']');
	newInput.attr('type', 'text');
	newDD = $(document.createElement("dd"));
	newDD.append(newInput);
	dl.append(newDD);

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
