#!/usr/bin/env bash

set -euo pipefail

OPENWRT_DIR="${1:-${OPENWRT_DIR:-}}"

if [[ -z "${OPENWRT_DIR}" || ! -d "${OPENWRT_DIR}" ]]; then
  echo "usage: $0 <openwrt-source-dir>" >&2
  exit 1
fi

CUSTOM_DIR="${OPENWRT_DIR}/package/custom"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

mkdir -p "${CUSTOM_DIR}"

clone_repo() {
  local name="$1"
  local url="$2"
  local ref="$3"
  echo "==> cloning ${name} (${ref})"
  git clone --filter=blob:none --depth 1 --branch "${ref}" "${url}" "${WORK_DIR}/${name}" >/dev/null 2>&1
}

copy_dir() {
  local src="$1"
  local dst="$2"
  if [[ ! -d "${src}" ]]; then
    echo "missing source directory: ${src}" >&2
    exit 1
  fi
  echo "==> syncing ${dst}"
  rm -rf "${CUSTOM_DIR:?}/${dst}"
  mkdir -p "${CUSTOM_DIR}/${dst}"
  rsync -a --delete \
    --exclude='.git' \
    --exclude='.github' \
    --exclude='.gitignore' \
    "${src}/" "${CUSTOM_DIR}/${dst}/"
}

rewrite_makefile_if_needed() {
  local file="$1"

  if [[ -f "${file}" ]]; then
    sed -i 's#\.\./\.\./luci\.mk#$(TOPDIR)/feeds/luci/luci.mk#g' "${file}"
    sed -i 's/libstdcpp6/libstdcpp/g' "${file}"
    sed -i 's/+tor +tor-geoip +obfs4proxy/+tor-geoip +obfs4proxy/g' "${file}"
    sed -i 's/+tor-basic +tor-geoip +obfs4proxy/+tor-geoip +obfs4proxy/g' "${file}"
  fi
}

clone_repo "diskman" "https://github.com/sbwml/luci-app-diskman.git" "main"
copy_dir "${WORK_DIR}/diskman/luci-app-diskman" "luci-app-diskman"

clone_repo "lucky" "https://github.com/kenzok8/openwrt-packages.git" "master"
copy_dir "${WORK_DIR}/lucky/luci-app-lucky/luci-app-lucky" "luci-app-lucky"
copy_dir "${WORK_DIR}/lucky/luci-app-lucky/lucky" "lucky"

clone_repo "openclaw" "https://github.com/10000ge10000/luci-app-openclaw.git" "v2.0.2"
copy_dir "${WORK_DIR}/openclaw" "luci-app-openclaw"

clone_repo "syncdial" "https://github.com/BenjaminX/luci-app-syncdial.git" "master"
copy_dir "${WORK_DIR}/syncdial" "luci-app-syncdial"

clone_repo "timewol" "https://github.com/kiddin9/luci-app-timewol.git" "main"
copy_dir "${WORK_DIR}/timewol" "luci-app-timewol"

clone_repo "wrtbwmon-ui" "https://github.com/brvphoenix/luci-app-wrtbwmon.git" "release-2.0.13"
copy_dir "${WORK_DIR}/wrtbwmon-ui/luci-app-wrtbwmon" "luci-app-wrtbwmon"

clone_repo "wrtbwmon" "https://github.com/brvphoenix/wrtbwmon.git" "master"
copy_dir "${WORK_DIR}/wrtbwmon/wrtbwmon" "wrtbwmon"

clone_repo "aliddns" "https://github.com/honwen/luci-app-aliddns.git" "v20210117"
copy_dir "${WORK_DIR}/aliddns" "luci-app-aliddns"

clone_repo "argon-theme" "https://github.com/jerrykuku/luci-theme-argon.git" "v2.4.3"
copy_dir "${WORK_DIR}/argon-theme" "luci-theme-argon"

clone_repo "argon-config" "https://github.com/jerrykuku/luci-app-argon-config.git" "master"
copy_dir "${WORK_DIR}/argon-config" "luci-app-argon-config"

clone_repo "torbp" "https://github.com/zerolabnet/luci-app-torbp.git" "1.0"
copy_dir "${WORK_DIR}/torbp" "luci-app-torbp"

clone_repo "openclash" "https://github.com/vernesong/OpenClash.git" "v0.47.075"
copy_dir "${WORK_DIR}/openclash/luci-app-openclash" "luci-app-openclash"

clone_repo "wechatpush" "https://github.com/tty228/luci-app-wechatpush.git" "v3.6.12"
copy_dir "${WORK_DIR}/wechatpush" "luci-app-wechatpush"

clone_repo "awg" "https://github.com/2Grey/awg-openwrt.git" "v25.12.2"
copy_dir "${WORK_DIR}/awg/kmod-amneziawg" "kmod-amneziawg"
copy_dir "${WORK_DIR}/awg/amneziawg-tools" "amneziawg-tools"
copy_dir "${WORK_DIR}/awg/luci-proto-amneziawg" "luci-proto-amneziawg"

rewrite_makefile_if_needed "${CUSTOM_DIR}/luci-app-timewol/Makefile"
rewrite_makefile_if_needed "${CUSTOM_DIR}/luci-app-openclaw/Makefile"
rewrite_makefile_if_needed "${CUSTOM_DIR}/luci-app-torbp/Makefile"

required_makefiles=(
  "amneziawg-tools/Makefile"
  "kmod-amneziawg/Makefile"
  "luci-app-argon-config/Makefile"
  "luci-app-diskman/Makefile"
  "luci-app-lucky/Makefile"
  "luci-app-openclash/Makefile"
  "luci-app-openclaw/Makefile"
  "luci-app-syncdial/Makefile"
  "luci-app-timewol/Makefile"
  "luci-app-torbp/Makefile"
  "luci-app-wrtbwmon/Makefile"
  "luci-proto-amneziawg/Makefile"
  "luci-theme-argon/Makefile"
  "lucky/Makefile"
  "wrtbwmon/Makefile"
)

for rel in "${required_makefiles[@]}"; do
  if [[ ! -f "${CUSTOM_DIR}/${rel}" ]]; then
    echo "missing required package makefile: ${rel}" >&2
    exit 1
  fi
done

echo "Custom packages are ready under ${CUSTOM_DIR}"
