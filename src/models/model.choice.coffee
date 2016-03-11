# Copyright 2015 SpinalCom  www.spinalcom.com

# This file is part of SpinalCore.
#
# SpinalCore is licensed under the Free Software License Agreement
# that you should have received along with this file. If not, see
# <http://resources.spinalcore.com/license.pdf>.



# value choosen from a list
# get() will give the value
# num is the number of the choosen value in the list
# lst contains the posible choices
root = global ? this

class root.Choice extends Model 
    constructor: ( data, initial_list = [] ) ->
        super()
        
        # default
        @add_attr
            num: 0
            lst: initial_list
        
        # init
        if data?
            @num.set data

    filter: ( obj ) ->
        true
            
    item: ->
        @_nlst()[ @num.get() ]
            
    get: ->
        @item()?.get()
            
    toString: ->
        @item()?.toString()

    equals: ( a ) ->
        if a instanceof Choice
            super a
        else
            @_nlst()[ @num.get() ].equals a
    
    _set: ( value ) ->
        for i, j in @_nlst()
            if i.equals value
                return @num.set j
        @num.set value

    _nlst: ->
        l for l in @lst when @filter l
        
