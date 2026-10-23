# 重装恢复：逐阶段执行

来源：本会话实机记录与已交付脚本。顺序是本次整理的恢复流程，不代表从零重装已再次实测。新包装脚本和原附件的区别见 [VALIDATION](VALIDATION.md)。

## 0. 擦盘前：备份，不只保存这个仓库

先将整盘镜像和关键配置保存到外置盘。仓库不包含 MOK 私钥、蓝牙配对密钥、原 GDM XML、用户 XML、已安装二进制或 initrd。见 [备份手册](BACKUP-UPDATES.md)。

安装官方 Ubuntu 介质。**精确复现要求运行 `7.0.0-38-generic`，可取得 `linux-source-7.0.0=7.0.0-38.38` 和匹配 headers，且保留第二个可启动原装内核。** 如果以后默认内核不同，停止本仓库 Xe 安装步骤；不能改版本检查后硬装，更不能长期为复现旧配置放弃安全更新。

ASUS USB 启动及 Win11 恢复是独立事项，见 [USB-WINDOWS](USB-WINDOWS.md)。

## 0.5. LiveUSB 安装界面上下倒置：在开始安装前临时旋转

**这是「Try Ubuntu」Live 会话阶段的操作，不是安装完成后执行的持久双屏配置。** 本机在 2026-10-21 安装 Ubuntu 26.04.1 的记录为：Live USB 初始上屏画面倒置、当时只显示一块屏；安装后才继续识别和配置两块屏。原会话当时提供过 GNOME 设置界面的临时修正方法；以下 `gdctl` 单屏命令则是根据安装后已经验证的语法整理的**备用方法，未单独在 LiveUSB 实机验收**。

1. 完全关机，先把触点键盘从下屏移开再启动 LiveUSB（**修复 Xe 之前不要以键盘盖着下屏的状态测试冷启动**）；准备有线 USB 键盘/鼠标，防止蓝牙和触屏方向影响操作。正常进入 Ubuntu Live 桌面，若自动出现安装器，先返回桌面或暂时最小化安装器。
2. 虽然屏幕上下反转，仍可按 **Ctrl+Alt+T** 打开终端，运行：

```bash
gnome-control-center display
```

3. 在 **Settings → Displays（设置 → 显示）** 中选择当前发光的**物理上屏**，将方向（Orientation）设置为 **Landscape (flipped)**（横向翻转，即 180°），点击 **Apply**，再点 **Keep Changes** 确认。屏幕转正后回到安装器，正常安装 Ubuntu。**不要只因为 GNOME 显示器编号是 1/2 就推断它对应 eDP-1/eDP-2。**
4. 如果 Live 桌面没有提供该 GUI 选项，并且当前确实进入 **GNOME Wayland 会话**、`gdctl show` 可运行、输出显示 **eDP-1 就是当前唯一有效的上屏**，可使用以下备用命令。执行前先只读核对：

```bash
echo "$XDG_SESSION_TYPE"
command -v gdctl
gdctl show
```

确认无误后，**先 verify、再实际设置**；如检查失败就停止，不要尝试强制点亮下屏：

```bash
gdctl set --verify \
  --logical-monitor --primary --monitor eDP-1 \
  --transform 180 --scale 1.6666666269302368

gdctl set \
  --logical-monitor --primary --monitor eDP-1 \
  --transform 180 --scale 1.6666666269302368
```

这组备用命令只调整当前 Live 会话的单个逻辑显示器：**不加入 eDP-2、不使用 `--persistent`、不写 `monitors.xml`、不修改 GDM/GRUB/内核参数**。如果 `gdctl` 不存在、会话不是 GNOME Wayland、输出和当前硬件不一致，跳过此方法，使用 GUI 或外接屏/鼠标继续安装，不要猜测接口名称。

5. **LiveUSB 中的屏幕方向是临时设置**：重启、结束 Live 会话或切入正式安装系统后一般不保留。安装完成进入真正的 Ubuntu GNOME 桌面后，再继续下文 **第 1 节**做正式持久配置；**不要把 LiveUSB 的单屏配置复制给 GDM**。

### 安装期禁止事项

- 不要为了让安装界面转正加入 `video=eDP-1:panel_orientation=upside_down`、`fbcon=rotate` 等未经当前基线验证的启动参数；之前将内核 panel orientation 与 GNOME 180° 同时使用曾出现双重旋转。
- **不要在未加载 Xe TCSS 补丁的 LiveUSB 里反复强制开启 eDP-2**。此次要求只是让安装界面可操作，未在安装期解决下屏冷启动。
- 如果出现桌面冻结、`gdctl` 超时、面板黑屏，不继续反复 modeset。先保证可用的 Live 上屏和安装数据安全，必要时重新以键盘移开的状态启动 LiveUSB。

