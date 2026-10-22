# 历史失败脚本：不要运行

v1/v2原附件以.sh.txt保留，仅为追踪，不是重装入口。
- v1：MOK test-key返回码误判；末尾误留BUILD。
- v2：修复MOK/尾部，但普通用户lsinitramfs读取root-only initrd失败，引发回滚。
- v3在scripts/xe；默认从scripts/install-xe.sh进入以固定上游。

早期zenbook-duo-display轮询助手已被专用Rust项目替代，不能并行启动；safe门槛不能证明所有开屏路径安全。它仅归档，没有被本仓库安装。
