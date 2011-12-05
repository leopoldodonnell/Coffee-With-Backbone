$(document).ready ->
	
	# Create the collection of Baristas for the ListView and put the view into the
	# baristas div
	baristas = new List baristaList
	list_view = new ListView {collection: baristas, el: $("#baristas") }
	

