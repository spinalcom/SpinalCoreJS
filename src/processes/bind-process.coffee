# Copyright 2015 SpinalCom  www.spinalcom.com

# This file is part of SpinalCore.
#
# SpinalCore is licensed under the Free Software License Agreement
# that you should have received along with this file. If not, see
# <http://www.spinalcore.com/downloads/license.pdf>.



# permits to bind a function to a model
# f is the function which has to be binded
# onchange_construction true means that onchange will be automatically called after after the bind

root = global ? this

class root.BindProcess extends Process
    constructor: ( model, onchange_construction, @f ) ->
        super model, onchange_construction
    onchange: ->
        @f()
