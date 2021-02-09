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
# KERNEL_VERSION: 内核版本号
# KERNEL_VERSION: Kernel version
#
KERNEL_VERSION="$(uname -r)"
#
#
#
show_tasks() {
  echo -e "
${COLOR_PREFIX_BLUE}############ ASUSHI TOOLS ############${COLOR_SUFFIX}
"
  echo -e "${COLOR_PREFIX_GREEN}「fd」${COLOR_SUFFIX}\tFormat USB storage\t格式化U盘"
  echo -e ""
  echo -e "${COLOR_PREFIX_GREEN}「q」${COLOR_SUFFIX}\tQuit / Exit\t终止程序"
  echo -e "${COLOR_PREFIX_GREEN}「a」${COLOR_SUFFIX}\tAbout ASUSHI\t关于 ASUSHI"
  echo -e "${COLOR_PREFIX_BLUE}\nSelect a task: ${COLOR_SUFFIX}"
  select_task
}
#
#
#
select_task() {
  read TASK_SELECTED
  until [ "$TASK_SELECTED" = q ] || [ "$TASK_SELECTED" = a ] || [ "$TASK_SELECTED" = fd ]; do
    echo -e "${COLOR_PREFIX_RED}Oops, something went wrong, please try again: ${COLOR_SUFFIX}"
    read TASK_SELECTED
  done
  if [ "$TASK_SELECTED" = q ]; then
    echo -e "\nGoodbye."
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
task_end() {
  echo -e "\n${COLOR_PREFIX_GREEN}「r」${COLOR_SUFFIX}\tBack to task menu\t返回菜单"
  echo -e "${COLOR_PREFIX_GREEN}「q」${COLOR_SUFFIX}\tQuit / Exit\t终止程序"
  read ABOUT_TASK_SELECTED
  until [ "$ABOUT_TASK_SELECTED" = q ] || [ "$ABOUT_TASK_SELECTED" = r ]; do
    echo -e "${COLOR_PREFIX_RED}Oops, something went wrong, please try again: ${COLOR_SUFFIX}"
    read ABOUT_TASK_SELECTED
  done

  if [ "$ABOUT_TASK_SELECTED" = q ]; then
    echo -e "\nGoodbye."
    exit 0
  elif [ "$ABOUT_TASK_SELECTED" = r ]; then
    show_tasks
  fi
}
#
#
#
about() {
  echo -e "\n${COLOR_PREFIX_YELLO}ASUSHI / A SUSHI${COLOR_SUFFIX} is a manager for routers running Asuswrt or Asuswrt-Merlin."
  echo -e "\n${COLOR_PREFIX_GREEN}「HOME PAGE」${COLOR_SUFFIX}\thttps://github.com/imzue/asushi"
  echo -e "${COLOR_PREFIX_GREEN}「ISSUES」${COLOR_SUFFIX}\thttps://github.com/imzue/asushi/issues"
  echo -e "${COLOR_PREFIX_GREEN}「CONTRIBUTORS」${COLOR_SUFFIX}\thttps://github.com/imzue"
  echo -e "${COLOR_PREFIX_GREEN}「LICENSE」${COLOR_SUFFIX}\tMIT License"
  echo -e "${COLOR_PREFIX_GREEN}「VERSION」${COLOR_SUFFIX}\t${VERSION}"

  task_end
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

  echo -e "\n${COLOR_PREFIX_BLUE}USB storage list: ${COLOR_SUFFIX}"
  USB_DEVICE_COUNT=0
  USB_DRIVE_LIST
  for USB_PATH in $(nvram show 2>/dev/null | grep '^usb_path.*=storage' | cut -d= -f1); do
    USB_ACT=$(nvram get ${USB_PATH}_act)
    USB_DEV="/dev/${USB_ACT}"
    USB_DRIVE_LIST="Disk ${USB_DEV};${USB_DRIVE_LIST}"
    USB_MANUFACTURER="$(nvram get ${USB_PATH}_manufacturer | xargs)"
    USB_PRODUCT="$(nvram get ${USB_PATH}_product | xargs)"
    USB_NAME="$USB_MANUFACTURER $USB_PRODUCT"
    if [ -z "$USB_MANUFACTURER" ]; then
      USB_NAME="$USB_PRODUCT"
    fi
    USB_DEVICE_COUNT=$((USB_DEVICE_COUNT + 1))
    echo -e "${COLOR_PREFIX_GREEN}${USB_DEV}${COLOR_SUFFIX}\t${USB_NAME}"
  done

  if [ "$USB_DEVICE_COUNT" = 0 ]; then
    echo -e "${COLOR_PREFIX_RED}No USB storage device has been found! ${COLOR_SUFFIX}"
    exit 1
  fi

  echo -e "\n${COLOR_PREFIX_BLUE}Please choose a USB storage device (e.g., /dev/sda and q to quit): ${COLOR_SUFFIX}"
  read USB_DRIVE
  if [ "$USB_DRIVE" = q ]; then
    exit 0
  fi

  echo "${USB_DRIVE_LIST}"

  until echo $USB_DRIVE_LIST 2>/dev/null | grep "Disk $USB_DRIVE;" &>/dev/null; do
    echo -e "${COLOR_PREFIX_RED}Oops, something went wrong, please try again (e.g., /dev/sda or q to quit): ${COLOR_SUFFIX}"
    read USB_DRIVE
    if [ $USB_DRIVE == q ]; then
      exit 0
    fi
  done
  #
  # USB_DRIVE_LABEL: U盘卷标
  # USB_DRIVE_LABEL: USB storage device volume label
  #
  USB_DRIVE_LABEL="ASUSHI"
  ASUSHI_ROOT="/tmp/mnt/${USB_DRIVE_LABEL}"
  #
  # USB_DRIVE_PARTITION: U盘第一分区
  # USB_DRIVE_PARTITION: The first partition of the USB storage device
  #
  USB_DRIVE_PARTITION="${USB_DRIVE}1"
  #
  #
  # USB_DRIVE_FILESYSTEM: U盘文件系统
  # USB_DRIVE_FILESYSTEM: USB storage device filesystem
  #
  USB_DRIVE_FILESYSTEM="ext4"
  #
  # PROC_FILESYSTEM_EXT4: 是否支持 ext4
  # PROC_FILESYSTEM_EXT4: Whether to support ext4
  #
  PROC_FILESYSTEM_EXT4="$(grep 'ext4' "/proc/filesystems")"
  if [ -z "${PROC_FILESYSTEM_EXT4}" ]; then
    USB_DRIVE_FILESYSTEM="ext3"
  fi
  #
  # Unmount all USB storage devices
  #
  if [ -z "$(which ejusb)" ]; then
    echo -e "\n${COLOR_PREFIX_BLUE}Use \`umount\` to unmount the USB storage devices... ${COLOR_SUFFIX}"
    echo -e "${COLOR_PREFIX_YELLOW}[WARNING]: This operation may fail. If it fails, please manually unmount the USB storage device and run again. ${COLOR_SUFFIX}"
    while mount | grep "$USB_DRIVE" >/dev/null 2>&1; do
      for i in $(mount | grep "$USB_DRIVE" | awk '{print $1}'); do
        umount -f $i >/dev/null
        sleep 2
      done
    done
  else
    echo -e "\n${COLOR_PREFIX_BLUE}Unmounting all USB storage devices... ${COLOR_SUFFIX}"
    ejusb -1
    sleep 5
  fi
  #
  echo -e "\n${COLOR_PREFIX_BLUE}Repartitioning ${USB_DRIVE}... ${COLOR_SUFFIX}"
  fdisk $USB_DRIVE <<EOF
u
p
o
n
p
1
2048

p
wq
EOF
  #
  if [ ${?} -ne 0 ]; then
    echo -e "${COLOR_PREFIX_RED}Oops, cannot repartition ${USB_DRIRVE}, please try again. ${COLOR_SUFFIX}"
    exit 2
  fi
  #
  if [ ! -d "${ASUSHI_ROOT}" ]; then
    mkdir -m 777 "${ASUSHI_ROOT}"
  fi
  #
  mount "${USB_DRIVE_PARTITION}" "${ASUSHI_ROOT}" 2>/dev/null
  #
  echo -e "\n${COLOR_PREFIX_BLUE}Success! ${ASUSHI_ROOT} is ready. ${COLOR_SUFFIX}"
  #
  task_end
}
#
#
#
show_tasks
