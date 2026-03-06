# 检查脚本是否被 source 执行，否则报错退出
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "请使用 'source env.sh' 或 '. env.sh' 来加载环境，而不是直接执行该脚本。"
    exit 1
fi

export OPENCLAW_CONFIG_DIR="$HOME/code/openclaw-isolated/.openclaw"
export OPENCLAW_WORKSPACE_DIR="$HOME/code/openclaw-isolated/.openclaw/workspace"
export OPENCLAW_SANDBOX=1
