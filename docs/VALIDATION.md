# 验证分级、脚本来源与限制

## 三类证据

| 类别 | 内容 |
|---|---|
| 会话实机报告 | gdctl布局/持久化；WMI飞行模式修复；Xe参数Y；Rust locale修复57/57与切换；一轮盖键盘冷启动；手动btintel_pcie重载 |
| 失败/未完成 | GDM单屏回归、后续归属异常、多入口安全；Plymouth；蓝牙间歇复发；睡眠唤醒/长期运行；自动蓝牙包部署未确认 |
| 本次归档检查 | Bash语法、固定提交、原附件完整性、文档链接/敏感信息、无自动重启及帮助入口；不代替硬件验收 |

归档过程没有访问用户正在运行的电脑，不在容器内构建Ubuntu Xe、更新initrd、导入MOK或运行GUI服务。

## 原附件

| 文件 | SHA-256 |
|---|---|
| Xe v3 | de1ed7221d6fd22a380d5fd75d9adc6a4f6adc0a09d1e2d77c4ef24ec558d4bb |
| Xe rollback | 15f52f9074b5e832f1ffd014b016b75a906689bf56450c188dca23cebaa08a29 |
| Xe v1 | 9dcbe66fede1b61d0d89c33b1ef46f111fa641bce995a81b60628cab495b155e |
| Xe v2 | 8995352f2685993dd6b25fc88a863c910d380941cd59bc1ec1fcd49a6f750d05 |

v3、rollback在scripts/xe，v1/v2在archive且为.txt不可执行入口。原蓝牙包解压在optional，未悄悄标为已部署。文件字节需由test-static核对。

v3保留当时“未在该内核验证”的注释，后续实机证据另记；原脚本默认取用户目录补丁，新install-xe包装器先固定版本。

原v3只拒绝“initrd有stock但无patched”，不能拒绝“两者都无”；新包装增加patched必须存在且不得混stock的检查。外层若在原安装成功后发现问题，会停止并要求人工核对/回滚，不自动重启。

原rollback有`dkms remove ... || true`，需核验真实结果；finished不是成功证明。原v1有多余BUILD和MOK误判，v2有initrd读取权限缺陷，全部只归档。

## 新增打包辅助脚本

preflight/verify/diagnostics为只读；fetch-upstream固定commit且拒绝覆盖本地改动；check-mok精确核验；install-xe包住原v3；bluetooth-reload增加同硬件/错误签名/RFKill检查；backup-local只写私有本地备份。

这些辅助脚本仅容器静态/非硬件检查，**没有在UX8407AA执行过整个重装流程**。没有GDM/Plymouth安装器，无ownership绕过、无自动重启，不使用未验证“全部健康”的返回码代替实机。

## 无法密闭复现的部分

旧APT包未来可能不在线；Rust工具链未完整冻结；未获得本机原XML、initrd、二进制字节及所有Codex附件；固件/BIOS/硬件状态/时序仍影响结果。原runtime安全入口与事务缺口未修。自动蓝牙包不涵盖所有用户关闭与超时路径。

离线测试命令：`bash scripts/test-static.sh`。测试结果见 [static-checks](../evidence/static-checks.txt)。本机旧57/57属于上游runtime测试，不与本仓库测试混同。
