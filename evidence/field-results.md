# 会话现场证据摘录（脱敏）

以下来自用户终端输出与实机反馈，不是本次打包重新运行。省略个人路径、root UUID、主机名、boot ID及MAC。

## 补丁前/后

```text
uname -r: 7.0.0-38-generic
原Xe: /lib/modules/7.0.0-38-generic/kernel/drivers/gpu/drm/xe/xe.ko.zst
DKMS当时仅asus-nb-wmi-ux8407aa/0.1.0（34和38内核）
TCSS参数: No such file or directory
```

v3完成并重启后的用户输出：
```text
/lib/modules/7.0.0-38-generic/updates/dkms/xe.ko.zst
Y
```

## MOK与v2回滚

```text
MOK.der is already enrolled
MOK_EXIT=1
PRIVATE_KEY_EXIT=0
SecureBoot enabled
```

改为导出DER比对后：
```text
MOK verified: exact DER certificate is present in enrolled MokListRT.
Upstream commit: cc65948bfb921483336d7174b7ef4afce8e3431f
Building module(s) ... done.
Signing module .../xe.ko
Installing .../updates/dkms/xe.ko.zst
3cpio: Failed to open /boot/initrd.img-7.0.0-38-generic: Permission denied
Installation aborted (exit 1). Removing this DKMS override if added.
EXIT=1
```

因此v2不是编译不兼容，而是检查权限失败；v3改sudo lsinitramfs。

## 中文解析与归属

```text
Logical monitors:
  eDP-1 (内置显示器)
eDP-2: connected / disabled
secondaryPanelDisabledByRuntime: False
secondaryPanelDisabledByRuntimeBootId: None
GNOME dock-mode verify failed (attached=true, logical_edp1=false, logical_edp2=false)
Skipping automatic dual-screen enable
```

Codex报告仅改session_agent.rs，runtime57/57，release构建成功，单二进制备份/替换。用户实机确认下屏亮；关屏O=true，开屏O=false。公开提交e0b11760…。

## 蓝牙

```text
PCI 0000:00:14.7 Intel CNVi Bluetooth [8086:e476]
Kernel driver in use: btintel_pcie
hci0 Soft blocked: no / Hard blocked: no
Found device firmware: intel/ibt-00a0-0291-pci.sfi
Firmware loaded ...
Device booted ...
Controller in error state
Timeout (3000 ms) on alive interrupt, alive context: intel_reset1
Intel Soft Reset failed (-62)
```

用户执行stop bluetooth、modprobe -r/+ btintel_pcie、start bluetooth后反馈“有效”。之后一次冷启动蓝牙正常，另一次同错误复发。自动恢复zip已交付，无后续安装验收证据。

## 冷启动与GDM

用户确认键盘盖着poweroff后启动，蓝牙正常，拿开下屏亮，盖上正常关闭。随后GDM单屏方案导致开机下屏已关、无runtime归属，拿开被拦；GDM回滚后恢复。

第二轮审计又见attached/disabled/unowned且原GDM已恢复，缺当次E采样，不能唯一归因。一次PASS不能替代全入口和长期验证。
