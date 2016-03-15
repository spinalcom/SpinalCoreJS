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

url = require('url');
root = global ? this

# Define main API
class root.spinalCore

    @connect: (options) ->
        if typeof options == 'string'
            options = url.parse(options)

        FileSystem._home_dir = options.path
        FileSystem._url = options.hostname
        FileSystem._port = options.port
        FileSystem._userid = options.auth
        return new FileSystem

    # stores a model in the file system
    @store: (fs, model, file_name, callback) ->
        fs.load_or_make_dir FileSystem._home_dir, ( dir, err ) =>
            file = dir.detect ( x ) -> x.name.get() == file_name
            if file?
                dir.remove file
            dir.add_file file_name, model, model_type: "Test"
            callback()

    # loads a model from the file system
    @load: (fs, file_name, callback) ->
        fs.load_or_make_dir FileSystem._home_dir, ( current_dir, err ) ->
            file = current_dir.detect ( x ) -> x.name.get() == file_name
            if file?
                console.log "load"
                file.load ( data, err ) =>
                    callback(data)

    # "static" method: extend one object as a class, using the same 'class' concept as coffeescript
    @extend: (child, parent) ->
        for key, value of parent
            child[key] = value

        ctor = () ->
            @constructor = child
            return

        ctor.prototype = parent.prototype
        child.prototype = new ctor()
        child.__super__ = parent.prototype

        # using embedded javascript because the word 'super' is reserved
        `child.super = function () {
            var args = [];
           	for (var i=1; i < arguments.length; i++)
                args[i-1] = arguments[i];
            child.__super__.constructor.apply(arguments[0], args);
        }`

        root = global ? this
        child_name = /^function\s+([\w\$]+)\s*\(/.exec( child.toString() )[ 1 ]
        root[child_name] = child

module.exports = spinalCore
