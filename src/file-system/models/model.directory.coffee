# Copyright 2015 SpinalCom  www.spinalcom.com

# This file is part of SpinalCore.
#
# SpinalCore is licensed under the Free Software License Agreement
# that you should have received along with this file. If not, see
# <http://www.spinalcore.com/downloads/license.pdf>.

# List of files
# _underlying_fs_type is not needed ()

root = global ? this

class root.Directory extends Lst
    constructor: () ->
        super()

    base_type: ->
        File
    
    find: ( name ) ->
        for f in this
            if f.name.equals name
                return f
        return undefined

    load: ( name, callback ) ->
        f = @find name
        if f
            f.load callback
        else
            callback undefined, "file does not exist"
        
    has: ( name ) ->
        for f in this
            if f.name.equals name
                return true
        return false
    
    add_file: ( name, obj, params = {} ) ->
        o = @find name
        if o?
            return o
        res = new File name, obj, params
        @push res
        return res
    
    force_add_file: ( name, obj, params = {} ) ->
        num = @length
        find_name = true
        name_file = name + "_" + num
        while find_name
            name_file = name + "_" + num
            o = @find name_file
            if o?
                num += 1
            else
                break
        console.log name_file
        res = new File name_file, obj, params
        @push res
        return res

    get_file_info: ( info ) ->
        info.icon = "folder"
