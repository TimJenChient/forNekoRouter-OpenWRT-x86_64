# Build-OpenWRT-Custom-x86_0402

用于 GitHub Actions 云编译 `x86_64` OpenWrt，固定到官方 `v25.12.2`，启用 `apk` 包管理，并在编译结束后把固件和最终 `.config` 上传到 GitHub Release。

## 特性

- 基于官方 `openwrt/openwrt` `v25.12.2`
- 官方 feeds 固定为 `openwrt-25.12`
- 目标平台固定为 `x86/64 generic`
- RootFS 分区固定为 `3072 MiB`
- 启用 `apk`
- 固件文件上传到 Release
- 根目录自带预生成 `.config`

## 已编译的包

- 官方包：
  `luci-app-acme`
  `luci-app-frpc`
  `luci-app-frps`
  `luci-app-nlbwmon`
  `luci-app-statistics`
  `luci-app-ttyd`
  `luci-app-adblock-fast`
  `acme-acmesh-dnsapi`
  `obfs4proxy`
- 第三方包：
  `luci-app-diskman`
  `luci-app-lucky`
  `luci-app-openclaw`
  `luci-app-syncdial`
  `luci-app-timewol`
  `luci-app-wireguard`（兼容包，实际拉取 `luci-proto-wireguard`）
  `luci-app-wrtbwmon`
  `luci-app-aliddns`
  `luci-theme-argon`
  `luci-app-torbp`
  `luci-app-argon-config`
  `luci-app-openclash`
  `luci-app-passwall2`
  `awg-openwrt`（`kmod-amneziawg`、`amneziawg-tools`、`luci-proto-amneziawg`）

## 已知限制

- `luci-app-homeassistant` 没有找到可稳定用于 `OpenWrt 25.12.2` 的公开上游源码。为了避免整条编译链失败，本仓库默认不启用它。如果你有明确可用的源码仓库，可以再补充进去。

## 使用

1. 把仓库推到你自己的 GitHub 仓库。
2. 确认仓库 `Actions` 已开启，并允许工作流写入 `contents`。
3. 在 GitHub Actions 里运行 `Build OpenWrt x86_64`。
4. 编译完成后，到 `Releases` 下载固件和最终 `.config`。
