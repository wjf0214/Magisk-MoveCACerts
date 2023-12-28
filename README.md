# MoveCACerts

这是一个 Magisk 模块，用于将自定义CA证书添加到系统信任存储区。安装完后需要重启手机.
支持安卓14

## 用法

1. `git clone https://github.com/wjf0214/Magisk-MoveCACerts.git` 或直接下载仓库 zip。
2. 将要添加的 Android 设备的CA证书（以 hash.0 命名）放进 `system/etc/security/cacerts` 目录。
3. 将 `Magisk-MoveCACerts` 目录中的所有文件打包，生成 `Magisk-MoveCACerts.zip` 文件。注意，请直接打包所有文件而不是打包 `Magisk-MoveCACerts` 项目的目录。
4. 将 `Magisk-MoveCACerts.zip` 导入到手机，在 Magisk 从本地选择 `Magisk-MoveCACerts.zip` 文件，安装模块。

⚠️ 注意：如果手机已经安装了模块，后续追加的证书可以直接放入 `/data/adb/modules/MoveCACerts/system/etc/security/cacerts/` 目录下，再重启手机即可。
