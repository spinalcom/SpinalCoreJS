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
