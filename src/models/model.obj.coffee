# Copyright 2015 SpinalCom  www.spinalcom.com

# This file is part of SpinalCore.
#
# SpinalCore is licensed under the Free Software License Agreement
# that you should have received along with this file. If not, see
# <http://resources.spinalcore.com/license.pdf>.

# generic object with data

root = global ? this

class root.Obj extends Model
    constructor: ( data ) ->
        super()
        
        if data?
            @_set data

    toString: ->
        @_data?.toString()

    equals: ( obj ) ->
        if obj instanceof Obj
            return @_data == obj._data
        return @_data == obj

    get: ->
        @_data

    _get_fs_data: ( out ) ->
        FileSystem.set_server_id_if_necessary out, this
        out.mod += "C #{@_server_id} #{@toString()} "

    _set: ( value ) ->
        if @_data != value
            @_data = value
            return true
        return false
            
    _get_state: ->
        @_data

    _set_state: ( str, map ) ->
        @set str
