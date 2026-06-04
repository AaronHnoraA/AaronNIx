# nix-darwin 更新策略

这份配置现在不再区分日常更新、受控更新和 Emacs 保护更新。所有系统更新入口都走同一条全量链路。

## 核心规则

- 不再安装或更新 `emacs-plus-app@master`。
- 不再使用 `emacs-overlay`。
- 不再维护 Homebrew protected formula/cask 名单。
- `daily`、`controlled-full` 是兼容别名，最终都调用 `full-update`。
- 更新流程不会调用 `nvim --headless` 做 Neovim 插件更新。

## 常用命令

### 全量更新

```sh
nix-darwin full
```

等价于：

```sh
make full-update
```

会执行：

- `brew update`
- `brew upgrade`
- `brew upgrade --cask`
- `nix flake update`
- `darwin-rebuild`
- `home-manager-switch`
- 用户工具全量更新

### 兼容入口

以下命令仍然保留，但都等价于全量更新：

```sh
nix-darwin daily
nix-darwin controlled-full
make daily-update
make controlled-full-update
```

## 用户工具更新

用户工具更新脚本在：

```text
modules/home-manager/scripts/bin/nix-darwin-update-user-tools
```

日常模式会尝试更新：

- npm 全局包：`npm update -g`
- cargo 安装的二进制：`cargo install-update -a`
- conda 包管理器：`conda update -n base -c defaults conda -y`

全量模式额外会尝试：

```sh
rustup update
conda update --all -y
```

如果没有安装 `cargo-install-update`，脚本会跳过 cargo-installed binaries，并给出提示。

## 全局入口

全局命令脚本在：

```text
modules/home-manager/scripts/bin/nix-darwin
```

Home Manager 会把它链接到：

```text
~/.local/bin/nix-darwin
```

默认仓库路径是：

```sh
~/.nixpkgs
```

如果以后配置仓库移动，可以设置：

```sh
export NIX_DARWIN_CONFIG=/path/to/nix-config
```

## Neovim 插件

系统更新流程不更新 Neovim 插件。需要更新插件时，进入 Neovim 后手动使用配置里的插件管理命令。
