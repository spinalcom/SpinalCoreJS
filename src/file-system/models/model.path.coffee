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