参考：正式 GNOME 双屏命令见下一节；LiveUSB 启动入口另见 [USB-WINDOWS](USB-WINDOWS.md)。

## 1. 安装完成后的初始显示：先有一个可用桌面

未打补丁前，键盘拿开后开机，准备 USB 键盘/鼠标。Live USB 当时只显示一块屏，安装后才两块；GNOME 的数字编号不能当作 eDP 接口编号。

```bash
echo "$XDG_SESSION_TYPE"
uname -r
gdctl show
cat /proc/cmdline
```

本机已确认上屏 eDP-1、下屏 eDP-2。两屏都已能显示、没有自动切屏服务运行时，先验证：

```bash
gdctl set --verify \
  --logical-monitor --primary --monitor eDP-1 \
  --transform 180 --scale 1.6666666269302368 \
  --logical-monitor --monitor eDP-2 --below eDP-1 \
  --transform normal --scale 1.6666666269302368
```

验证通过且桌面没有冻结，再执行同一条命令，将 `--verify` 换为 `--persistent`。这保存的是用户桌面配置，**不要把生成的单屏 XML 复制给 GDM**。如果下屏 disabled、显示卡顿或发生 timeout，不把这条命令作为反复强制唤醒工具。

本基准不要加 `video=eDP-1:panel_orientation=upside_down`；它曾与桌面的 180° 校正冲突。保留已用的 `xe.enable_dpcd_backlight=3`。

## 2. 下载恢复仓库和固定上游

```bash
sudo apt update
sudo apt install git python3
git clone https://github.com/cwangfr/zenbook_duo26_setup.git
cd zenbook_duo26_setup
bash scripts/test-static.sh
bash scripts/preflight.sh
bash scripts/fetch-upstream.sh runtime
bash scripts/fetch-upstream.sh xe
```

固定 checkout 为 `~/zenbook-duo26-Ubuntu26.04` 与 `~/zenbook-duo-2026-linux`。已有目录若提交不同、origin 不同或有本地修改，脚本拒绝覆盖；不要 reset 或删除自己的修复。固定版本见 [sources.lock.json](../config/sources.lock.json)。

## 3. ASUS WMI 飞行模式修复

这只修键盘插拔误触发 RFKill，不修 Xe 或蓝牙 Intel Reset。

```bash
cd ~/zenbook-duo26-Ubuntu26.04/ux8407aa-asus-nb-wmi-quirk
./scripts/install.sh
```

上游脚本验证 DMI，安装 DKMS 与当前 headers，构建 `asus-nb-wmi-ux8407aa/0.1.0`。此源基线为 7.0，不假设未来版本仍适用。

保持 Secure Boot 开启。如果本机新签名证书尚未注册：

```bash
./scripts/enroll-mok.sh
```

设置一次性密码，手动重启；蓝色 MOK Manager：Enroll MOK → Continue → Yes → 密码 → Reboot。不要导入不明证书。键盘布局可能与桌面不同。

现场出现过 `mokutil --test-key` 输出 already enrolled 但 EXIT=1。不要只看退出码重复注册，也不能关闭 Secure Boot 绕过。回到恢复仓库运行：

```bash
bash scripts/check-mok.sh
```

它导出已注册公钥证书逐字节匹配本机 DER，并校验私钥对应的公钥，不导出私钥。检查失败则停止 Xe 安装。重启后运行上游 `./scripts/verify.sh`，结合 `rfkill list` 和键盘插拔行为验收。

## 4. Xe TCSS DKMS：严格限制 ABI

确保当前内核就是 `7.0.0-38-generic`，保留第二个可启动 Ubuntu 内核及 USB 救援盘。先保存工作并备份当前 initrd。

```bash
cd ~/zenbook_duo26_setup
set -o pipefail
bash scripts/install-xe.sh --apply 2>&1 | tee ~/xe-install-recovery.log
rc=${PIPESTATUS[0]}
printf 'EXIT=%s\n' "$rc"
```

包装器先固定 `cc65948…` 并验证 MOK，再调用原 v3 安装器。它不运行 Arch 的 `duo apply`，而用 Ubuntu `7.0.0-38.38` 原生源码、匹配 headers 和 Module.symvers 构建覆盖 `xe.ko`；包含 v7.0 `i915_reg_t` 兼容改动。不更换完整内核。

**仅 `EXIT=0` 并且磁盘模块/签名/initramfs 检查通过才手动重启。**

```bash
modinfo -n xe
modinfo -F signer xe
sudo lsinitramfs /boot/initrd.img-$(uname -r) | grep 'updates/dkms/xe\.ko'
```

`modinfo` 是磁盘上选中的模块，不证明运行内核已加载它。重启后必须检查：

```bash
cat /sys/module/xe/parameters/zenbook_duo_edp2_tcss
```

预期 `Y`。安装成功不等于全部路径实测稳定。

