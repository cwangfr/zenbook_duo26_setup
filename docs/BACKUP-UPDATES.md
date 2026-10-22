# 备份、内核更新与回退

仓库是恢复手册，不是整机镜像。重装前仍需外置盘备份，最好加密。**不把MOK私钥、SSH/Wi-Fi/蓝牙配对密钥上传GitHub。**

## 本地备份

```bash
bash scripts/backup-local.sh /media/$USER/EXTERNAL/zenbook-backup-20261022
```

按实际挂载点替换路径。脚本保存版本、关键显示/GRUB/Plymouth配置、runtime二进制、当前kernel/initrd、Xe DKMS source及上游tracked diff/git bundle。不会自动还原，不保存MOK私钥或蓝牙密钥。未跟踪源码文件需按status另行补备份；这也不是APT完整离线包。

至少另外记录：用户monitors.xml、GDM seat0原XML与numeric UID/GID/mode、上游HEAD与Cargo.lock、构建日志、安装包版本。不能仅用报告中XML hash重建原件；不能凭EDID描述编造配置。

新系统不要恢复旧state.json的boot ownership，不照搬旧root UUID、GDM动态UID或给其他内核用旧initrd。

## 精确包是否仍可取得

```bash
dpkg-query -W -f='${binary:Package}\t${Version}\n' \
  'linux-image*' 'linux-modules*' 'linux-headers*' 'linux-source*' dkms mokutil
apt-cache policy linux-source-7.0.0 linux-headers-7.0.0-38-generic
```

在仓库外用APT下载精确已装版本（若源仍提供），保存来源/校验。`/var/cache/apt/archives`不保证保留。不要从不明网盘下载内核包。固定Git提交不保证Ubuntu旧包永久在线。

## 内核更新限制

当前Xe DKMS明确：
```text
BUILD_EXCLUSIVE_KERNEL="^7\\.0\\.0-38-generic$"
```

`AUTOINSTALL=yes`不代表能编译到所有新ABI。WMI为新内核成功也不意味着Xe成功。

重启新内核前按实际KNEW检查：
```bash
dkms status
modinfo -k "$KNEW" -n xe
modinfo -k "$KNEW" -F signer xe
sudo lsinitramfs "/boot/initrd.img-$KNEW" | grep 'xe\.ko'
```

官方若已集成等效修复，再评估移除override并独立验收，不只看版本号。保留备用内核，但不长期冻结安全更新；新ABI必须使用匹配源码、headers、Module.symvers、配置及签名。

## MOK

```bash
mokutil --sb-state
sudo openssl x509 -inform DER -in /var/lib/shim-signed/mok/MOK.der \
  -noout -subject -fingerprint -sha256
```

UEFI可能保留旧MOK，而重装后本地生成新keypair，仍须核验确切DER及匹配私钥；必要时注册新证书。仓库只保存操作方法，不保存私钥。

## 回滚原则

一次回滚一个组件。蓝牙故障不先卸Xe；登录方向不改TCSS；归属不手写JSON。Xe回滚原脚本含容错语句，之后检查真实结果。GDM恢复仅使用本机原件。旧XML还原不会立即改变当前会话；不得自动重启GDM验证。

上游uninstall可能删服务、设置或依赖，执行前阅读。保持一个可启动原内核和USB救援介质。
