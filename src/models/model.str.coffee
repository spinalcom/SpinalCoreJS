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


# String

root = if typeof _root_obj == "undefined" then global else window

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
