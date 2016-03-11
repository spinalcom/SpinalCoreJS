# Copyright 2015 SpinalCom  www.spinalcom.com

# This file is part of SpinalCore.
#
# SpinalCore is licensed under the Free Software License Agreement
# that you should have received along with this file. If not, see
# <http://resources.spinalcore.com/license.pdf>.

# contains (privately on the server) a path to data on the server

root = global ? this

class root.Path extends Model
    # @file is optionnal. Must be a javascript File object
    constructor: ( @file ) ->
        super()

        size = if @file?
            if @file.fileSize? then @file.fileSize else @file.size
        else
            0
        
        @add_attr
            remaining: size
            to_upload: size

    get_file_info: ( info ) ->
        info.remaining = @remaining
        info.to_upload = @to_upload
        
    _get_fs_data: ( out ) ->
        super out
        # permit to send the data after the server's answer
        if @file? and @_server_id & 3
            FileSystem._files_to_upload[ @_server_id ] = this
