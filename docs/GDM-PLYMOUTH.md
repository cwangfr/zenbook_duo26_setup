# GDM/Plymouth：失败方案、源码审计和未完成边界

**默认不部署新GDM配置，Plymouth未修复。** 本章来自用户上传的第二轮审计和会话证据，不是新增授权或生产修复。原始报告约261行，其配套source-excerpts/测试源码/现场JSON只给出本机路径，未实际取得；不能冒称全部复核。

## 第一轮已失败

将用户单屏monitors.xml复制到`/var/lib/gdm3/seat0/config/monitors.xml`，eDP-1主屏/upside_down，eDP-2 disabled。静态检查PASS，但Rust接管时下屏已关闭而未记录归属：O=false/bootId=null，拿开键盘被保护拦截。回滚正确。

现场回滚路径：`/var/backups/zenbook-duo-display/gdm-seat0-20261022/rollback-gdm.sh`。这里只记录路径，**仓库没有得到其实际内容**；重装不能假设存在。恢复磁盘XML不会立即改变当前运行会话。

## 审计范围

- Rust提交`e0b11760ad23898761e7acedd322dc412ced604a`，开始工作区干净。
- Ubuntu GDM源包50.1-0ubuntu0.1、Mutter50.1-0ubuntu2.4，展开并应用发行版patches；tar SHA-256与.dsc清单一致，但报告未额外验证GPG信任链。
- greeter当时未存活，路径由发行版源码与早前现场支持，未冒充本轮读取进程环境。
- GDM回滚件重新读取cmp=ORIGINAL_MATCH，hash `b1ea1dc3ce09ee2539de95bb8047a395e7665e59fecc1bec902dd40c5e7d5418`；双屏、上屏normal、无disabled；旧路径不存在；全局XML同hash。
- 用户配置、initrd、Xe/WMI、Rust二进制、GRUB、Plymouth保护清单未变；没有部署/重启。

## 为什么GDM双屏也不保证接管

GDM为seat设置独立XDG_CONFIG_HOME，现场为`/var/lib/gdm3/seat0/config`，动态UID不能硬编码。普通用户Mutter另读`~/.config/monitors.xml`，初始化可优先用自己的stored配置；disabled monitorspec也加入匹配键，检测到两屏不会自动跳过单屏XML。

会话当前双屏可由Rust临时gdctl set形成，磁盘XML仍是单屏。GDM→用户Mutter→Rust不是严格串行的屏幕连续性保证。一次采样E=true或一次冷启动成功，不能证明所有启动E都为true。

## 归属与保护的真实能力

A=keyboard attached，E=执行前sysfs下屏enabled，O=本boot已记录runtime关闭归属，S=命令+verify成功：

```text
成功记录 O' = A && (O || E)
monitor detach guard: block = !A && !E && !O
```

| A/E/O | monitor路径 | 成功后归属 |
|---|---|---|
| 1/0/0 | 可执行attached布局 | false，不能认领先前关闭 |
| 1/0/1 | 可执行 | true，保留当前boot归属 |
| 1/1/0或1 | 可执行 | true |
| 0/0/0 | 拒绝开屏 | 不变 |
| 0/0/1 | 可恢复 | false/null |
| 0/1/0或1 | 可执行 | false/null |

失败/timeout/verify错误不授予新O；部分关闭但verify失败可留下“关闭且无归属”。这个guard不是Xe健康分类器：connected/disabled不足以判别故障，O=true也不能排除关闭后新的故障。

## 已发现的代码缺口

1. startup replay、session registration、resume replay未共用monitor的guard；不能靠重启agent恢复证明安全。
2. `probe_session_agent`只看Envelope可反序列化，Error也可能被认ready；注册ACK不等于布局/ownership ACK。
3. startup和常规replay不是同一executor；attached捕获值可能过期。
4. monitor外层采样/成功记录与内层replay重复，外层target可能陈旧；不是同一事务边界。
5. O仅绑定boot，新的session/设备故障没有完整撤销依据；历史enabled不等于当前健康。
6. 蓝牙明确返回Err后显示循环可继续，已有日志；但同步bluetoothctl/rfkill output无超时，前置挂起仍可阻塞显示。T7返回错误不等于T8永久挂起通过。
7. Boot lifecycle前面的硬件/背光错误可提前返回，不能假定startup pending总设置。

上述并发/陈旧风险是源码可达分析，不能全部声称已在本机复现。

## 第二轮验证与最新现场

报告运行：runtime基线57 PASS；提取原函数的隔离ownership审计6 PASS；“GDM双屏足够保证O”反例测试预期RED（1 FAIL、exit101）。这是基线GREEN和设计反证，不是生产修复RED→GREEN；隔离测试不模拟Mutter/KMS。

补查时又见`keyboardAttached=true / eDP-2 disabled / O=false / bootId=null`，最近attach replay 1/3成功，但缺该次E值。原GDM已正确恢复，故不能把它当残留单屏证据，也不能唯一归因为Xe。若状态不变，下一次detach将被guard拦截。

## 下一阶段实施边界

先在隔离分支增加同一事务boot/session/target generation、E/O前值、命令、verify、提交后O日志；核对实际二进制与源码。统一所有入口的采样/guard/命令/verify/提交及ready语义，避免盲目修显示XML。

测试至少覆盖：GDM双屏→用户单屏；正常attach/detach；四入口unknown-disabled零开屏调用；部分apply/verify失败；旧boot/session/ACK；并发旧target；蓝牙Err与挂起；已O=true后的新设备故障；错误交接token；readiness期间拿开键盘。必须在生产调用边界注入，不只测布尔函数。

A：GDM原双屏XML只改上屏transform，是最小候选，仍有用户会话先关屏反例，不能独立批准部署。
B：单屏+可信交接，要有真实关闭事务、认证身份、boot/seat/session/设备/config世代及一次性消费/撤销，不是事后写O=true；成本大，暂不首选。
C：先修Rust安全入口，只能保证更保守，不能自动解决用户Mutter的关闭归属。

不允许改用户已工作配置来掩盖风险，不允许全局删guard、历史enabled伪造归属、延时脚本抢跑、重启agent绕过、制造真实坏管线。若可信交接不能成立，继续BLOCKED。

## Plymouth

固件ASUS Logo、GRUB、Plymouth、GDM是不同阶段。当前BGRT/two-step/DRM renderer，未找到已验证的仅Plymouth整体旋转方案。不能只转PNG就称Logo/动画/解锁提示全部修复。

全局panel_orientation曾导致GNOME重复校正，已撤销。将来如更新initramfs，先备份，只更新当前内核，以root核对签名Xe仍在；不碰Secure Boot或驱动。当前不部署Plymouth修改。

结论：审计交付PASS；仅XML安全接管FAIL；全入口保护完备性FAIL；可信交接与完整健康分类BLOCKED；新GDM/Rust安装未执行。
