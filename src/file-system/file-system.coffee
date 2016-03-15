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


#
# data from changed object are sent if not activity since 100ms
# 
#

root = global ? this

class root.FileSystem
    # when object are saved, their _server_id is assigned to a tmp value
    @_cur_tmp_server_id = 0
    @_sig_server = true # if changes has to be sent
    @_disp = false
    @_userid = "644"

    # TODO: Hardcoded: review this
    if typeof window == 'undefined'
        XMLHttpRequest_node = require 'xhr2'
        @_XMLHttpRequest = XMLHttpRequest_node
    
    # data are sent after a timeout (and are concatened before)
    @_objects_to_send = {}
    @_timer_send = undefined #
    @_timer_chan = undefined #
    
    # functions to be called after an answer
    @_nb_callbacks = 0
    @_callbacks = {}

    # instances of FileSystem
    @_nb_insts = 0
    @_insts = {}
    
    # ..._server_id -> object
    @_files_to_upload = {} # ref to Path waiting to be registered before sending data
    @_ptr_to_update = {} # Ptr objects that need an update, associated with @_tmp_objects
    @_tmp_objects = {} # objects waiting for a real _server_id
    @_objects = {} # _server_id -> object
    
    # url and port of the server
    @_url = "127.0.0.1"
    @_port = "8888"
    
    @url_com = "/sceen/_" # 
    @url_upload = "/sceen/upload" # 
    
    # conector type : Browser or Node
    if typeof window == 'undefined'
        @CONNECTOR_TYPE = "Node"
    else
        @CONNECTOR_TYPE = "Browser"
        

    constructor: ->
        # default values
        @_data_to_send    = ""
        @_session_num     = -2 # -1 means that we are waiting for a session id after a first request.
        @_num_inst        = FileSystem._nb_insts++
        
        # register this in FileSystem instances
        FileSystem._insts[ @_num_inst ] = this    
        
        # first, we need a session id fom the server
        if FileSystem._userid?
            @send "U #{FileSystem._userid} "
        @send "S #{@_num_inst} "
        
    
    # load object in $path and call $callback with the corresponding model ref
    load: ( path, callback ) ->
        FileSystem._send_chan()
        @send "L #{FileSystem._nb_callbacks} #{encodeURI path} "
        FileSystem._callbacks[ FileSystem._nb_callbacks ] = callback
        FileSystem._nb_callbacks++

    # make dir if not already present in the server. Call callback -- as in the @load proc -- when done (i.e. when loaded or created)
    load_or_make_dir: ( dir, callback ) ->
        @load dir, ( res, err ) =>
            if err
                if dir == "/"
                    callback 0, err
                else
                    lst = ( v for v in dir.split '/' when v.length )
                    nir = lst.pop()
                    oir = "/" + lst.join( "/" )
                    @load_or_make_dir oir, ( n_res, n_err ) =>
                        if n_err
                            callback 0, n_err
                        else
                            n_dir = new Directory
                            n_res.add_file nir, n_dir
                            callback n_dir, n_err
            else
                callback res, err
    

    # load an object using is pointer and call $callback with the corresponding ref
    load_ptr: ( ptr, callback ) ->
        FileSystem._send_chan()
        @send "l #{FileSystem._nb_callbacks} #{ptr} "
        FileSystem._callbacks[ FileSystem._nb_callbacks ] = callback
        FileSystem._nb_callbacks++
        
    # explicitly send a command
    send: ( data ) ->
        @_data_to_send += data
        if not FileSystem._timer_send?
            FileSystem._timer_send = setTimeout FileSystem._timeout_send_func, 1

    # send a request for a "push" channel
    make_channel: ->  
        path = ""
        if FileSystem.CONNECTOR_TYPE == "Browser"
            path =  FileSystem.url_com + "?s=#{@_session_num}"
        else if FileSystem.CONNECTOR_TYPE == "Node"
            path = "http://" + FileSystem._url + ":" + FileSystem._port + FileSystem.url_com + "?s=#{@_session_num}"
                   
        xhr_object = FileSystem._my_xml_http_request()
        xhr_object.open 'GET', path, true
        xhr_object.onreadystatechange = ->
            if @readyState == 4 and @status == 200
                if FileSystem._disp
                    console.log "chan ->", @responseText
                    
                _w = ( sid, obj ) ->
                    if sid? and obj?
                        obj._server_id = sid
                        FileSystem._objects[ sid ] = obj
                    
                FileSystem._sig_server = false
                
                eval @responseText
                FileSystem._sig_server = true
        xhr_object.send()
        

    # get the first running inst
    @get_inst: ->
        for k, i of FileSystem._insts
            return i
        new FileSystem
        
    #
    @set_server_id_if_necessary: ( out, obj ) ->
        if not obj._server_id?
            # registering
            obj._server_id = FileSystem._get_new_tmp_server_id()
            FileSystem._tmp_objects[ obj._server_id ] = obj
            
            # new object
            ncl = ModelProcessManager.get_object_class( obj )
            if obj._underlying_fs_type?
                out.mod += "T #{obj._server_id} #{ncl} "
                ncl = obj._underlying_fs_type()
            out.cre += "N #{obj._server_id} #{ncl} "
            
            # data
            obj._get_fs_data out


    # send changes of m to instances.
    @signal_change: ( m ) ->
        if FileSystem._sig_server
            FileSystem._objects_to_send[ m.model_id ] = m
            if FileSystem._timer_chan?
                clearTimeout FileSystem._timer_chan
            FileSystem._timer_chan = setTimeout FileSystem._timeout_chan_func, 250

    #
    @_tmp_id_to_real: ( tmp_id, res ) ->
        tmp = FileSystem._tmp_objects[ tmp_id ]
        if not tmp?
            console.log tmp_id
        
        FileSystem._objects[ res ] = tmp
        tmp._server_id = res
        delete FileSystem._tmp_objects[ tmp_id ]
        
        #
        ptr = FileSystem._ptr_to_update[ tmp_id ]
        if ptr?
            delete FileSystem._ptr_to_update[ tmp_id ] 
            ptr.data.value = res
            
        #
        if FileSystem._files_to_upload[ tmp_id ]? and tmp.file?
            delete FileSystem._files_to_upload[ tmp_id ] 
            # send the file
            fs = FileSystem.get_inst()                    
            
            path = ""
            if FileSystem.CONNECTOR_TYPE == "Browser"
                path = FileSystem.url_com + "?s=#{fs._session_num}&p=#{tmp._server_id}"
            else if FileSystem.CONNECTOR_TYPE == "Node"
                path = "http://" + FileSystem._url + ":" + FileSystem._port + FileSystem.url_com + "?s=#{fs._session_num}&p=#{tmp._server_id}"
             
            xhr_object = FileSystem._my_xml_http_request()
            xhr_object.open 'PUT', path, true
            xhr_object.onreadystatechange = ->
                if @readyState == 4 and @status == 200
                    _w = ( sid, obj ) ->
                        if sid? and obj?
                            obj._server_id = sid
                            FileSystem._objects[ sid ] = obj
                    
                    eval @responseText
            xhr_object.send tmp.file
            delete tmp.file
            

    @_get_new_tmp_server_id: ->
        FileSystem._cur_tmp_server_id++
        if FileSystem._cur_tmp_server_id % 4 == 0
            FileSystem._cur_tmp_server_id++
        FileSystem._cur_tmp_server_id

    # send changes
    @_send_chan: ->
        out = FileSystem._get_chan_data()
        for k, f of FileSystem._insts
            f.send out
        
    # timeout for at least one changed object
    @_timeout_chan_func: ->
        FileSystem._send_chan()
        delete FileSystem._timer_chan

    # get data of objects to send
    @_get_chan_data: ->
        out = { cre: "", mod: "" }
        for n, model of FileSystem._objects_to_send
            model._get_fs_data out
        FileSystem._objects_to_send = {}
        
        out.cre + out.mod
        
    # 
    @_timeout_send_func: ->
        # if some model have changed, we have to send the changes now
        out = FileSystem._get_chan_data()
        for k, f of FileSystem._insts
            f._data_to_send += out
        
        # send data
        for k, f of FileSystem._insts when f._data_to_send.length
            # if we are waiting for a session id, do not send the data
            # (@responseText will contain another call to @_timeout_send with the session id)
            if f._session_num == -1
                continue
            
            # for first call, do not add the session id (but say that we are waiting for one)
            if f._session_num == -2
                f._session_num = -1
            else
                f._data_to_send = "s #{f._session_num} " + f._data_to_send       
            
            
            # request
            path = ""
            if FileSystem.CONNECTOR_TYPE == "Browser"
                path = FileSystem.url_com
            else if FileSystem.CONNECTOR_TYPE == "Node"
                path = "http://" + FileSystem._url + ":" + FileSystem._port + FileSystem.url_com
             
            xhr_object = FileSystem._my_xml_http_request()
            xhr_object.open 'POST', path, true
            xhr_object.onreadystatechange = ->
                if @readyState == 4 and @status == 200
                    if FileSystem._disp
                        console.log "resp ->", @responseText
                        
                    _c = [] # callbacks
                    _w = ( sid, obj ) ->
                        if sid? and obj?
                            obj._server_id = sid
                            FileSystem._objects[ sid ] = obj
                    
                    FileSystem._sig_server = false
                    eval @responseText
                    FileSystem._sig_server = true
                    
                    for c in _c
                        FileSystem._callbacks[ c[ 0 ] ] FileSystem._objects[ c[ 1 ] ], c[ 2 ]
                        
            if FileSystem._disp
                console.log "sent ->", f._data_to_send + "E "
            xhr_object.setRequestHeader('Content-Type','text/plain')
            xhr_object.send f._data_to_send + "E "
            #console.log "-> ", f._data_to_send
            f._data_to_send = ""
            
        #
        FileSystem._objects_to_send = {}
        delete FileSystem._timer_send
    
    @_my_xml_http_request: ->
        if FileSystem.CONNECTOR_TYPE == "Browser"
            if window.XMLHttpRequest
                return new XMLHttpRequest
            if window.ActiveXObject
                return new ActiveXObject 'Microsoft.XMLHTTP'
            alert 'Your browser does not seem to support XMLHTTPRequest objects...'
            
        else if FileSystem.CONNECTOR_TYPE == "Node"
            return new FileSystem._XMLHttpRequest() 
          
        else
            console.log "you must define CONNECTOR_TYPE"
