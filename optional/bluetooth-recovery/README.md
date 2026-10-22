# 可选：条件式蓝牙启动恢复

五个脚本/单元文件来自会话交付zip，保持原字节。**没有用户确认安装或自动触发成功；只有手动重载已实测有效。**

OnBootSec=25s检查：已有Controller则不动；无Controller且本boot有Intel Soft Reset failed (-62)，才reload一次btintel_pcie。限定UX8407AA和PCI8086:e476，用flock防并发，不改Wi-Fi/Xe/GDM/SecureBoot/配对数据。

```bash
bash optional/bluetooth-recovery/install.sh
systemctl status zenbook-bt-recover.timer
sudo journalctl -b -u zenbook-bt-recover.service --no-pager
```

安装enable --now时，若已经开机超过25秒，可能立即检查/重载，准备有线输入并保存工作。timer自然每次boot一次，但脚本没有永久boot标记，手工重启service/timer仍能再运行，不能称绝对不可能第二次。

原包未额外检查RFKill/用户主动关闭，也未覆盖所有异常超时路径；systemd杀掉脚本不保证回滚内核动作。被中断后人工检查bluetooth.service是否恢复。默认不安装，不改成无条件循环。

```bash
bash optional/bluetooth-recovery/uninstall.sh
```

卸载不删配对。只修当前故障可用scripts/bluetooth-reload.sh --apply。官方驱动修复实测稳定后移除临时机制。
