# OpenClaw 部署在未 Root 手机示例

在未 Root 的 Android 手机上通过 Termux + proot 部署 OpenClaw AI 助手。

![未Root部署](https://img.shields.io/badge/Root-No-red)
![配置概览](https://img.shields.io/badge/Device-Android-green)
![框架](https://img.shields.io/badge/Framework-OpenClaw-blue)
![API](https://img.shields.io/badge/API-GLM--4.7-orange)
![远程访问](https://img.shields.io/badge/Remote-Tailscale-purple)

## 说明

本项目展示了在**未 Root 的 Android 手机**上部署 OpenClaw AI 助手的完整方案。通过 Termux + proot 技术在用户空间运行 Linux 环境，无需 Root 权限。

## 性能影响说明

由于使用 proot 进行用户空间模拟，会有以下性能影响：

- **CPU 开销**：proot 模拟会有约 10-20% 的 CPU 性能损耗
- **内存占用**：Ubuntu 环境约占用 500MB-1GB RAM
- **响应速度**：AI 响应主要取决于 API 网络延迟，本地开销较小
- **电池消耗**：后台运行会增加电池消耗

**实际体验**：
- 对于 API 调用型 AI（如 GLM），响应速度主要取决于网络延迟
- 本地 proot 开销对整体体验影响有限
- 日常使用完全可用，响应速度"见仁见智"

> 💡 **Root 手机优势**：如果手机已 Root，可直接使用 chroot 或容器技术，性能会有更好表现。本方案适用于未 Root 手机。

## 配置概览

| 配置项 | 内容 |
|--------|------|
| 设备 | vivo V2055A (Android 14) + Windows 11 电脑 |
| Linux 环境 | Andronix Ubuntu 22.04 XFCE (ARM64) in Termux (proot) |
| AI 框架 | OpenClaw 2026.2.2-3 |
| LLM API | GLM-4.7 (智谱 AI Zhipu AI) |
| 远程访问 | Tailscale P2P VPN + SSH 密钥认证 |
| 运行时 | Node.js 22.12.0 + npm 10.9.0 |

## 功能特点

- **无需 Root** - 通过 Termux + proot 在用户空间运行 Linux
- **随时可用** - 通过 Tailscale，手机在任何网络（4G/5G/WiFi）都能被访问
- **安全可靠** - SSH 密钥认证，密码登录已禁用
- **成本低廉** - 使用 GLM API，相比 OpenAI 更经济
- **轻量便携** - 所有组件运行在 Android 手机上，无需额外服务器
- **稳定运行** - Bionic Bypass 确保 OpenClaw 在 Android 环境稳定运行
- **联网搜索** - Brave Search 集成，AI 可获取最新网络信息（需配置代理）

## 快速开始

### 1. 运行启动脚本

双击运行 `start-openclaw.bat`，输入手机 IP 地址即可自动连接。

### 2. 完整配置

查看 [完整配置指南](./docs/完整配置指南.md) 了解详细步骤。

## 文件说明

```
.
├── start-openclaw.bat       # Windows 启动脚本（自动连接）
├── docs/
│   └── 完整配置指南.md       # 详细安装配置文档
└── README.md                # 本文件
```

## 使用流程

### 手机端

1. 打开 Termux App
2. 运行: `ubuntu`
3. 确保 Tailscale App 正在运行
4. 在 Termux 新窗口中: `sshd`
5. 在 Ubuntu 中: `openclaw gateway`

### 电脑端

双击运行 `start-openclaw.bat`，输入手机 IP 地址，自动打开浏览器访问。

## 核心技术

### Bionic Bypass（Android 必需）

Android 的 Bionic C 库与 glibc 不完全兼容，需要特殊处理：

```bash
# 创建 hijack.js
cat > ~/hijack.js << "EOF"
const os = require("os");
os.networkInterfaces = () => ({});
EOF

# 设置 NODE_OPTIONS（已在启动脚本中配置）
export NODE_OPTIONS="-r /root/hijack.js"
```

### proot 用户空间模拟

使用 proot 在用户空间模拟 Linux 环境：
- 无需 Root 权限
- 通过系统调用翻译实现
- 有一定性能开销但完全可用

### Brave Search 搜索功能

需要配置代理（api.search.brave.com 被墙）：

```bash
# 编辑代理配置
nano ~/.proxy.conf

# 取消注释并修改端口
export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890
```

### SSH 快捷启动

```bash
# 在 Termux 中设置快捷命令
echo 'sshd() { sshd -o PasswordAuthentication=no; }' >> ~/.bashrc
source ~/.bashrc

# 之后直接输入 sshd 即可启动
sshd
```

## 故障排除

### OpenClaw 启动失败

```bash
# 检查 NODE_OPTIONS
echo $NODE_OPTIONS  # 应该显示: -r /root/hijack.js

# 检查符号链接
ls -l /usr/bin/openclaw
```

### Brave Search 搜索失败

```bash
# 检查 API Key
openclaw config get skills.brave-search.apiKey

# 检查代理配置
cat ~/.proxy.conf
```

### SSH 连接被拒绝

```bash
pkill sshd && sshd -o PasswordAuthentication=no
```

## 系统要求

### 手机端

- Android 10+
- Termux
- Andronix Ubuntu 22.04
- 至少 3GB RAM（推荐 4GB+）
- 至少 4GB 可用存储（推荐 8GB+）

### 电脑端

- Windows 10/11
- SSH 客户端（Windows 自带）
- Tailscale（可选）

## 常见问题

**Q: 未 Root 手机性能如何？**

A: proot 会有约 10-20% 性能损耗，但对于 API 型 AI（如 GLM），响应主要取决于网络延迟，实际体验完全可用。

**Q: Root 手机有更好方案吗？**

A: Root 手机可直接使用 chroot、LXC 或容器技术，性能会更接近原生 Linux。本方案适用于未 Root 手机。

**Q: 手机 IP 地址经常变化怎么办？**

A: 使用启动脚本时输入当前 IP 即可。查看 IP：
```bash
ip addr show wlan0 | grep 'inet '
```

**Q: 忘记 Token 怎么办？**

A: 在 Ubuntu 中执行：
```bash
openclaw config get gateway.token
```

**Q: Brave Search 为什么需要代理？**

A: api.search.brave.com 在中国大陆被墙，需要代理才能访问。

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关链接

- [OpenClaw 官网](https://openclaw.com/)
- [GLM API 文档](https://open.bigmodel.cn/)
- [Brave Search API](https://brave.com/search/api/)
- [Tailscale](https://tailscale.com/)
- [Termux Wiki](https://wiki.termux.com/)
- [Andronix](https://andronix.app/)
- [proot GitHub](https://github.com/proot-me/proot)

---

**文档版本：** v4.0
**最后更新：** 2026年2月6日
