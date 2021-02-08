#!/bin/sh

#
############ ASUSHI TOOLS ############
#
#
#
VERSION=0.0.1
#
COLOR_SUFFIX="\033[0m"
COLOR_PREFIX_RED="\033[31m"
COLOR_PREFIX_GREEN="\033[32m"
COLOR_PREFIX_YELLO="\033[33m"
COLOR_PREFIX_BLUE="\033[36m"
#
#
#
show_tasks() {
  echo "
${COLOR_PREFIX_BLUE}############ ASUSHI TOOLS ############${COLOR_SUFFIX}
"
  echo "${COLOR_PREFIX_GREEN}「fd」${COLOR_SUFFIX}\tFormat USB storage\t格式化U盘"
  echo ""
  echo "${COLOR_PREFIX_GREEN}「q」${COLOR_SUFFIX}\tQuit / Exit\t终止程序"
  echo "${COLOR_PREFIX_GREEN}「a」${COLOR_SUFFIX}\tAbout ASUSHI\t关于 ASUSHI"
  echo "${COLOR_PREFIX_BLUE}\nSelect a task: ${COLOR_SUFFIX}"
  select_task
}
#
#
#
select_task() {
  read TASK_SELECTED
  until [ "$TASK_SELECTED" = q ] || [ "$TASK_SELECTED" = a ] || [ "$TASK_SELECTED" = fd ]; do
    echo "${COLOR_PREFIX_RED}Oops, something went wrong, please try again: ${COLOR_SUFFIX}"
    read TASK_SELECTED
  done
  if [ "$TASK_SELECTED" = q ]; then
    echo "\nGoodbye."
    exit 0
  elif [ "$TASK_SELECTED" = a ]; then
    about
  elif [ "$TASK_SELECTED" = fd ]; then
    format_disk
  fi
}
#
#
#
about() {
  echo "\n${COLOR_PREFIX_YELLO}ASUSHI / A SUSHI${COLOR_SUFFIX} is a manager for routers running Asuswrt or Asuswrt-Merlin."
  echo "\n${COLOR_PREFIX_GREEN}「HOME PAGE」${COLOR_SUFFIX}\thttps://github.com/imzue/asushi"
  echo "${COLOR_PREFIX_GREEN}「ISSUES」${COLOR_SUFFIX}\thttps://github.com/imzue/asushi/issues"
  echo "${COLOR_PREFIX_GREEN}「CONTRIBUTORS」${COLOR_SUFFIX}\thttps://github.com/imzue"
  echo "${COLOR_PREFIX_GREEN}「LICENSE」${COLOR_SUFFIX}\tMIT License"
  echo "${COLOR_PREFIX_GREEN}「VERSION」${COLOR_SUFFIX}\t${VERSION}"

  echo "\n${COLOR_PREFIX_GREEN}「r」${COLOR_SUFFIX}\tBack to task menu\t返回菜单"
  echo "${COLOR_PREFIX_GREEN}「q」${COLOR_SUFFIX}\tQuit / Exit\t终止程序"
  read ABOUT_TASK_SELECTED
  until [ "$ABOUT_TASK_SELECTED" = q ] || [ "$ABOUT_TASK_SELECTED" = r ]; do
    echo "${COLOR_PREFIX_RED}Oops, something went wrong, please try again: ${COLOR_SUFFIX}"
    read ABOUT_TASK_SELECTED
  done

  if [ "$ABOUT_TASK_SELECTED" = q ]; then
    echo "\nGoodbye."
    exit 0
  elif [ "$ABOUT_TASK_SELECTED" = r ]; then
    show_tasks
  fi
}
#
#
#
format_disk() {
  printf "
=======================================================================
                          ASUSHI TOOLS

    1. 将格式化U盘并重新分区，使用前务必先备份U盘内数据；
    2. 建议上传至路由器 /tmp/ 目录后执行，不能在U盘内执行。

    1. It will format and re-partition your USB storage, 
    be sure to backup your data before.
    2. It is recommended to upload to the router /tmp/ directory
    and then run, cannot run in the USB storage.
=======================================================================
"
  echo -e "\n${COLOR_PREFIX_BLUE}You have read the above notices and confirmed [y/n]: ${COLOR_SUFFIX}"
  read NOTICES_CONFIRMED
  until [ $NOTICES_CONFIRMED == y -o $NOTICES_CONFIRMED == n ]; do
    echo -e "${COLOR_PREFIX_RED}Oops, something went wrong, please try again [y/n]: ${COLOR_SUFFIX}"
    read NOTICES_CONFIRMED
  done
  if [ $NOTICES_CONFIRMED == n ]; then
    exit 0
  fi
}
#
#
#
show_tasks
