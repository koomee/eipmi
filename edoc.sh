#!/bin/bash

# Script to generate EDoc documentation and optionally deploy it
# to the github gh-pages branch. The current branch must be clean
# when executing this script.
# Usage:
#   ./edoc.sh        - will only generate the documentation
#   ./edoc.sh deploy - will do the above and deploy to github

mkdir -p tmp
mkdir -p doc

# get edown from github
git clone https://github.com/hdiedrich/markedoc.git tmp

# preprocess README.md because markdown.sed can't handle code blocks
perl -pi.bak -e "s/\`\`\`/\'\'\'/g" README.md
perl -pi -e "s/\'\'\'erlang/\`\`\`/g" README.md

# create overview.edoc
echo "@title EIPMI - A native Erlang IMPI library" > doc/overview.edoc
echo "@copyright 2012 Lindenbaum GmbH" >> doc/overview.edoc
echo "" >> doc/overview.edoc
sed -r -f tmp/bin/markedoc.sed README.md >> doc/overview.edoc

# restore original README.md
mv README.md.bak README.md

# create edoc and cleanup
rebar clean compile doc
rm -rf tmp

# deploy to gh-pages
if [ "$1" == "deploy" ]; then
    CURRENT=`git branch | grep "*" | awk '{print $2}'`
    git checkout gh-pages
    rm *.html
    rm edoc-info
    rm erlang.png
    rm stylesheet.css
    cp doc/* .
    git add .
    git commit -a -m "Regenerated site documentation."
    git push origin gh-pages
    git checkout $CURRENT
fi