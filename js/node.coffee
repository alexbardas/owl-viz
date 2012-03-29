# author Alex Bardas
# data type for creating a Tree structure

define [], ->

    # Tree Node
    class Node
        constructor: (params) ->
            @children = []
            @parent = {}
            @name = if params? then params.name else ''