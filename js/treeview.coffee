define ['backbone', 'cs!mustache', 'underscore', 'cs!log', 'text!templates/item.mjs'], (Backbone, Mustache, _, log, ItemTemplate) ->
	log.debug(true)
	print = log.info
	warn = log.warn
	error = log.error

	class ItemModel extends Backbone.Model
		defaults:
			parent: null
			name: '',
			isExpandable: false,
			childrenNo: 1

	'''	
		Render a new "ul" element
	'''
	class ItemView extends Backbone.View
		tagName: 'ul'
		className: 'nav nav-list'
		template: ItemTemplate
		$previousElement: ''

		events: 
			"click li": "expandList"
			#"dblclick li": "editContent"
			#"keydown li": "saveContent"

		initialize: (options) ->
			#print "Initializing Item View"
			if options? and options.model?
				@model = options.model

		render: ->
			#print "Rendering Item View"
			parent = @model.get('parent')
			attr = @model.attributes
			@.$el.html(Mustache.to_html(@template, attr))
			if parent? then @.$el.hide() else @.$el.show()
			@

		reRender: ($el) ->
			print "Rerendering Item View"
			parent = @model.get('parent')
			attr = @model.attributes
			$el = Mustache.to_html(@template, attr)

		expandList: (event)->
			event.stopPropagation()
			$el = @.$el.find("li:first")
			if $el.is(@$previousElement)
				@$previousElement.attr('contenteditable', false);

			if $el.find("a").attr('contenteditable') is "true"
				return @
			isExpanded = @.model.get('isExpanded')
			@.model.set('isExpanded', !isExpanded)

			$el.nextAll().toggle();
			@.reRender($el)

			$('html, body').animate(
		         scrollTop: $el.offset().top - 50
		         500
		  	)

		editContent: (event)->
			event.stopPropagation()
			$el = @.$el.find("li:first").find("a")
			$el.attr('contenteditable', true)
			$el.focus()
			@$previousElement = $el

		saveContent: (event)->
			event.stopPropagation()
			if event.keyCode is 13
				@.$el.find("li:first a").attr('contenteditable', false)

	class TreeView extends Backbone.View
		tagName: 'ul'
		className: 'nav nav-list'

		initialize: (json) ->
			#print "Initializing Tree View"
			json = json or {}
			@.createTree(json, @el, null)
		
		# Recursively creat the needed Tree element
		# of the initial json
		createTree: (json, el, root, parent) ->
			print "Creating new tree branch"
			if root?
				@.addItems(el, {parent: parent or null, name: root, isExpandable: true, isExpanded: false, childrenNo: _.keys(json).length})
				el = $(el).children().last();

			for key of json
				print "Process element '#{key}' with parent '#{root}'"
				if _.isEmpty json[key]
					@.addItems(el, {name: key, parent: root or null})
				else
					@.createTree(json[key], el, key, root)

		addItems: (el, params={}) ->
			print "Adding '#{params.name}'"

			model = new ItemModel(params)
			view = new ItemView({model: model})
			$(el).append(view.render().el)

	return TreeView