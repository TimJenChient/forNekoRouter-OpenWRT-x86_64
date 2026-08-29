# Build-OpenWRT-Custom-x86_0402

用于 GitHub Actions 云编译 `x86_64` OpenWrt 的自定义镜像构建项目，基于官方 `v25.12.2` 版本，启用 `apk` 包管理，并在编译完成后自动上传固件和配置文件到 GitHub Release。

## 📋 项目特性

- **基础版本固定**：官方 `openwrt/openwrt` `v25.12.2`
- **Feeds 固定**：所有官方 feeds 固定为 `openwrt-25.12` 分支
- **目标平台**：`x86/64 generic`（可部署在 KVM、VMware、VirtualBox 等虚拟化平台）
- **RootFS 分区**：固定为 `3072 MiB`
- **包管理**：启用 `apk` 包管理器
- **文件格式**：EXT4 分区 + GRUB EFI 引导
- **自动上传**：编译完成后自动上传固件和最终 `.config` 至 Release
- **预配置**：仓库根目录包含预生成的 `.config` 配置文件

## 📦 已集成的包

### 官方包
- `luci-app-acme` - ACME 证书管理
- `luci-app-adblock-fast` - 快速广告屏蔽
- `luci-app-frpc` / `luci-app-frps` - 内网穿透
- `luci-app-nlbwmon` - 网络带宽监控
- `luci-app-statistics` - 系统统计
- `luci-app-ttyd` - Web 终端
- `acme-acmesh-dnsapi` - DNS API 支持
- `obfs4proxy` - Obfs4 代理

### 第三方包
- **网络工具**：
  - `luci-app-wireguard` / `luci-proto-wireguard` - WireGuard VPN
  - `kmod-amneziawg` / `amneziawg-tools` / `luci-proto-amneziawg` - AmneziaWG 支持
  - `luci-app-torbp` - Tor 网络支持

- **系统管理**：
  - `luci-app-diskman` - 磁盘分区管理
  - `luci-app-argon-config` - Argon 主题配置
  - `luci-theme-argon` - Argon UI 主题

- **应用**：
  - `luci-app-lucky` - 大吉
  - `luci-app-openclash` - Clash 内核（v0.47.075）
  - `luci-app-openclaw` - OpenClaw v2.0.2
  - `luci-app-syncdial` - 同步拨号
  - `luci-app-timewol` - 定时唤醒

- **监控**：
  - `luci-app-wrtbwmon` - 带宽监控 UI
  - `wrtbwmon` - 带宽监控后端
  - `collectd` 各模块（CPU、内存、网络、DNS、RRDTool 等）

- **其他**：
  - `iperf3` - 网络性能测试
  - `grep`, `sed`, `coreutils-sort`, `xz-utils` - 常用工具
  - `script-utils` - 脚本工具库

## 🛠️ 项目结构

```
.
├── .config                          # OpenWrt 编译配置文件
├── feeds.conf.default               # Feeds 源配置（固定为 openwrt-25.12）
├── .github/
│   └── workflows/
│       └── build-openwrt.yml        # GitHub Actions 编译工作流
├── scripts/
│   └── prepare_custom_packages.sh    # 第三方包集成脚本
├── package/
│   └── custom/                      # 第三方包存储目录
└── README.md                        # 本文件
```

## 🚀 使用方法

### 快速开始

1. **Fork 本仓库**到你的 GitHub 账号
   ```bash
   # 或直接克隆
   git clone https://github.com/TimJenChient/Build-OpenWRT-Custom-x86_0402.git
   cd Build-OpenWRT-Custom-x86_0402
   git push origin main
   ```

2. **启用 Actions**
   - 进入仓库 → `Settings` → `Actions` → `General`
   - 确保 `Actions permissions` 设置为 `Allow all actions and reusable workflows`
   - 确保 `Workflow permissions` 中勾选 `Read and write permissions`

3. **触发编译**
   - 进入 `Actions` 选项卡
   - 选择 `Build OpenWrt x86_64` 工作流
   - 点击 `Run workflow` 按钮开始编译

4. **下载固件**
   - 编译完成后访问 `Releases` 页面
   - 下载以下文件：
     - `openwrt-*-x86_64-generic-ext4-combined-efi.img.gz` - EFI 启动固件
     - `openwrt-*-x86_64.config` - 最终编译���置

### 自定义配置

#### 修改编译配置

编辑 `.config` 文件：
```bash
# 启用/禁用包
CONFIG_PACKAGE_luci-app-xxx=y    # 启用
# CONFIG_PACKAGE_luci-app-xxx is not set  # 禁用

# 调整分区大小
CONFIG_TARGET_ROOTFS_PARTSIZE=3072  # 单位：MiB
```

#### 添加第三方包

编辑 `scripts/prepare_custom_packages.sh`，按照现有格式添加：

```bash
clone_repo "package-name" "https://github.com/user/repo.git" "branch-or-tag"
copy_dir "${WORK_DIR}/package-name/path" "target-package-dir"
```

确保添加的包包含 `Makefile` 文件。

#### 更换 Feeds 版本

修改 `feeds.conf.default`：
```bash
# 将 openwrt-25.12 替换为其他分支/标签
src-git packages https://github.com/openwrt/packages.git;openwrt-25.12
src-git luci https://github.com/openwrt/luci.git;openwrt-25.12
```

## ⚠️ 已知限制与注意事项

- **luci-app-homeassistant**：暂无可稳定用于 OpenWrt 25.12.2 的公开上游源码，默认未启用
- **编译时间**：首次编译需要下载大量源码，耗时较长（30~60 分钟），后续增量编译会快速得多
- **磁盘空间**：编译过程需要 30+ GB 自由空间
- **网络依赖**：需要稳定的国际网络环境下载官方源码

## 🔧 编译工作流说明

工作流 `build-openwrt.yml` 自动执行以下步骤：

1. **环境准备** - 安装编译依赖
2. **克隆源码** - 从官方仓库克隆 OpenWrt v25.12.2
3. **配置 Feeds** - 应用自定义 feeds 配置并更新
4. **集成包** - 同步第三方包并运行准备脚本
5. **应用配置** - 复制 `.config` 并执行 defconfig 验证
6. **下载源码** - 下载所有编译依赖的源码包
7. **编译固件** - 多线程编译（失败则单线程重试）
8. **收集产物** - 整理固件文件和配置文件
9. **发布** - 上传至 GitHub Release 和 Actions Artifacts

## 📝 文件说明

| 文件 | 用途 |
|------|------|
| `.config` | OpenWrt 编译配置，定义目标平台、包选择等 |
| `feeds.conf.default` | Feeds 源配置，指定官方软件包源 |
| `scripts/prepare_custom_packages.sh` | 自动下载并集成第三方包的脚本 |
| `package/custom/` | 本地第三方包存储（编译前生成） |

## 🤝 贡献与反馈

- 发现问题或有建议？欢迎提交 Issue
- 有改进方案？欢迎提交 Pull Request

## 📄 许可证

本项目基于上游 OpenWrt 项目的许可证，具体请参考各源码仓库的许可证信息。

---

**最后更新**：2026-08-29
