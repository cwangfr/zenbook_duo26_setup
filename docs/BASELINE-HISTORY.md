# 现场基线与全部技术历程

来源：本次会话用户输出、实机反馈、Codex修复/审计记录。记录跨2026-10-21/22（Europe/Paris）。不是归档时远程读取当前电脑。

## 硬件/软件基线

| 项目 | 值 |
|---|---|
| DMI | ASUS / Zenbook Duo UX8407AA |
| OS /会话 | Ubuntu 26.04.1 / GNOME Wayland |
| Kernel | 7.0.0-38-generic；备用7.0.0-34-generic曾存在 |
| GDM/Mutter审计包 | 50.1-0ubuntu0.1 / 50.1-0ubuntu2.4 |
| Secure Boot | Enabled |
| 显示 | eDP-1上屏主屏180°，eDP-2下屏normal、下方；2880×1800；最初两屏144Hz |
| 缩放 | 实际1.6666666269302368；手工1.66曾被接受，后按约5/3处理 |
| 键盘触点USB | 0b05:1cd7 |
| 蓝牙 | PCI 0000:00:14.7，8086:e476，btintel_pcie |
| Wi-Fi | PCI 0000:00:14.3，8086:e440，iwlwifi |
| 蓝牙固件 | intel/ibt-00a0-0291-pci.sfi，日志46-8.26 |
| Xe DKMS | zenbook-duo-xe-ubuntu/1.3.0-u70038，运行标记Y |
| WMI DKMS | asus-nb-wmi-ux8407aa/0.1.0 |
| 保留参数 | xe.enable_dpcd_backlight=3 |
| 撤销参数 | video=eDP-1:panel_orientation=upside_down |
| 启动镜像/主题 | 现场update-initramfs调用Dracut；BGRT/two-step |

不保存本机root UUID、个人EDID、序列号、蓝牙MAC、账号及boot ID。

## 1. USB与初始显示

讨论Esc启动菜单、F2 BIOS、整盘擦除Ubuntu后的Windows恢复；未验证具体子型号Cloud Recovery。Live USB当时只显示一屏，安装后两屏。最初按GNOME数字猜eDP接口的假设后来纠正：**上屏eDP-1，下屏eDP-2**。

`gdctl --verify`只验证、普通set临时、--persistent保存。正确180°/上下布局经过用户重启确认。修改显示时发生过卡死和自动转回，可能是确认回滚或驱动超时，不能仅凭外观下结论。

## 2. 自动切屏与服务

手动关闭/开启下屏成功后，先提供过简单轮询用户服务；随后使用Ubuntu专用Rust项目替代。早期助手只在启动看到键盘拿开且下屏enabled才设safe=1，不能与Rust并行，也不解决后续所有交接问题。

安装曾不完整，导致unit不存在；重新完整安装后3服务active。session-agent是用户服务。lifecycle是oneshot+RemainAfterExit，active/exited正常；但ExecStart前缀-可忽略错误，仍应看Result/ExecMainStatus和日志。

## 3. 飞行模式

触点键盘插拔导致RFKill误切换。固件WMI 0x5D/0x5E/0x5F在缺少UX8407AA quirk时被解释成无线按键。安装上游asus-nb-wmi DKMS、MOK后用户确认有效。它不修Xe或PCIe蓝牙Intel Reset。

## 4. Xe/TCSS

原驱动带键盘冷启动，拿开会冻结；Caps Lock仍能响应，约一分钟后桌面恢复但只有上屏。另有下屏关闭一次后不能恢复。先确认原驱动路径且无TCSS运行参数，不能把WMI DKMS当成显卡补丁。

选用burakgon display-edp2-tcss v2/1.3：请求Panther Lake Port B C20 PHY的TCSS电源，再编程时钟，关屏后释放请求。用精确Ubuntu source/headers构建Xe覆盖，不运行Arch pacman/mkinitcpio安装器。不安装完整7.2-rc4/rc5内核；那些仅是其他项目的测试基线。

安装器历程：
- v1：MOK仅看test-key退出码，文字enrolled但EXIT=1导致误拒绝；末尾误留BUILD。
- v2：导出MOK精确比对DER并检查keypair；编译签名通过，但普通用户lsinitramfs读root-only initrd失败（3cpio Permission denied），回滚。
- v3：sudo读取initrd；最终磁盘updates/dkms且运行参数Y。原始脚本保留，不悄悄重写成另一版本。
- 本仓库新增包装：先固定上游，再额外检查initrd确有补丁且不混stock。新增包装不冒充实机验收。

## 5. 启动旋转冲突

Codex为GDM/Plymouth加入全局panel_orientation。桌面已有180°校正，重启后方向异常。移除新增参数、保留背光参数、update-grub后恢复。不能因此认为所有下屏黑屏均由方向造成。

## 6. 蓝牙

No default controller available。实际PCIe设备和hci0存在、RFKill未锁、固件下载成功，Intel Reset出现Controller in error state、intel_reset1 timeout、-62。modprobe btusb不针对该硬件；重载btintel_pcie用户明确确认有效。之后冷启动有成功也有复发。

交付条件式timer包：约25秒检查，无Controller且有指定错误才一次reload。**没有安装/实机验收回复。** 没有安装蓝牙DKMS。相关Ubuntu bug/commit只是线索；不宣称已确认官方发布到本内核。

## 7. 中文解析Bug及实机验证

Xe已加载Y且没有典型PHY错误，但Rust verify报告两屏false。gdctl实际输出中文“内置显示器”，旧代码写死英文Built-in display。关屏实际成功→verify失败→O未记录→detach被保护阻断。

Codex只改session_agent.rs：只读Logical monitors段，精确connector token；英文/中文/法文及边界测试、runtime57/57，release成功；备份替换单二进制，实测盖上O=true、拿开亮屏且O=false。公开提交e0b11760…可复现。

随后用户确认盖键盘完全关机再启动、蓝牙正常、拿开/盖回切屏正常。**这是一轮PASS，不是所有会话路径或长期稳定保证。** 睡眠/唤醒未完成。

## 8. GDM失败与审计

第一轮将用户单屏XML复制到GDM seat0，只上屏180°、下屏disabled。静态检查通过但登录后Rust没有关闭归属，detach不开屏。GDM备份回滚后恢复；Plymouth未改。

第二轮源码审计发现：用户stored XML仍可先关闭下屏；startup/re-register/resume与monitor保护不同；readiness把可反序列化Error当ready；外层/内层重复采样提交、陈旧target及并发风险；蓝牙命令同步无超时可能阻塞显示。

最后补查又见attached=true、disabled、O=false，实际当次前态E没有日志，不能唯一归因于GDM残留或Xe。审计PASS不等于修复PASS；新部署BLOCKED。详见专章。

## 9. 其他项目与Kubuntu

zakstam多桌面/布局/快捷键丰富，但不是当前ownership交接的现成修复，可能覆盖同名服务；README的登录修复针对SDDM/KWin。cceelen UX8406使用udev写DRM status off/detect，未移植到本机。burakgon KDE管理不能把Arch installer整体套Ubuntu。

本会话决定保留GNOME，不为登录动画直接换Kubuntu；桌面切换不能消除同内核的TCSS和PCIe蓝牙问题。先前“80%问题已解决”等比例不是技术验收指标，不纳入基线。

## 缺失材料

未取得用户本机完整XML、实际部署二进制及全套hash、initrd、Codex工作目录中全部diff/验证附件。仅给出本机路径不能当作文件内容。原GDM在审计中是双屏、上屏normal、无disabled；不能凭描述编造EDID/mode/serial。
