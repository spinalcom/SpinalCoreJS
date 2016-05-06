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


# List of files
# _underlying_fs_type is not needed ()

root = if typeof _root_obj == "undefined" then global else window

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
    
    add_tiff_file: ( name, obj, tiff_obj, params = {} ) ->
        o = @find name
        if o?
            return o
        res = new TiffFile name, obj, tiff_obj, params
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
