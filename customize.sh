##########################################################################################
#
# Magisk 模块安装脚本
# by wjf0214
#
##########################################################################################

##########################################################################################
#
# 使用说明:
#
# 1. 将文件放入系统文件夹(删除placeholder文件)
# 2. 在module.prop中填写您的模块信息
# 3. 在此文件中配置和调整
# 4. 如果需要开机执行脚本，请将其添加到post-fs-data.sh或service.sh
# 5. 将其他或修改的系统属性添加到system.prop
#
##########################################################################################

##########################################################################################
# 配置
##########################################################################################

# 如果您需要更多的自定义，并且希望自己做所有事情
# 请在custom.sh中标注SKIPUNZIP=1
# 以跳过提取操作并应用默认权限/上下文上下文步骤。
# 请注意，这样做后，您的custom.sh将负责自行安装所有内容。
SKIPUNZIP=0

# 如果您需要调用Magisk内部的busybox
# 请在custom.sh中标注ASH_STANDALONE=1
ASH_STANDALONE=0

# customize.sh 脚本在 Magisk 的 BusyBox ash shell 中运行，并启用“独立模式”。以下变量和函数可用：

##########################################################################################
# 变量:
##########################################################################################
# MAGISK_VER (string): 当前已安装 Magisk 的版本字符串
# MAGISK_VER_CODE (int): 当前已安装 Magisk 的版本代码
# BOOTMODE (bool): 如果当前正在 Magisk Manager 中安装该模块, 则为 true
# MODPATH (path): 该路径为模块文件的安装路径
# TMPDIR (path): 临时文件目录
# ZIPFILE (path): 该路径为你的模块安装包(zip 文件)的路径
# ARCH (string): 当前设备的架构. 该值可能为 arm, arm64, x86, 或 x64
# IS64BIT (bool): 如果 $ARCH 值为 arm64 或 x64, 则为 true
# API (int): 当前设备的 API 等级(Android 版本)
#

##########################################################################################
# 函数:
##########################################################################################
# ui_print <msg>
#     打印 <msg> 到终端
#     请避免使用 'echo', 因为它不会在第三方 Recovery 的终端中显示
#
# abort <msg>
#     打印错误信息 <msg> 到终端, 并终止安装
#     请避免使用 'exit', 因为这将会跳过终止清理步骤
#
# set_perm <target> <owner> <group> <permission> [context]
#     如果 [context] 参数为空, 则默认值为 "u:object_r:system_file:s0"
#     此函数是以下命令的简写
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     如果 [context] 参数为空, 则默认值为 "u:object_r:system_file:s0"
#     对于 <directory> 中的所有文件, 将会执行:
#       set_perm file owner group filepermission context
#     对于 <directory> 中的所有目录(包括目录本身), 将会执行:
#       set_perm dir owner group dirpermission context
#

##########################################################################################
# 替换列表
# 为了方便起见，您还可以在变量名称 REPLACE 中声明要替换的文件夹列表。模块安装程序脚本将在 REPLACE 中列出的文件夹中创建 .replace 文件。例如：
##########################################################################################

# 请按以下格式编写列表
# 这只是个示例
REPLACE_EXAMPLE="
/system/app/YouTube
/system/app/Bloatware
"
# 上面的列表将导致创建以下文件： $MODPATH/system/app/YouTube/.replace 和 $MODPATH/system/app/Bloatware/.replace 。

# 请在这里编写你自己的列表
REPLACE="
"

##########################################################################################
# 安装设置
##########################################################################################

# 如果SKIPUNZIP=1你将可能会需要使用以下代码
# 当然，你也可以自定义安装脚本，需要时请删除#
# 将 $ZIPFILE 提取到 $MODPATH
#  ui_print "- 解压模块文件"
#  unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2
# 删除多余文件
# rm -rf \
# $MODPATH/system/placeholder $MODPATH/customize.sh \
# $MODPATH/*.md $MODPATH/.git* $MODPATH/LICENSE 2>/dev/null


# 安装命令
ui_print "- Start installing the module"

ui_print "- Extract module certificate files"
unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

ui_print "- Deleting Placeholder Files"
rm -f $MODPATH/system/etc/security/cacerts/placeholder

ui_print "- Installation is successful, reboot the phone to check whether the CA certificate is added to the system trust store."

ui_print "- End installing the module"
ui_print "  by wjf0214 (github.com/wjf0214)"
ui_print " "


##########################################################################################
# 权限设置
##########################################################################################

# 请注意，magisk模块目录中的所有文件/文件夹都有$MODPATH前缀-在所有文件/文件夹中保留此前缀
# 一些例子:

# 对于目录(包括文件):
# set_perm_recursive  <目录>                <所有者> <用户组> <目录权限> <文件权限> <上下文> (默认值是: u:object_r:system_file:s0)

# set_perm_recursive $MODPATH/system/lib 0 0 0755 0644
# set_perm_recursive $MODPATH/system/vendor/lib/soundfx 0 0 0755 0644

# 对于文件(不包括文件所在目录)
# set_perm  <文件名>                         <所有者> <用户组> <文件权限> <上下文> (默认值是: u:object_r:system_file:s0)

# set_perm $MODPATH/system/lib/libart.so 0 0 0644
# set_perm /data/local/tmp/file.txt 0 0 644

# 默认权限请勿删除
set_perm_recursive $MODPATH 0 0 0755 0644