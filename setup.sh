cat > /workspaces/ZMK-Keyboard/setup.sh << 'EOF'
#!/bin/bash
# 用法: ./setup.sh
# 功能: 一键配置 ZMK 编译环境（克隆源码 + 安装工具链 + 设置快捷命令）

set -e

# 获取当前脚本所在目录（即 ZMK 配置仓库根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="$(basename "$SCRIPT_DIR")"

echo "=========================================="
echo "🚀 开始配置 ZMK 编译环境"
echo "=========================================="
echo "📂 配置仓库: $SCRIPT_DIR"

# 1. 安装系统依赖
echo ""
echo "📦 安装系统依赖..."
sudo apt update
sudo apt install -y ninja-build protobuf-compiler
echo "✅ 系统依赖安装完成"

# 2. 克隆 ZMK 官方源码
echo ""
echo "📦 克隆 ZMK 源码..."
cd /workspaces
if [ -d "zmk" ]; then
    echo "⚠️ zmk 目录已存在，跳过克隆"
else
    git clone https://github.com/zmkfirmware/zmk.git
    echo "✅ ZMK 源码克隆完成"
fi

# 3. 初始化 west 工作区
echo ""
echo "📦 初始化 west 工作区..."
cd /workspaces/zmk
if [ ! -d ".west" ]; then
    west init -l app/
else
    echo "⚠️ west 工作区已存在，跳过 init"
fi
echo "✅ west 工作区初始化完成"

# 4. 更新 west 模块
echo ""
echo "📦 更新 west 模块（下载 Zephyr 和依赖，可能需要 3-5 分钟）..."
west update
echo "✅ west 更新完成"

# 5. 安装 Python 依赖
echo ""
echo "📦 安装 Python 依赖..."
pip install -r zephyr/scripts/requirements.txt
pip install -r app/requirements.txt
# ZMK Studio 需要额外依赖
pip install protobuf grpcio-tools pyelftools
echo "✅ Python 依赖安装完成"

# 6. 安装 Zephyr SDK
echo ""
echo "📦 安装 Zephyr SDK（可能需要 5-10 分钟）..."
west sdk install
echo "✅ Zephyr SDK 安装完成"

# 7. 设置快捷命令（双重保障）
echo ""
echo "📦 设置快捷命令..."

# 方法1：alias
if ! grep -q "alias build=" ~/.bashrc; then
    echo "alias build=\"$SCRIPT_DIR/build.sh\"" >> ~/.bashrc
    echo "alias push=\"cd $SCRIPT_DIR && git add . && git commit -m \\\"Update \$(date +%Y-%m-%d)\\\" && git push origin main && rm -rf /workspaces/zmk/app/build_* && rm -rf /home/codespace/.cache/zephyr 2>/dev/null\"" >> ~/.bashrc
    echo "✅ alias 已添加到 ~/.bashrc"
else
    echo "⚠️ alias 已存在，跳过"
fi

# 方法2：添加到 PATH（让 build.sh 可以在任何目录直接运行）
if ! grep -q "export PATH=.*$SCRIPT_DIR" ~/.bashrc; then
    echo "export PATH=\$PATH:$SCRIPT_DIR" >> ~/.bashrc
    echo "✅ PATH 已添加到 ~/.bashrc"
else
    echo "⚠️ PATH 已存在，跳过"
fi

# 重新加载配置
source ~/.bashrc

echo ""
echo "=========================================="
echo "✅ 环境配置完成！"
echo "=========================================="
echo ""
echo "📂 配置仓库: $SCRIPT_DIR"
echo ""
echo "可用命令："
echo "  build 键盘名     - 编译固件（如 build x35n）"
echo "  build.sh 键盘名  - 同上（PATH 方式）"
echo "  push             - 提交并推送到 GitHub，同时自动清理缓存"
echo ""
echo "固件自动保存到: $SCRIPT_DIR/键盘名/键盘名.uf2"
echo "=========================================="
EOF
chmod +x /workspaces/ZMK-Keyboard/setup.sh