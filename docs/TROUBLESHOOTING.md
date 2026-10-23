# 分层排障命令

先保存工作、准备有线输入，一次只改一个组件。取证可以用`bash scripts/collect-diagnostics.sh`，输出仅保存在本地，含潜在个人标识，分享前脱敏。

## 蓝牙无默认控制器

本机是PCIe `btintel_pcie`，不是USB蓝牙；lsusb无蓝牙并不说明未枚举。

```bash
rfkill list
lspci -nnk | grep -A4 -Ei 'network|bluetooth|wireless'
lsmod | grep -Ei 'btintel_pcie|btintel|bluetooth'
ls -la /sys/class/bluetooth/
bluetoothctl list
sudo journalctl -k -b --no-pager | grep -Ei 'bluetooth|btintel|hci[0-9]|firmware' | tail -n 100
```

已遇到：RFKill soft/hard=no；hci0存在；固件成功加载；随后Controller in error state、intel_reset1 timeout、Intel Soft Reset failed (-62)。这不是缺配对的证明，也不是必须重装BlueZ。之后SOF Bluetooth音频错误不能代替前面的首次故障。

手动恢复原命令（有线输入）：
```bash
sudo systemctl stop bluetooth
sudo modprobe -r btintel_pcie
sudo modprobe btintel_pcie
sudo systemctl start bluetooth
bluetoothctl list
bluetoothctl power on
```

modprobe卸载失败不force，恢复bluetooth.service并取证。不卸iwlwifi，不删`/var/lib/bluetooth`。历史错误留在journal；控制器已正常就不重复reload。新包装脚本只在控制器缺失、RFKill未锁且匹配错误签名时运行一次。

## 飞行模式

WMI quirk只处理键盘事件，独立于Xe和蓝牙Reset。
```bash
modinfo -n asus_nb_wmi
dkms status
rfkill list
```
需用实际键盘切换验收，不能仅凭DKMS installed。

## 下屏不亮

```bash
modinfo -n xe
cat /sys/module/xe/parameters/zenbook_duo_edp2_tcss
gdctl show
for d in /sys/class/drm/card*-eDP-2; do
  [ -d "$d" ] && { echo "$d"; cat "$d/status" "$d/enabled"; }
done
sudo tail -n 120 /var/lib/zenbook-duo/daemon.log
sudo journalctl -k -b --no-pager | grep -Ei 'PHY B|AUX B|DDI B|DPCD|flip_done|DSB.*timed out|TCSS' | tail -n 80
```

| 结果 | 下一步 |
|---|---|
| 原装模块路径、无运行参数 | 查DKMS、MOK、initramfs；别继续修改GNOME |
| updates/dkms + Y | 补丁有运行证据，不等于所有硬件路径健康 |
| PHY refclk/AUX/flip_done/DSB timeout | 停止重复modeset，保留日志 |
| connected+disabled | 可以是正常关闭，也可以是失败，不能单字段判断 |
| enabled且逻辑双屏、物理黑 | 查背光/显示链路，逻辑正常不能证明亮屏 |
| disabled+O=false+Skipping | 查关闭来源/事务，不能强改ownership |
| verify两屏false但gdctl上屏存在 | 查旧英文解析Bug是否被重新安装 |

`ACPI: SSDT ... TcssSsdt`是表信息，不是TCSS错误。筛选没报错也不等于全健康。Caps Lock有效只说明部分输入/系统仍响应，不足以断言是GNOME坏。

TTY `Ctrl+Alt+F3`可用时先保存日志。不要在运行图形会话中卸载Xe，不循环gdctl恢复。

## 中文GNOME解析

旧代码匹配`eDP-1 (Built-in display)`，中文是`eDP-1 (内置显示器)`。关屏成功但verify失败→不记录O→detach阻断。固定提交e0b11760…修复connector精确匹配。不要把改英文或删guard当修复。

```bash
git -C ~/zenbook-duo26-Ubuntu26.04 rev-parse HEAD
systemctl --user status zenbook-duo-session-agent.service
```

