# 开源来源与固定版本

以下保留会话引用。README支持声明、社区报告、本机实测不是同一种证据；链接不等于授权执行其中全部安装命令。

## 实际采用

### Ubuntu专用Rust项目
- https://github.com/therealarnold666/zenbook-duo26-Ubuntu26.04
- 固定基线：https://github.com/therealarnold666/zenbook-duo26-Ubuntu26.04/tree/e0b11760ad23898761e7acedd322dc412ced604a
- 中文解析修复：https://github.com/therealarnold666/zenbook-duo26-Ubuntu26.04/commit/e0b11760ad23898761e7acedd322dc412ced604a
- WMI：https://github.com/therealarnold666/zenbook-duo26-Ubuntu26.04/tree/e0b11760ad23898761e7acedd322dc412ced604a/ux8407aa-asus-nb-wmi-quirk
- 安装：https://github.com/therealarnold666/zenbook-duo26-Ubuntu26.04/blob/e0b11760ad23898761e7acedd322dc412ced604a/install-rust-runtime.sh
- 冷启动A/B：https://github.com/therealarnold666/zenbook-duo26-Ubuntu26.04/blob/e0b11760ad23898761e7acedd322dc412ced604a/XE_EDP2_KEYBOARD_AB_REPORT.md
- 逻辑正常但物理黑屏：https://github.com/therealarnold666/zenbook-duo26-Ubuntu26.04/blob/e0b11760ad23898761e7acedd322dc412ced604a/POST_LOGIN_DISPLAY_RECOVERY_FINDINGS.md
- 更广内核修复记录：https://github.com/therealarnold666/zenbook-duo26-Ubuntu26.04/blob/e0b11760ad23898761e7acedd322dc412ced604a/UX8407AA_KERNEL_AND_RUNTIME_FIXES_2026-07-27.md
- 关键源码目录：https://github.com/therealarnold666/zenbook-duo26-Ubuntu26.04/tree/e0b11760ad23898761e7acedd322dc412ced604a/ui-tauri-react/src-tauri/src/runtime

社区项目，非ASUS官方支持包。固定提交包含cwangfr的locale修复；不要直接最新main覆盖自己二进制。

### Xe TCSS补丁
- https://github.com/burakgon/zenbook-duo-2026-linux
- 本机日志记录版本：https://github.com/burakgon/zenbook-duo-2026-linux/tree/cc65948bfb921483336d7174b7ef4afce8e3431f
- 模块：https://github.com/burakgon/zenbook-duo-2026-linux/tree/cc65948bfb921483336d7174b7ef4afce8e3431f/modules/display-edp2-tcss
- 硬件报告：https://github.com/burakgon/zenbook-duo-2026-linux/blob/cc65948bfb921483336d7174b7ef4afce8e3431f/docs/hardware-report.md
- 上游问题：https://gitlab.freedesktop.org/drm/xe/kernel/-/issues/9196
- RFC v2：https://lore.kernel.org/all/20261015-ptl-port-b-tcss-v2-0-e00ce882402d@gmail.com/

原安装器为Arch/CachyOS；此恢复只复用补丁，用精确Ubuntu源码。其他发行版/内核的验证不是Ubuntu7.0的证明；本机以会话后续实测为准。

## 只比较，不能并行安装

### zakstam多桌面管理
- https://github.com/zakstam/zenbook-duo-linux
- 审查版本：https://github.com/zakstam/zenbook-duo-linux/tree/7573a35a490050959bc0f1446160fe1896c84b4c
- 独立GNOME扩展：https://github.com/Antonskt/zenbook-duo-gnome-tools

功能：GNOME/KDE/Niri/Hyprland、布局/外接屏/旋转/亮度、背光、Fn/媒体键、触摸控制、键盘电量、Tauri控制面板、生命周期恢复。部分键盘特性限定UX8406MA；UX8407AA需要额外内核/固件条件。

登录方向示例为SDDM/plasmalogin的KWin配置，不是完整GDM50交接。ConditionUser=!gdm只是用户名条件，不能宣称覆盖所有动态greeter身份。该次RuntimeState未见当前关闭归属字段；更积极开屏不等于当前安全问题已解决。

与现有runtime使用同服务名/目录，不能整体并装。README的全局panel_orientation不能直接套到已校正180°的GNOME基准。其他固件/音频步骤本机没有执行验收。

### UX8406下屏架构
- https://github.com/cceelen/asus-zenbook-duo-ux8406
- https://github.com/cceelen/asus-zenbook-duo-ux8406/tree/main/second-screen

通过udev写DRM connector status off/detect模拟热插拔，compositor恢复布局。机型、键盘ID及USB端口有限定，不是UX8407AA验证方案；本机未安装规则或helper。

历史来源：https://github.com/Fmstrat/zenbook-duo-linux

## 官方参考及审计源码

- ASUS USB：https://www.asus.com/support/faq/1013017/
- ASUS Cloud Recovery：https://www.asus.com/support/faq/1050478/
- Ubuntu Secure Boot：https://wiki.ubuntu.com/UEFI/SecureBoot
- systemctl：https://www.freedesktop.org/software/systemd/man/latest/systemctl.html
- GDM50.1：https://github.com/GNOME/gdm/blob/50.1/daemon/gdm-launch-environment.c
- Mutter store：https://github.com/GNOME/mutter/blob/50.1/src/backends/meta-monitor-config-store.c
- Mutter initial config：https://github.com/GNOME/mutter/blob/50.1/src/backends/meta-monitor-manager.c
- gdctl：https://github.com/GNOME/mutter/blob/50.1/tools/gdctl
- GDM审计源包：https://archive.ubuntu.com/ubuntu/pool/main/g/gdm3/gdm3_50.1-0ubuntu0.1.dsc
- Mutter审计源包：https://archive.ubuntu.com/ubuntu/pool/main/m/mutter/mutter_50.1-0ubuntu2.4.dsc

## 蓝牙线索，未宣称已集成

本会话引用：https://bugs.launchpad.net/bugs/2170908 ，上游提交短ID `5917dd39db2b`，涉及warning bit误判。此次归档未重新取得该页面的完整内容，保留为会话来源线索；不确认当前发布状态或本机唯一根因。确证是本机初始化日志和重载btintel_pcie有效。自动恢复包不等同于内核补丁。

## 可复现性与许可

Git提交固定，旧Ubuntu包仍需软件源或离线缓存。没有完整固定Rust工具链及二进制构建环境，相同源码不等于bit-for-bit同产物。各仓库LICENSE和文件声明仍适用；不再分发ASUS专有ISH/Windows固件或私钥。
