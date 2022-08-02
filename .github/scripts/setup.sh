#!/usr/bin/env bash

GITHUB_OWNER=guionardo
GITHUB_REPOSITORY=python-package
GITHUB_URL=https://github.com/guionardo/python-package
GITHUB_DOCS_URL=https://guionardo.github.io/python-package
GITHUB_USERNAME="Guionardo Furlan"
GITHUB_EMAIL=guionardo@gmail.com

function check_git() {
    if [ ! -f .git/config ]; then
        echo "Git repository not found. Please run this script from the root of the repository."
        exit 1
    fi
    origin_url=$(git config --get remote.origin.url)
    if (echo "$origin_url" | grep -v -q "github.com"); then
        echo "Git repository is not on GitHub."
        exit 1
    fi
    if [[ $origin_url == git@* ]]; then
        pat='git@github.com:(.*)/(.*).git'
    else
        pat='https:\/\/github.com\/(.*)\/(.*).git'
    fi
    
    if [[ $origin_url =~ $pat ]]; then
        GITHUB_OWNER=${BASH_REMATCH[1]}
        GITHUB_REPOSITORY=${BASH_REMATCH[2]}
    else
        echo "Could not parse GitHub repository URL."
        exit 1
    fi
    
    GITHUB_USERNAME=$(git config --get user.name)
    if [ -z "$GITHUB_USERNAME" ]; then
        echo "Please set your GitHub username in ~/.gitconfig."
        exit 1
    fi
    
    GITHUB_EMAIL=$(git config --get user.email)
    if [ -z "$GITHUB_EMAIL" ]; then
        echo "Please set your GitHub email in ~/.gitconfig."
        exit 1
    fi
    
    GITHUB_URL="https://github.com/$GITHUB_OWNER/$GITHUB_REPOSITORY"
    GITHUB_DOCS_URL="https://$GITHUB_OWNER.github.io/$GITHUB_REPOSITORY"
    
    echo "*** GitHub repository infos ***"
    echo "GITHUB_OWNER      $GITHUB_OWNER"
    echo "GITHUB_REPOSITORY $GITHUB_REPOSITORY"
    echo "GITHUB_URL        $GITHUB_URL"
    echo "GITHUB_DOCS_URL   $GITHUB_DOCS_URL"
    echo "GITHUB_USERNAME   $GITHUB_USERNAME"
    echo "GITHUB_EMAIL      $GITHUB_EMAIL"
    echo "*******************************"
}

function create_setup_py() {
    setup_py=".github/setup.py"
    if [ -f "$setup_py" ]; then
        echo "$setup_py already exists."
        return
    fi
    echo "'''" > $setup_py
    echo "GitHub repository infos $(date +%c)" >> $setup_py
    echo "'''" >> $setup_py
    echo "" >> $setup_py
    echo "GITHUB_OWNER = '$GITHUB_OWNER'" >> $setup_py
    echo "GITHUB_REPOSITORY = '$GITHUB_REPOSITORY'" >> $setup_py
    echo "GITHUB_URL = '$GITHUB_URL'" >> $setup_py
    echo "GITHUB_DOCS_URL = '$GITHUB_DOCS_URL'" >> $setup_py
    echo "GITHUB_USERNAME = '$GITHUB_USERNAME'" >> $setup_py
    echo "GITHUB_EMAIL = '$GITHUB_EMAIL'" >> $setup_py
    
    echo "GitHub repository infos saved into $setup_py"
}

function update_badges() {
    updated="github.com/$GITHUB_OWNER/$GITHUB_REPOSITORY/actions/workflows"
    cat README.md | grep -Eo "(github\.com/[a-zA-Z0-9.]*/[a-zA-Z0-9_.-]*/actions/workflows)" | sort -u | while read -r url; do
        if [ $url == $updated ]; then
            continue
        fi
        echo "Updating URL $url -> $updated"
        
        cmd="s $url $updated g"
        sed -i "$cmd" README.md
    done
}


check_git
create_setup_py
update_badges