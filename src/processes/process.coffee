# Copyright 2015 SpinalCom  www.spinalcom.com

# This file is part of SpinalCore.
#
# SpinalCore is licensed under the Free Software License Agreement
# that you should have received along with this file. If not, see
# <http://www.spinalcore.com/downloads/license.pdf>.



# something which has to be synchronized with one or several model(s)
#
# Each process has an uniquer id called "process_id"

root = global ? this

class root.Process
    
    # m can be a model or a list of models
    constructor: ( m, onchange_construction = true ) ->
        #
        @process_id = ModelProcessManager._cur_process_id
        ModelProcessManager._cur_process_id += 1
        
        # what this is observing
        @_models = []
        
        # bind
        if m instanceof Model
            m.bind this, onchange_construction
        else if m.length?
            for i in m
                i.bind this, onchange_construction
        else if m?
            console.error "Process constructor doesn't know what to do with", m

    #
    destructor: ->
        for m in @_models
            i = m._processes.indexOf this
            if i >= 0
                m._processes.splice i, 1


    # called if at least one of the corresponding models has changed in the previous round
    onchange: ->


# bind model or list of model to function or process f
# (simply call the bind method of Model)
bind = ( m, f ) =>
    if m instanceof Model
        m.bind f
    else
        for i in m
            i.bind f
