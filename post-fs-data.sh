#!/system/bin/sh

# 不要假设您的模块将位于何处。
# 如果您需要知道此脚本和模块的放置位置，请使用$MODDIR
# 这将确保您的模块仍能正常工作
# 即使Magisk将来更改其挂载点

# 此脚本将在post-fs-data模式下执行

exec > /data/local/tmp/MoveCACerts.log
exec 2>&1

# set -x

MODDIR=${0%/*}

TEMP_DIR=/data/local/tmp/cacerts_copy

set_context() {
    # 判断当前SELinux的应用模式
    [ "$(getenforce)" = "Enforcing" ] || return 0

    default_selinux_context=u:object_r:system_file:s0
    selinux_context=$(ls -Zd $1 | awk '{print $1}')

    if [ -n "$selinux_context" ] && [ "$selinux_context" != "?" ]; then
        chcon -R $selinux_context $2
    else
        chcon -R $default_selinux_context $2
    fi
}

echo "[$(date +%F) $(date +%T)] - MoveCACerts post-fs-data.sh start."

chown -R 0:0 ${MODDIR}/system/etc/security/cacerts

if [ -d /apex/com.android.conscrypt/cacerts ]; then
    # 检测是否存在 android 14 以上版本
    echo "[$(date +%F) $(date +%T)] - Android version 14 or higher detected"

    # 创建临时目录
    rm -rf "$TEMP_DIR"
    mkdir -p -m 700 "$TEMP_DIR"
    mount -t tmpfs tmpfs "$TEMP_DIR"

    # 复制当前系统证书到临时目录
    cp -f /apex/com.android.conscrypt/cacerts/* ${TEMP_DIR}

    # 复制 Magisk 模块下证书到临时目录
    cp -f ${MODDIR}/system/etc/security/cacerts/* ${TEMP_DIR}

    chown -R 0:0 "$TEMP_DIR"
    set_context /apex/com.android.conscrypt/cacerts "$TEMP_DIR"

    # 检查新证书是否成功添加，如果添加成功，则在APEX中挂载目录，并删除临时目录。
    CERTS_NUM="$(ls -1 "$TEMP_DIR" | wc -l)"
    if [ "$CERTS_NUM" -gt 10 ]; then
        mount -o bind "$TEMP_DIR" /apex/com.android.conscrypt/cacerts
        for pid in 1 $(pgrep zygote) $(pgrep zygote64); do
            nsenter --mount=/proc/${pid}/ns/mnt -- \
                mount --bind "$TEMP_DIR" /apex/com.android.conscrypt/cacerts
        done
        echo "[$(date +%F) $(date +%T)] - The number of certificates is: $CERTS_NUM ,Mounted successfully!"
    else
        echo "[$(date +%F) $(date +%T)] - The number of certificates is: $CERTS_NUM , the number is too low, for security reasons, cancel the replacement of CA storage"
    fi

    # 删除临时目录
    umount "$TEMP_DIR"
    rmdir "$TEMP_DIR"
else
    # 非 Android 14 版本
    echo "[$(date +%F) $(date +%T)] - Android version lower than 14 detected"
    set_context /system/etc/security/cacerts ${MODDIR}/system/etc/security/cacerts
fi
