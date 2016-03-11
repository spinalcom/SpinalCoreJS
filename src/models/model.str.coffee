# Copyright 2015 SpinalCom  www.spinalcom.com

# This file is part of SpinalCore.
#
# SpinalCore is licensed under the Free Software License Agreement
# that you should have received along with this file. If not, see
# <http://resources.spinalcore.com/license.pdf>.

# String

root = global ? this

class root.Str extends Obj
    constructor: ( data ) ->
        super()
        
        # default value
        @_data = ""
        @length = 0

        # init if possible
        if data?
            @_set data

    # toggle presence of str in this
    toggle: ( str, space = " " ) ->
        l = @_data.split space
        i = l.indexOf str
        if i < 0
            l.push str
        else
            l.splice i, 1
        @set l.join " "

    # true if str is contained in this
    contains: ( str ) ->
        @_data.indexOf( str ) >= 0

    #
    equals: ( str ) ->
        @_data == str.toString()
        
    #
    ends_with: ( str ) ->
        l = @_data.match( str + "$" )
        l?.length and l[ 0 ] == str
        
    #
    deep_copy: ->
        new Str @_data + ""

    #
    _get_fs_data: ( out ) ->
        FileSystem.set_server_id_if_necessary out, this
        out.mod += "C #{@_server_id} #{encodeURI @_data} "

    #
    _set: ( value ) ->
       
        if not value?
            return @_set "" 
        n = value.toString()
        if @_data != n
            @_data = n
            @length = @_data.length
            return true
        return false

    #
    _get_state: ->
        encodeURI @_data

    _set_state: ( str, map ) ->
        @set decodeURIComponent str
