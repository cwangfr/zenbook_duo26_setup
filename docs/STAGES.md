# 分段恢复脚本使用说明（UX8407AA / Ubuntu 26.04）

此页是 [REINSTALL.md](REINSTALL.md) 的**执行入口**，详细原理、手动验证与回滚依据仍以原手册为准。脚本放在 [scripts/stages/](../scripts/stages/)；每个阶段独立执行，不会自动跳到下一阶段，也不会自动重启。读写类必须显式传入 `--apply`，并在关键危险阶段等待人工确认。**仅进行了源代码审阅/静态约束设计，尚未在本次新装机器完成从头到尾的实机验收。**

## 从当前「gobject-sys 编译失败」位置继续

你不需要重跑 WMI 或 Xe。进入恢复仓库，依次执行：

```bash
cd ~/zenbook_duo26_setup
bash scripts/stages/50-rust-deps.sh --apply
bash scripts/stages/52-rust-resume-only.sh --apply
bash scripts/stages/53-rust-check.sh
```

只有此前上游 `setup-gnome.sh` 已执行完 Rust 安装之前的 udev、触摸映射、GRUB 背光等步骤，才可以用 `52` 直接重试 Rust 服务；若从未执行过这些步骤，应改用 `51-rust-full-install.sh --apply`。**51 和 52 是互斥的恢复路径，不要都执行。**

## 全部阶段（从头重装）

| 顺序 | 阶段 | 命令 | 行为与人工关口 |
|---|---|---|---|
| 安装前 | LiveUSB 临时旋转 | `bash scripts/stages/00-liveusb-display.sh` | 需要事先将仓库放在 U 盘/Live 环境；只打开 GNOME 显示设置，手动 Landscape (flipped)；没有仓库时直接 `gnome-control-center display` |
| 10 | 自检及硬件信息 | `bash scripts/stages/10-preflight.sh` | 只读；失败时停止；不等于物理显示成功 |
| 20 | 下载固定源码 | `bash scripts/stages/20-fetch-sources.sh --apply` | Apt 安装基础工具，固定 Rust 和 Xe 上游提交 |
| 30 | WMI 飞行模式修复 | `bash scripts/stages/30-wmi-install.sh --apply` | 安装 DKMS 0.1.0；如果已有此版本则拒绝重复覆盖 |
| 31 | MOK 签名注册（按需） | `bash scripts/stages/31-mok-enroll.sh --apply` | 如果未注册则要求密码；必须**人工重启**并在蓝色界面确认 |
| 32 | MOK 验证 | `bash scripts/stages/32-mok-check.sh` | 证书/私钥匹配和已注册公钥检查；失败不继续 |
| 40 | Xe v3 安装 | `bash scripts/stages/40-xe-install.sh --apply` | **仅 7.0.0-38-generic + 已注册 MOK**；不会自动重启；先核对安装日志/initramfs |
| 41 | Xe 重启后检查 | `bash scripts/stages/41-xe-check.sh` | 确认运行参数 `zenbook_duo_edp2_tcss=Y`、签名和 DKMS |
| 50 | Tauri/GTK/Rust 依赖 | `bash scripts/stages/50-rust-deps.sh --apply` | apt 开发库；必要时在普通用户下安装官方 rustup；检验 `gobject-2.0` 等 pkg-config |
| 51 | **首次完整 GNOME 安装** | `bash scripts/stages/51-rust-full-install.sh --apply` | 原上游 `install.sh --skip-ui`，含 udev/sudoers/Rust；须先确认双屏正常，不要替换为 52 |
| 52 | **仅 Rust 重试** | `bash scripts/stages/52-rust-resume-only.sh --apply` | 只在此前 GNOME setup 前半段已经执行后使用，与 51 二选一 |
| 53 | Rust 状态检查 | `bash scripts/stages/53-rust-check.sh` | 只读；检查 system/user 服务、日志和 ownership |
| 54 | Rust runtime 回归 | `bash scripts/stages/54-rust-tests.sh` | 编译并运行 `cargo test --locked --lib runtime::`，可能需要较长时间 |
| 60 | 蓝牙已知错误手动恢复（可选） | `bash scripts/stages/60-bluetooth-recovery.sh --apply` | 仅无默认控制器且匹配已有 -62 故障；可能中断蓝牙 |
| 90 | 最终只读检查 | `bash scripts/stages/90-final-check.sh` | 再做冷启动、键盘插拔、休眠/恢复等**人工验收** |
| 99 | Xe 回滚（**不是安装步骤**） | `bash scripts/stages/99-xe-rollback.sh --apply` | 必须先启动**另一个原装备用内核**，再从安全 TTY 操作，保留原回滚脚本语义 |

除 00 外，进入本仓库的根目录再运行：`cd ~/zenbook_duo26_setup`。仓库尚未下载时先执行 `sudo apt install git`，`git clone https://github.com/cwangfr/zenbook_duo26_setup.git`。各阶段用 `bash` 启动，因此即使 GitHub checkout 的可执行位改变也可运行。

## 重要约束

- 不要执行 `for x in scripts/stages/*.sh; do bash "$x" --apply; done`；50 之后必须选择 **51 或 52**，MOK/Xe 需多次人工重启。
- 每个安装/修复阶段都可以单独运行；读写阶段默认缺少 `--apply` 就拒绝。重装不自动改 GDM、Plymouth、全局屏幕方向，不强制开启已 disabled 且 ownership=false 的 eDP-2。
- 有效的 Xe 原始安装/回滚、WMI、蓝牙脚本仍在原路径；新阶段脚本只是简短入口，避免将长命令逐行复制到终端。
- 发生 `gobject-sys` 失败时必须保存真正的 `--- stderr`，而不是仅凭 crate 名推断缺失的 .pc 文件。Rust 依赖的参考说明见 [REINSTALL 第 5.0 节](REINSTALL.md#50-首次编译前补齐-rusttauri-系统依赖)。
- `32`/ `41`/ `53`/ `90` 是检查点，不可跳过实机操作验证；任何新的内核 ABI 都必须先重新审计 Xe 补丁兼容性。
