# AWA-Helper on Fly.io

镜像：`ghcr.io/your-github-username/awa-helper-fly:latest`

本目录在官方 `hclonely/awa-helper:latest` 上增加首次配置导入和一个 Fly Volume 的初始化。配置、日志、运行数据分别保存在 `/data/config`、`/data/logs`、`/data/data`。程序以 node 用户运行，默认常驻 Manager。源代码更新无需同步到此 fork；工作流每次拉取最新官方镜像。

## 构建镜像

打开 Actions → **Build Fly image** → Run workflow。main 上相关文件变更会触发构建；每天 UTC 02:00（北京时间 10:00）也会重建。fork 的定时工作流可能需要先在 Actions 中启用；长期没有仓库活动时，GitHub 可能停用定时任务，手动运行仍可用。

首次发布后，在 GitHub Packages 中把 awa-helper-fly 的 visibility 设为 **Public**。工作流只发布镜像，不自动部署 Fly。

## Ubuntu 首次部署

安装 Fly CLI 并登录后，在本目录执行：

```bash
fly auth login
fly apps create your-app-name
curl -fL https://raw.githubusercontent.com/HCLonely/AWA-Helper/main/config.example.yml -o config.yml
nano config.yml
```

在完整模板中修改：
- webUI.enable: true，webUI.port: 2345，webUI.local: false。
- autoUpdate: false（容器通过替换镜像更新）。
- manager.secret：填写长随机密码。
- manager.timezone: Asia/Shanghai。
- awaCookie：填写自己的 Cookie。
- proxy.enable: []，关闭默认本机代理。
- Twitch、Steam 任务配置凭据之前保持关闭。

公开文件仅包含占位符。部署前在本地将 fly.toml 的 app 和命令中的 your-app-name 替换为真实应用名，将镜像中的 your-github-username 替换为镜像所属用户名。不要把替换后的真实部署配置提交到公开仓库。

```bash
fly volumes create awa_data --region sin --size 1 -a your-app-name
fly secrets set "AWA_CONFIG=$(base64 -w 0 config.yml)" --stage -a your-app-name
fly deploy --ha=false
```

执行 `fly apps open` 打开管理页面，以 manager.secret 登录。Manager 默认等待定时计划，也可在网页手动启动任务。机器和数据卷会产生费用。

## 更新

先运行 **Build Fly image** 并等待成功，再在本目录执行：

```bash
fly deploy --ha=false
```

不需要 --no-cache，因为 Fly 直接拉取镜像，不进行构建。部署会短暂重启服务。

后续配置在 WebUI 修改；初始 Secret 只在卷中没有配置时导入，再次上传 Secret 不会覆盖已有配置。不要删除数据卷。不要提交 Cookie、config.yml 或 Fly token。fly.toml 中的 AWA_CONFIG 是 Secret 名称，不是实际内容。

## 排查

```bash
fly status
fly logs
```

工作流验证镜像文件、脚本语法及 node 用户切换；未使用真实账号运行 AWA 任务。