HEAD不能代替运行二进制hash，检查实际部署。

## 上屏倒置

本基准eDP-1需要180°。先检查是否新增全局方向，不立刻改用户持久布局：
```bash
cat /proc/cmdline
sudo grep -RnsE 'panel_orientation|fbcon=rotate|video=eDP|rotate=180' \
  /etc/default/grub /etc/default/grub.d /etc/kernel /etc/modprobe.d /etc/initramfs-tools 2>/dev/null
```

备份找到的实际配置，只撤销本次添加的`video=eDP-1:panel_orientation=upside_down`，保留背光参数，再`sudo update-grub`，人工重启。不要编辑生成的grub.cfg，也不要删其他video配置。fbcon=rotate主要影响文本控制台，不能直接当同一根因。

## Rust Cargo / gobject-sys 构建失败

2026-10-23 安装阶段报告 `Cargo is still unavailable`，随后 `failed to run custom build command for gobject-sys v0.18.0`。二者是不同阶段的问题：前者涉及 Rust 工具链/PATH/目标用户；后者通常涉及系统 pkg-config 与 GLib/GTK 库，但需要 Cargo 的 `--- stderr` 确诊。

```bash
whoami
command -v cargo
cargo --version
pkg-config --modversion glib-2.0 gobject-2.0 gtk+-3.0 webkit2gtk-4.1
dpkg-query -W pkg-config libglib2.0-dev libgtk-3-dev libwebkit2gtk-4.1-dev 2>&1
```

没有找到 `gobject-2.0.pc` 时优先安装 `pkg-config libglib2.0-dev`；因该项目 `Cargo.toml` 依赖 Tauri 2 且选择 `--skip-ui` 也会编译相关 crate，参照 [重装第 5.0 节](REINSTALL.md#50-首次编译前补齐-rusttauri-系统依赖) 安装其余官方 Linux 开发依赖。修复后在**同一个普通用户**会话下重新运行安装器，不使用 `sudo cargo build`；已有成功构建的依赖会由 Cargo 复用。

若 pkg-config 均成功仍失败，应保留完整 `--- stdout` 与 `--- stderr`、crate 版本、`pkg-config` 输出，不要只用顶层一句 `failed to run custom build command` 推断原因。这里的解决方案目前是源码分析与官方文档依据，**尚未收到这次重装的成功验收回报**。

## 服务/权限/初始化

```bash
systemctl status zenbook-duo-rust-daemon.service
systemctl show zenbook-duo-rust-lifecycle.service -p ActiveState -p SubState -p Result -p ExecMainStatus
systemctl --user status zenbook-duo-session-agent.service
```

active/exited是lifecycle设计。unit不存在先看安装日志，别反复enable。Wayland不照抄Xorg xrandr方案。显示设置卡顿也可能是等待KMS。

MOK文字enrolled但exit1已在现场出现；使用导出DER精确匹配+keypair校验，不重复无依据导入。3cpio Permission denied是v2读取root-only initrd的权限Bug。Dracut蓝牙提示不证明桌面蓝牙缺驱动。

## 关机/reboot被阻止

```bash
systemd-inhibit --list
gnome-session-inhibit --list
systemctl reboot
```

GNOME session inhibitor是保护，不是Xe安装失败。不加sudo可先尝试，但不保证绕过。保存工作、确认安装成功后，人工才用：
```bash
sudo systemctl reboot -i
# 或
sudo systemctl poweroff -i
```

不将-i写成默认安装行为，不全局关闭会话保护。

## 完全关机与EC复位

温重启可能保留异常状态。正常poweroff、移开键盘、断开外接供电/扩展坞再启动曾用于恢复；拔充电器不等于内部电池断电。社区15秒按电源建议不是已确认适用于所有UX8407AA的ASUS官方EC流程，不在脚本自动执行。具体EC reset依型号官方说明。

冷启动暂时恢复不等于永久驱动修复；新内核/会话仍要验收。
