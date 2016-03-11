# Copyright 2015 SpinalCom  www.spinalcom.com

# This file is part of SpinalCore.
#
# SpinalCore is licensed under the Free Software License Agreement
# that you should have received along with this file. If not, see
# <http://resources.spinalcore.com/license.pdf>.

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
