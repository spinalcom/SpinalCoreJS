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

# scalar
root = if typeof _root_obj == "undefined" then global else window

class root.ModelProcessManager
    # nb "change rounds" since the beginning ( * 2 to differenciate direct and indirect changes )
    @_counter: 0
    # changed models (current round)
    @_modlist: {}
    # new processes (that will need a first onchange call in "force" mode)
    @_n_processes: {}
    # current model id (used to create new ids)
    @_cur_mid: 0
    # current process id (used to create new ids)
    @_cur_process_id: 0
    # timer used to create a new "round"
    @_timeout: undefined
    # if _force_m == true, every has_been_modified function will return true
    @_force_m: false
    # synchronizer (link to the server that will store files)
    @_synchro: undefined

    # modify state according to str. str can be the result of a previous @get_state
    @new_from_state: ( str ) ->
        map = {}
        lst = str.split "\n"
        mid = lst.shift()
        for l in lst when l.length
            s = l.split " "
            map[ s[ 0 ] ] = {
                type: s[ 1 ]
                data: s[ 2 ]
                buff: undefined
            }
                
        # fill / update this with data in map[ mid ]
        eval "var __new__ = new #{map[ mid ].type};"
        __new__._set_state map[ mid ].data, map
        return __new__
        
    #
    @load: ( filename, func ) ->
        if not ModelProcessManager.synchronizer
            ModelProcessManager._synchro = new Synchronizer
        ModelProcessManager._synchro.load filename, func
        
        
    # If v is a Model, return v. Else, return a Model of guessed right type
    @conv: ( v ) ->
        if v instanceof Model
            return v
        if v instanceof Array
            return new Lst v
        if typeof v == "string"
            return new Str v
        if typeof v == "number"
            return new Val v
        if typeof v == "boolean"
            return new Bool v
        if v instanceof Object
            return new Model v
        return new Obj v

    # return the type of obj
    @get_object_class: ( obj ) ->
        if obj and obj.constructor
        # and obj.constructor.toString
            if obj.constructor.name
                return obj.constructor.name
            # arr = obj.constructor.toString().match ///(class|function)\s*(\w+)///
            # if arr and arr.length == 2
            #     return arr[ 1 ]

    @_get_attribute_names: ( m ) ->
        if m instanceof Model
            m._attribute_names
        else
            for key, val of m
                key

    # create a Model using a line of get_state (using .type, .data, ...)
    @_new_model_from_state: ( mid, map ) ->
        info = map[ mid ]
        eval "info.buff = new #{info.type};"
        info.buff._set_state info.data, map
        return info.buff
        
    # say that something will need a call
    # to ModelProcessManager._sync_processes during the next round
    @_need_sync_processes: ->
        if not ModelProcessManager._timeout?
            ModelProcessManager._timeout = setTimeout ModelProcessManager._sync_processes, 1

    # the function that is called after a very short timeout,
    # when at least one object has been modified
    @_sync_processes: ->
        processes = {}
        for id, model of ModelProcessManager._modlist
            for process in model._processes
                processes[ process.process_id ] = {
                    value: process
                    force: false
                }

        for id, process of ModelProcessManager._n_processes
            processes[ id ] = {
                value: process
                force: true
            }
        ModelProcessManager._timeout = undefined
        ModelProcessManager._modlist = {}
        ModelProcessManager._n_processes = {}
        ModelProcessManager._counter += 2

        for id, process of processes
            ModelProcessManager._force_m = process.force
            process.value.onchange()
                
        ModelProcessManager._force_m = false
