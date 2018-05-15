# Copyright 2015 SpinalCom - www.spinalcom.com
#
# This file is part of SpinalCore.
#
# Please read all of the following terms and conditions
# of the Free Software license Agreement ("Agreement")
# carefully.
#
# This Agreement is a legally binding contract between
# the Licensee (as defined below) and SpinalCom that
# sets forth the terms and conditions that govern your
# use of the Program. By installing and/or using the
# Program, you agree to abide by all the terms and
# conditions stated or referenced herein.
#
# If you do not agree to abide by these terms and
# conditions, do not demonstrate your acceptance and do
# not install or use the Program.
#
# You should have received a copy of the license along
# with this file. If not, see
# <http://resources.spinalcom.com/licenses.pdf>.


# value choosen from a list
# get() will give the value
# num is the number of the choosen value in the list
# lst contains the posible choices
root = if typeof _root_obj == "undefined" then global else window

class root.Choice extends Model
    constructor: ( data, initial_list = [] ) ->
        super()
        
        # default
        @add_attr {
            num: 0
            lst: initial_list
        }
        
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
        
