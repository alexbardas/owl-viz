# author Alex Bardas
# data type for creating a Tree structure

define ['cs!node'], (Node) ->

	# Tree's root, carries all the information needed 
	# to render a tree
	class Root extends Node
	    constructor: (params) ->
	        super params
	        @parent = null