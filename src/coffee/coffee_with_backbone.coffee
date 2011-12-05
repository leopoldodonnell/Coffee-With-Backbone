#
# coffee_with_backbone.coffee
# coffee
# 
# Created by Leopold ODonnell on 05/12/2011.
# 
# Copyright (c) 2011 BigLife Labs, Inc.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

#
# ListItem class
#
# This class can have anything in it as long as there is a 'name' property that
# will be displayed in the list
#
class ListItem extends Backbone.Model
	defaults: {
		'name': 'no name'		
	}
	
	#
	# Return the URL
	#
	# This provides the RESTful magic that works with a grails RESTful controller
	# to CREATE, UPDATE and DELETE an item.
	#
	# The method checks the 'id' property's existance. If its there, then the instance
	# has already been created, so the operation will be an UPDATE or DELETE, otherwise
	# its a CREATE operation.
	#
	# Using this approach, no change is required to Backbone.sync.
	#
	url: -> 
		if @id?
			# Update, Delete - urlRoot is now part of @ and not on @attributes
			@urlRoot + "/" + @id
		else
			# Create - urlRoot hasn't been set on @ yet get it from @attributes
			@get('urlRoot')
	
	getText: -> @get('name')
	

#
# List class
#
# A pretty straight forward Backbone collection. The only thing of interest is the 'url' method
# returns @urlRoot. This is set on it by its view, 'ListView' during its initialization. This
# makes it possible for Backbone.sync to get the collection from the server without modification.
#
# The second thing to note is that the list is being sorted by the grails object.id property. Other
# forms of ordering could be employed; this is just here to illustrate how to keep the item in order.
#
# Depending on the way the collection is mashalled to JSON by the grails controller, the following
# code may be needed.
#
# Use the following code if the JSON collection returned by url is nested inside a top level object.
#
# E.g. a collection of people rendered in JSON as: {people : [{name: fred}, {barney}]}
#
#parse: (response)->
#	for prop of response
#		return response[prop]
#
class List extends Backbone.Collection
	model: ListItem
	url: -> @urlRoot
	comparator: (item) -> item.get 'id'
		

#
# ListItemView
#
# Lot's of interesting Backbone and Coffeescript things going on in this class.
#
# The view presents as a list with text input at the bottom.
# Entering some text will create a new Item that has been persisted to the database
# Mousing over an item reveals a 'delete button' that can be clicked to pop up a
# confirmation dialog to delete item from the database.
# A double-click on the item will switch the item to a text input the enables the
# name property of the item to be updated.
#
class ListItemView extends Backbone.View
	className: 'cwbListItemView'
	tagName: 'li'
	
	#
	# Some CSS trickery is performed here to switch back and forth from display and
	# edit modes. See the 'coffee_with_backbone.css' to understand how the '.cwbEditing'
	# class is added to/removed from @el to toggle what the user sees.
	#
	template: _.template('''
		<div>
			<div class="cwbDisplay">
				<div class="cwbItem">
					<%= listItem.getText() %>
					<span class="cwbItemDestroy">Delete Item</span>
				</div>
			</div>
			<div class="cwbEdit">
				<input class="cwbItemInput" type="text" value=""/>
			</div>
		</div>
		''')
	
	# A nice tidy way to map events on the View
	events:
		"click span.cwbItemDestroy" : "clear"
		"mouseover"									: "show_delete"
		"mouseout"									: "hide_delete"
		"dblclick .cwbItem"					: "edit"
		"keypress .cwbItemInput"		: "updateOnEnter"
		
	initialize: ->
		@model.bind 'change', @render, @
		@model.bind 'destroy', @unrender, @
		@model.view = @
		@render()

	#
	# Render the View, bind the hidden text input and hide the
	# 'Delete Item' button 
	#
	render: =>
		text = @model.getText()
		$(@el).html @template {listItem : @model}
		@input = @$('.cwbItemInput')
		@input.bind('blur', _.bind @close, @).val text
		@hide_delete()
		
	# Remove the view from the DOM.
	unrender: -> $(@el).remove()

	# Pop up a dialog to remove the item and destroy the model.
	clear: ->
		confirm = new ConfirmDialog model: @model 
		confirm.open()

	show_delete: ->
		$(@el).find('.cwbItemDestroy').removeClass('hidden')
		@ # good practice to return @, so the method can be chanined
	
	hide_delete: ->
		$(@el).find('.cwbItemDestroy').addClass('hidden')
		@ # good practice to return @, so the method can be chanined
	
	# Switch to view the text input
	edit: ->
		$(@el).addClass "cwbEditing"
		@input.focus()
	
	# Save away the edit from the text input and switch back to the display view
	close: ->
		if @input.val()
			@model.save name: @input.val()
		$(@el).removeClass "cwbEditing"
	
	updateOnEnter: (e) -> @close() if e.keyCode == 13
		

	
