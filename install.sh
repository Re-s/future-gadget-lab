#!/usr/bin/env bash
# =============================================================================
# 未来道具研究所 · Agent 角色卡一键安装脚本
#
# 用法：
#   bash install.sh                # 安装全部角色卡（kyouma + kurisu）
#   bash install.sh kyouma         # 只安装指定角色卡（agents/<id>/）
#   DSH_HOME=/path/to/.dsh bash install.sh   # 指定 DSH 根目录
#
# 安装目标：${DSH_HOME:-$HOME/.dsh}/.agent-presets/<id>/
# 安装后：新建会话时在预设选择器中选择对应角色卡即可。
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DSH_HOME="${DSH_HOME:-$HOME/.dsh}"
TARGET_ROOT="$DSH_HOME/.agent-presets"

# 允许通过参数指定要安装的角色卡；默认安装全部
if [ "$#" -gt 0 ]; then
  WANTED=("$@")
else
  WANTED=()
fi

echo "==> 未来道具研究所 · Agent 角色卡安装"
echo "    DSH 根目录 : $DSH_HOME"
echo "    安装目标   : $TARGET_ROOT"
echo ""

if [ ! -d "$REPO_ROOT/agents" ]; then
  echo "[错误] 未找到 agents/ 目录。请确认在仓库根目录运行本脚本：" >&2
  echo "        git clone https://github.com/Re-s/future-gadget-lab && cd future-gadget-lab" >&2
  exit 1
fi

mkdir -p "$TARGET_ROOT"
INSTALLED=0

for card_dir in "$REPO_ROOT"/agents/*/; do
  [ -d "$card_dir" ] || continue
  id="$(basename "$card_dir")"

  # 指定了安装列表时，跳过未点名的角色卡
  if [ "${#WANTED[@]}" -gt 0 ]; then
    skip=1
    for w in "${WANTED[@]}"; do
      [ "$w" = "$id" ] && skip=0 && break
    done
    [ "$skip" -eq 1 ] && continue
  fi

  # 校验角色卡必备文件
  if [ ! -f "$card_dir/agent.cordis.yml" ]; then
    echo "[警告] $id 缺少 agent.cordis.yml，跳过" >&2
    continue
  fi

  # 覆盖式安装（cp -r 保留 skills/ 子目录等全部内容）
  cp -r "$card_dir" "$TARGET_ROOT/$id"
  INSTALLED=$((INSTALLED + 1))
  echo "    ✓ 已安装: $id -> $TARGET_ROOT/$id"
done

if [ "$INSTALLED" -eq 0 ]; then
  echo "[错误] 没有安装任何角色卡（请检查 agents/ 目录内容）" >&2
  exit 1
fi

echo ""
echo "==> 安装完成（$INSTALLED 个角色卡）"
echo ""
echo "    下一步："
echo "    1. 新建会话（或刷新预设列表）"
echo "    2. 在预设选择器中挑选："
echo "       - 凤凰院凶真·疯狂科学家 (kyouma)  —— El Psy Kongroo."
echo "       - 牧濑红莉栖·助手 (kurisu)        —— 哼，我才不是特地帮你……"
echo ""
echo "    验证：确认 $TARGET_ROOT 下存在对应目录即可；"
echo "    也可让 DSH 通过 agentPresets.standingKeyFor('<id>') 做挂载校验。"
