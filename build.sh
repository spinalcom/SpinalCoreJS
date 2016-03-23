#!/bin/bash

# TODO: Modularize npm module to get rid of concatenating dependencies

# Build SpinalCore node module from CoffeeScript
buildForNode()
{
    cat extras/license_template.txt > lib/spinalcore.node.js;
    cat src/index.coffee src/model-process-manager.coffee src/models/model.coffee src/models/model.obj.coffee src/models/model.choice.coffee src/models/model.bool.coffee src/models/model.constrained-val.coffee src/models/model.lst.coffee src/models/model.val.coffee src/models/model.str.coffee src/file-system/*.coffee src/file-system/models/*.coffee src/processes/p* src/processes/b* | $(npm bin)/coffee -bc --stdio >> lib/spinalcore.node.js
}

# Build SpinalCore for browser from node module
buildForBrowser()
{
    buildForNode;
    echo "$($(npm bin)/browserify extras/browser.js)" > lib/spinalcore.browser.js;
}

# Main
if [[ $1 == "--browser" ]]; then
    buildForBrowser;
else
    buildForNode;
fi
