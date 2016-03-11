# Copyright 2015 SpinalCom  www.spinalcom.com

# This file is part of SpinalCore.
#
# SpinalCore is licensed under the Free Software License Agreement
# that you should have received along with this file. If not, see
# <http://resources.spinalcore.com/license.pdf>.

# scalar
root = global ? this

class root.Val extends Obj
    constructor: ( data ) ->
        super()

        @_data = 0

        # default values
        if data?
            @_set data
    
    # toggle true / false ( 1 / 0 )
    toggle: ->
        @set not @_data

    #
    toBoolean: ->
        Boolean @_data

    #
    deep_copy: ->
        new Val @_data

    #
    add: ( v ) ->
        if v
            @_data += v
            @_signal_change()
        
    # we do not take _set from Obj because we want a conversion if value is not a number
    _set: ( value ) ->
        # console.log value
        if typeof value == "string"
            if value.slice( 0, 2 ) == "0x"
                n = parseInt value, 16
            else
                n = parseFloat value
                if isNaN n
                    n = parseInt value
                if isNaN n
                    console.log "Don't know how to transform #{value} to a Val"
        else if typeof value == "boolean"
            n = 1 * value
        else if value instanceof Val
            n = value._data
        else # assuming a number
            n = value

        if @_data != n
            @_data = n
            return true

        return false
