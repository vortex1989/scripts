#!/bin/bash
# vim:fdm=marker
ERRMSG_WRONGDIR='You are not under octopress directory'
[ ! -f _config.yml ] && echo ${ERRMSG_WRONGDIR} && exit

BLOGDIR=${PWD}

deploy(){
  git checkout source
 git push origin source
 rake generate
  rake deploy
}

update_octopress(){
  echo 'upgrading octopress source'
  git pull octopress master     # Get the latest Octopress
  bundle install                # Keep gems updated
  rake update_source            # update the template's source
  rake update_style             # update the template's style
}

preview(){
  rake preview &
  sleep 1
  sensible-browser 127.0.0.1:4000
}

upgrade(){
  update_octopress
  deploy
}

# start to write new post
# @param: post title
post(){
  local title=${1?"requires title"}
  _new_item post ${title}
}

# start to write new page
# @param: page title
page(){
  _new_item page $1
}

_new_item(){
  local tmpfile=`mktemp`
  local item_name=${1?"requires item name"}
  local title=${2?"requires title"}
  rake new_${item_name}["\"${title}\""] | tee ${tmpfile}
  local file=`cat ${tmpfile} | awk -F: '{print $2}' | sed -e 's/ //'`
  sensible-editor ${BLOGDIR}/$file
  rm ${tmpfile}
  # return file name
  RET=${file}
}

# Main
# ----
actions="post upgrade preview deploy"
action=${1?"requirs action!, avaliabl actions are ${actions}"}

# run action
shift
${action} $@