#
# ListView
#
# Create a new list view by passing it a new List
#
# E.G.
# listView = new ListView { collection: myGrailsCollection }
#
# Options:
#		collection : an instance of a List class. An empty list is created otherwise.
#		urlRoot : should be set if he List controller URL != document.URL
#
class ListView extends Backbone.View
	className: 'cwbListView'
	tagName: 'div'
	template: _.template('''
	<div>
		<ul></ul>
		<input class="cwbInput" placeholder="Write something then press the <enter> key" type="text"/>
	</div>
	''')
	
	events:
		"keypress .cwbInput":	"createOnEnter"
		
	initialize: ->
		# Create a collection if none given.
		if !@collection
			@collection = new List

		# Watch for items on the collection to be added so they can be
		# rendered properly
		@collection.bind 'add', @appendItem, @
		
		#
		# Set the @urlRoot from the constructor options or get it from the document.
		# 
		@urlRoot = @options.urlRoot
		@urlRoot ?= document.URL
		@collection.urlRoot = @urlRoot
		@render()
	
	#
	# Render the List
	#
	# Note the use of => to ensure that @ is the view instance
	# returns @ to enable chaining of calls.
	#
	render: =>
		$(@el).html @template
		@input = @$('.cwbInput')
		@addAll()
		@ # good practice to return @, so the method can be chanined
	
	#
	# Add an item from the collection by giving it a view and appending its
	# view to the collection's view.
	#		
	appendItem: (item) ->
		# Set the urlRoot on the item, so the REST operations can be performed.
		item.urlRoot = @urlRoot
		itemView = new ListItemView {model: item}
		@$('ul').append itemView.render().el
	
	#
	# Refresh the view with all of the items in the collection
	#
	addAll:	-> @collection.each @appendItem, @
	
	#
	# Create a new item from text input if there's text and the enter key
	# key has been pressed.
	#
	# Note how the Backbone collection provides a neat way to creat and
	# render the new item.
	#
	createOnEnter: (e) ->
		text = @input.val()
		return if !text || e.keyCode != 13
		item = @collection.create name: text, urlRoot : @urlRoot
		@input.val('')
		

#
# This is an example of how someone might integrate a model confirmation
# dialog using jQuery-ui to delete a model instance.
#
# Much of this could have been done inline, but this shows a clean approach
# that is readable and could be improved to offer greater flexibility.
#
# 
class ConfirmDialog extends Backbone.View
	className: 'cwbConfirmDialog'
	template: _.template('Are you sure you want to delete <%= model.getText() %>?')
	
	initialize: ->
		@render()
	
	render: ->
		$(@el).html @template {model : @model}
		$(@el).dialog
			title: 'Confirm Delete'
			autoOpen: false,
			modal: true,
			buttons:
				"Cancel": @cancel
				"Confirm": @confirm
		@
		
	open: -> $(@el).dialog "open"
	
	#
	# Destroy the model instance. Not the use of => to bind @ to the 
	# ConfirmDialog instance. Without this, it would be necessary to
	# find some other way of getting it to find @model
	#
	confirm: =>
		@model.destroy() if @model?
		$(@el).dialog "close"
	
	# Just close the dialog - @ in this case is the ConfirmationDialog's @el
	cancel: -> $(@).dialog "close"


# Export the ListView so it can be accessed by the document.
window.ListView = ListView
window.List = List
window.ListItemView = ListItemView
window.ListItem = ListItem

