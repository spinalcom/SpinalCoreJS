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

# false by default
#
root = if typeof _root_obj == "undefined" then global else window

class root.Bool extends Obj
    constructor: ( data ) ->
        super()

        @_data = false

        # default values
        if data?
            @_set data
    
    # toggle true / false ( 1 / 0 )
    toggle: ->
        @set not @_data

    toBoolean: ->
        @_data

    #
    deep_copy: ->
        new Bool @_data

    # we do not take _set from Obj because we want a conversion if value is not a boolean
    _set: ( value ) ->
        if n instanceof Model
            n = value.toBoolean()
        else if value == "false"
            n = false
        else if value == "true"
            n = true
        else
            n = Boolean value

        if @_data != n
            @_data = n
            return true

        return false
        
    #
    _get_fs_data: ( out ) ->
        FileSystem.set_server_id_if_necessary out, this
        out.mod += "C #{@_server_id} #{ 1 * Boolean( @_data ) } "
