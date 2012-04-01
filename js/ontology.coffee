# author Alex Bardas
# Converts a valid XML ontology generated in *Protege* into a JSON
# First it creates the ontology's tree defined by root and children nodes
# Then, it creates a proper json from this tree

define ['cs!log', 'cs!tree'], (log, Tree) ->
    # set debug to true or false
    log.debug(false)
    print = log.info
    warn = log.warn
    error = log.error

    Node = Tree.Node
    Root = Tree.Root

    class Ontology
        type = Object.prototype.toString
        
        constructor: (owl) ->
            print "Initialize Ontology"
            # receives a string and checks if it is
            # a valid XML so it can return a proper JSON
            # after parsing it
            valid = @.isValidXML? owl

            if not valid 
                return false
            else
                root = @.toTREE valid

            if type.call("[object Object]")
                return @.toJSON(root)
            else
                return false

        toTREE: (xml) ->
            print "Create Tree"
            tree = {}
            root = 0

            $.each $(xml).find("Declaration"), (k, v) ->
                v = $(v).children().eq(0)
                name = v.attr("IRI")

                if name?
                    tree[name] = new Node({name: name})
                else
                    root_name = v.attr("abbreviatedIRI")
                    # remove first characters until ":"
                    # egg: owl:Thing -> Thing
                    # egg: owl:owl:Thing -> owl:Thing
                    root_name = root_name.replace(/.*?:/, '')
                    if root_name
                        tree[root_name] = new Root({name: root_name})
                        root = tree[root_name]
                    
                true

            $.each $(xml).find("SubClassOf"), (k, v) ->
                v = $(v).children()
                name = v.eq(0).attr("IRI")
                parent_name = v.eq(1).attr("IRI") || v.eq(1).attr("abbreviatedIRI").replace(/.*?:/, '')
                tree[name].parent = tree[parent_name]
                tree[parent_name].children.push(tree[name])
                true

            # the root has information about the whole tree
            root
        toJSON: (root) ->
            print "Create JSON"
            
            # transform the tree into a JSON
            json = {}
            json[root.name] = {}
            traversal = (node, json) ->
                # check if it is a leaf
                if node.children.length is 0
                    {}
                else
                    for child in node.children
                        json[node.name][child.name] = {}
                        traversal child, json[node.name]


            traversal root, json

            json

        isValidXML: (owl) ->
            print "Test if XML is valid"
            # tries to see if ontology is a valid XML document
            # return false if the document is not a XML 
            # else returns the document
            
            # try
            #     doc = $.parseXML(owl)
            # catch err
            #     error "The ontology is not a valid XML", err
            #     return false
            doc = owl
            return doc