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
root = if typeof _root_obj == "undefined" then global else window

class root.ConstrainedVal extends Model
    constructor: ( value, params = {} ) ->
        super()

        @add_attr {
            val: value or 0
            _min: if params.min? then params.min else 0
            _max: if params.max? then params.max else 100
        }
        @add_attr {
            _div: if params.div? then params.div else (@_max - @_min)
        }

    get: ->
        @val.get()

    ratio: ->
        ( @val.get() - @_min.get() ) / @delta()
    
    delta: ->
        @_max.get() - @_min.get()
        
    set_params: (params) ->
        @_min.set if params.min? then params.min else 0
        @_max.set if params.max? then params.max else 100
        @_div.set if params.div? then params.div else (@_max - @_min)
    #
    _set: ( value ) ->
        if value instanceof ConstrainedVal
            return @val._set value.get()
        res = @val.set value
        @_check_val()
        return res

    #
    _check_val: ->
        v = @val .get()
        m = @_min.get()
        n = @_max.get()
        d = @_div.get()
        
        if v < m
            @val.set m
        if v > n
            @val.set n
            
        if d
            s = ( n - m ) / d
            r = m + Math.round( ( @val.get() - m ) / s ) * s
            @val.set r