v3 会备份 initrd、编译、DKMS 签名并更新当前内核 initramfs。原 v2 因普通用户读 root-only initrd 而失败回滚；读取要加 sudo。Dracut 的 Bluetooth 提示不能直接当作正常桌面蓝牙损坏原因。

## 5. Rust 自动切屏：使用已经包含中文修复的提交

保持两块屏幕已经物理点亮、触点键盘拿开。先停止可能安装过的早期自建服务：

```bash
systemctl --user disable --now zenbook-duo-display.service 2>/dev/null || true
cd ~/zenbook-duo26-Ubuntu26.04
git rev-parse HEAD
# 应为 e0b11760ad23898761e7acedd322dc412ced604a
./install.sh --skip-ui -- --no-usb-media-remap
```

提示输入：背光 0 或个人偏好；缩放 1.67；USB Media Remap 选 n。不要同时安装 zakstam 或其他自动切屏管理器。

**上游安装不是纯用户级操作**：安装依赖、构建 Rust、写入 udev/触摸配置与系统/用户服务，并管理 `xe.enable_dpcd_backlight=3` 的 GRUB drop-in；会重启自己的服务。不会由本仓库自动重启电脑或 GDM。执行前阅读固定上游脚本。

```bash
systemctl is-active zenbook-duo-rust-daemon.service
systemctl is-active zenbook-duo-rust-lifecycle.service
systemctl --user is-active zenbook-duo-session-agent.service
cd ~/zenbook-duo26-Ubuntu26.04/ui-tauri-react/src-tauri
cargo test --locked --lib runtime::
```

现场 runtime 57/57 是当时记录，新构建仍须保存自己的结果。lifecycle 的 active/exited 正常，但看日志确认实际任务；用户 Agent 必须 `--user`。

固定提交已经包含 locale-independent 解析，**不再打第二次同名补丁**。它修正英文、中文、法文描述不一致造成的错误 verify，但没有解决后续审计发现的所有启动交接/并发问题。

第一次安装按上游要求重新登录/人工重启，使组权限及背光参数生效。可选 UI：同 checkout 的 `./install-ui.sh`；本会话没有明确 UI 安装验收，也未确认音频、ISH 固件、笔输入全部正常。

## 6. 蓝牙：先临时恢复，自动服务可选

本机 Intel `8086:e476` 使用 PCIe `btintel_pcie`，不是 btusb。出现 No default controller available 时，先检查 RFKill 和本次启动日志；仅对已经实测的 Intel Reset -62 类故障：

```bash
bash scripts/bluetooth-reload.sh --apply
bluetoothctl list
bluetoothctl power on
```

需要有线输入；蓝牙连接会断开。不删配对，不卸 Wi-Fi，不改 Xe。手动重载实测有效，非永久内核修复。

可选自动恢复包：

```bash
bash optional/bluetooth-recovery/install.sh
```

**只有交付和静态检查记录，没有用户部署/触发成功确认。** 安装 `enable --now` 时若已过25秒，可能立即运行；阅读该目录 README 后决定。不是默认必装。

## 7. 验收

先只读：

```bash
bash scripts/verify.sh
```

再人工操作：键盘拿开双屏 → 盖上关闭下屏 → 拿开亮起，重复3次。记录 Rust 成功关闭后 ownership=true/当前boot、成功恢复后 false/null；每次都确认物理显示，不只看 gdctl。

保存工作，完全关机后键盘盖着启动，登录再拿开；检查上屏方向、双屏切换、蓝牙和新的 Xe 错误。睡眠/唤醒另列，不由冷启动 PASS 代替。

若出现 disabled + ownership=false、unknown-disabled、GNOME timeout 或物理黑屏，停止。不得强改 JSON、反复开屏或用重启 Agent 绕过保护。最后审计表明此边界尚未修复，见 [GDM-PLYMOUTH](GDM-PLYMOUTH.md)。

## 8. 回滚

Xe：
```bash
bash scripts/xe/zenbook_duo_ubuntu_xe_dkms_rollback.sh
```

原 rollback 有容错 `|| true`，必须核对 dkms 状态、磁盘模块路径和 initramfs，不只看 finished。GUI 不能用时通过 TTY 或备用内核操作，**不要在运行图形桌面时卸载 Xe**。

WMI：固定 checkout 的 `./scripts/uninstall.sh`，之后人工重启。可选蓝牙：对应 `uninstall.sh`。Rust 优先按本地备份单组件恢复；全量上游卸载先阅读，可能改依赖及用户配置。

## 9. 本次不恢复的实验

GDM 单屏 XML、全局 panel_orientation、Plymouth 近似旋转、UX8406 udev off/detect、Kubuntu/SDDM迁移、第三个蓝牙 DKMS，均不是已验证恢复步骤。保留当前 GNOME 基线，后续单独审查。
