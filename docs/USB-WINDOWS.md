# USB启动与Windows恢复

这是会话涉及的安装前选项，不是本机已经执行的恢复操作。

ASUS笔记本完全关机后按住Esc再开机，可进入启动设备菜单；F2进入UEFI。选择已正确制作的UEFI USB。F7/F8等具体菜单随BIOS界面，按实际显示，不假定一致。不要默认关闭Secure Boot，先排查介质及接口。

普通U盘不是只复制ISO就可启动；Ventoy的ISO复制依赖已安装的引导器，属于不同流程。Live USB设置通常不持久，本机当时屏幕识别数量与安装后不同。

## 恢复Windows的不同含义

| 方法 | 限制 |
|---|---|
| 整盘镜像（Clonezilla/Rescuezilla等） | 擦盘前保存全部EFI/Windows/Recovery/OEM分区到外置盘，恢复的是备份时状态 |
| ASUS Cloud Recovery | 必须具体机型支持；有UEFI云恢复的型号可不依赖原SSD恢复分区；会重写目标盘 |
| Microsoft Windows 11 USB | 普通Windows重装，不等于原厂驱动、ScreenXpert等完整恢复；同设备同授权版本的激活按实际许可证 |

**本会话没有确认该UX8407AA子型号是否有BIOS Cloud Recovery选项，也没有执行Win11恢复。** 不能保证所有2026款都支持。

概念澄清：OEM产品密钥可能在固件中，数字许可证是另一激活机制，不能笼统说全部数字许可证存于BIOS。备份版本(Home/Pro)、激活及恢复信息；不公开密钥。

引用：[ASUS USB](https://www.asus.com/support/faq/1013017/) · [ASUS Cloud Recovery](https://www.asus.com/support/faq/1050478/) · [Microsoft重装](https://support.microsoft.com/fr-fr/windows/deployment/install-upgrade/reinstall-windows-with-the-installation-media)。本仓库不提供Windows镜像/密钥或ASUS专有驱动包。
