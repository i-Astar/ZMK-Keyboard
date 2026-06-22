cat > /workspaces/ZMK-Studio/setup.sh << 'EOF'
#!/bin/bash
# 用法: ./setup.sh
# 功能: 一键配置 ZMK 编译环境（克隆源码 + 安装工具链 + 设置快捷命令）

set -e

echo "=========================================="
echo "🚀 开始配置 ZMK 编译环境"
echo "=========================================="

# 1. 克隆 ZMK 官方源码
echo ""
echo "📦 克隆 ZMK 源码..."
cd /workspaces
if [ -d "zmk" ]; then
    echo "⚠️ zmk 目录已存在，跳过克隆"
else
    git clone https://github.com/zmkfirmware/zmk.git
    echo "✅ ZMK 源码克隆完成"
fi

# 2. 安装 west 和 Python 依赖
echo ""
echo "📦 安装 west 和 Python 依赖..."
cd /workspaces/zmk
pip install west
west update
pip install -r zephyr/scripts/requirements.txt
pip install -r app/requirements.txt
echo "✅ Python 依赖安装完成"

# 3. 安装 Ninja
echo ""
echo "📦 安装 Ninja 构建工具..."
sudo apt update
sudo apt install ninja-build -y
echo "✅ Ninja 安装完成"

# 4. 安装 Zephyr SDK
echo ""
echo "📦 安装 Zephyr SDK（可能需要 5-10 分钟）..."
west sdk install
echo "✅ Zephyr SDK 安装完成"

# 5. 设置快捷命令
echo ""
echo "📦 设置快捷命令..."
if ! grep -q "alias build=" ~/.bashrc; then
    echo 'alias build="/workspaces/ZMK-Studio/build.sh"' >> ~/.bashrc
    echo 'alias push="cd /workspaces/ZMK-Studio && git add . && git commit -m \"Update $(date +%Y-%m-%d)\" && git push origin main && rm -rf /workspaces/zmk/app/build_* && rm -rf /home/codespace/.cache/zephyr 2>/dev/null"' >> ~/.bashrc
    echo "✅ 快捷命令已添加到 ~/.bashrc"
else
    echo "⚠️ 快捷命令已存在，跳过"
fi

source ~/.bashrc

echo ""
echo "=========================================="
echo "✅ 环境配置完成！"
echo "=========================================="
echo ""
echo "可用命令："
echo "  build 键盘名   - 编译固件（如 build x35n）"
echo "  push           - 提交并推送到 GitHub，同时自动清理缓存"
echo ""
echo "固件自动保存到: /workspaces/ZMK-Studio/键盘名/键盘名.uf2"
echo "=========================================="
EOF

chmod +x /workspaces/ZMK-Studio/setup.sh