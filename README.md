# ASUS Zenbook Duo 2026 · Ubuntu 重装恢复档案

适用设备：**ASUS Zenbook Duo UX8407AA**。会话基线：**2026-10-22 / Ubuntu 26.04.1 / GNOME Wayland / 7.0.0-38-generic / Secure Boot 开启**。

这是本次实机排障的恢复资料，不是面向所有 Zenbook 的一键安装器。**按 [重装步骤](docs/REINSTALL.md) 逐阶段执行，每阶段验证后再继续。** 不自动重启，不部署失败的 GDM/Plymouth 实验。

## 分段执行（推荐）

**[按编号运行恢复脚本](docs/STAGES.md)**：无需逐行复制长命令。脚本独立执行、读写类需要 `--apply`、关键步骤保留人工确认。当前 Rust 编译中断可直接使用 50 → 52 → 53；首次安装使用 50 → 51 → 53。

## 恢复目标与证据边界

| 组件 | 会话结果 | 重装处理 |
|---|---|---|
| 上屏 eDP-1 / 下屏 eDP-2 | 上屏主屏、180°；下屏 normal、位于下方；约 166.67% 缩放 | 恢复并实机确认 |
| Xe TCSS DKMS | 已签名加载，运行参数 Y；键盘盖着冷启动及切换曾通过 | 仅支持精确 ABI，重新验收 |
| ASUS WMI DKMS | 插拔键盘误触发飞行模式已修复 | 保留 |
| Rust 中文解析 | 固定提交 e0b11760…；runtime 57/57、关屏/开屏及归属切换通过 | 使用包含修复的提交 |
| Intel PCIe 蓝牙 | 间歇初始化失败，重载 btintel_pcie 实测有效 | 手动恢复；自动恢复包为可选、未确认实机部署 |
| GDM | 单屏方案导致下屏恢复失败，已回滚 | 不部署该方案 |
| Plymouth | BGRT/two-step；独立旋转未完成 | 保持不变 |
| 长期与全入口安全性 | 后续审计发现归属、启动接管及检查入口缺口 | 未完成；不夸大单次 PASS |

> 最后一次审计又观察到 `keyboardAttached=true / eDP-2 disabled / ownership=false`。这是“曾通过关键用例、仍有已知边界”的恢复基线，不是所有启动路径都已证明稳定的发行版。详见 [GDM/Rust 审计](docs/GDM-PLYMOUTH.md)。

## 文档入口

- [重装步骤](docs/REINSTALL.md)：U 盘、方向、固定版本、MOK、WMI、Xe、Rust、蓝牙、验收与回滚。
- [完整技术历程与现场基线](docs/BASELINE-HISTORY.md) · [分层排障](docs/TROUBLESHOOTING.md)。
- [GDM/Plymouth 失败方案和第二轮审计](docs/GDM-PLYMOUTH.md)。
- [备份与内核更新](docs/BACKUP-UPDATES.md) · [USB 与 Windows 恢复](docs/USB-WINDOWS.md)。
- [开源仓库与官方参考链接](docs/UPSTREAM.md) · [脚本来源及验证限制](docs/VALIDATION.md)。

```bash
git clone https://github.com/cwangfr/zenbook_duo26_setup.git
cd zenbook_duo26_setup
bash scripts/test-static.sh
bash scripts/preflight.sh
```

上述命令只做离线检查/状态读取。安装步骤见手册，不要将全部脚本串成一次执行。

**精确版本限制：** Xe 安装器只适用于 `7.0.0-38-generic` + Ubuntu 源码 `7.0.0-38.38`。不能修改检查条件后强装到新内核；先确认官方修复或单独移植。不要为了复现旧配置而长期放弃安全更新。

**不要重做：** 全局 `panel_orientation=upside_down` 与现有 180° 桌面校正混用；将用户单屏 XML 复制给 GDM；强改 ownership；删除全部保护；并行运行多个双屏管理器。

原 Xe v3/回滚脚本与蓝牙恢复包保留会话附件字节。新增检查脚本只经过容器内静态测试，不冒充实机验证。旧 v1/v2 保存在 archive，仅用于追踪失败，不能运行。

本仓库不包含 MOK 私钥、配对密钥、Wi-Fi 密码、设备个人 XML、已安装二进制或 initrd。重装前仍需在外置盘备份当前系统。

## 主要上游

[Ubuntu 专用管理项目](https://github.com/therealarnold666/zenbook-duo26-Ubuntu26.04) · [2026 TCSS 补丁](https://github.com/burakgon/zenbook-duo-2026-linux) · [zakstam 多桌面项目（仅比较）](https://github.com/zakstam/zenbook-duo-linux)。固定提交见 [sources.lock.json](config/sources.lock.json)。
