# nix-darwin 更新策略

这份配置的目标是：日常可以放心更新系统和常用工具，但对 Emacs 这类敏感软件保持显式授权更新。

## 核心规则

- 日常更新不会自动升级 `emacs-plus-app@master`。
- `emacs-plus-app@master` 是 Homebrew cask，不是 Nix 包，也不是 Homebrew formula。
- 受控 Homebrew 更新由 nix-darwin activation 执行，会跳过保护名单。
- flake 更新默认只更新批准列表，不更新 `emacs-overlay`。
- 真正的全量更新入口仍然保留，但它会调用原生 Homebrew 和全量 flake update，适合有时间处理配置破损时使用。

## 常用命令

### 日常更新

```sh
nix-darwin daily
```

等价于：

```sh
make daily-update
```

会执行：

- `darwin-rebuild`
- `home-manager-switch`
- 日常用户工具更新：npm、cargo、conda
- 受控 Homebrew 更新

受控 Homebrew 更新会：

- 执行 `brew update`
- 升级当前 Homebrew 中 outdated 的 formula 和 cask
- 跳过 `local.homebrew.protectedFormulae`
- 跳过 `local.homebrew.protectedCasks`

默认保护名单包含：

```nix
"emacs-plus-app@master"
```

### 受控全量更新

```sh
nix-darwin controlled-full
```

等价于：

```sh
make controlled-full-update
```

会先更新批准的 flake inputs，然后执行日常更新。

批准的 flake inputs 在 `Makefile` 里：

```make
APPROVED_NIX_INPUTS
```

默认不会更新：

```make
PROTECTED_NIX_INPUTS = emacs-overlay
```

### 全量更新

```sh
nix-darwin full
```

等价于：

```sh
make full-update
```

这个入口不做保护，会直接调用原生更新：

```sh
brew update
brew upgrade
brew upgrade --cask
nix flake update
```

然后执行：

- `darwin-rebuild`
- `home-manager-switch`
- 更激进的用户工具更新

这个命令会升级 `emacs-plus-app@master`，适合空闲时主动处理破损风险。

## 单独更新保护项

更新 Homebrew 保护名单里的软件：

```sh
nix-darwin brew-update-protected
```

Emacs 兼容别名：

```sh
nix-darwin brew-update-emacs
```

更新受保护的 flake inputs：

```sh
nix-darwin flake-update-protected
```

Emacs 兼容别名：

```sh
nix-darwin flake-update-emacs
```

## 保护名单

保护名单在：

```text
modules/darwin/common/brew/default.nix
```

对应字段：

```nix
local.homebrew.protectedFormulae = [
  # "some-formula"
];

local.homebrew.protectedCasks = [
  "emacs-plus-app@master"
];
```

以后如果某个软件也对版本变化敏感，把它加入对应列表即可。

## 用户工具更新

用户工具更新脚本在：

```text
modules/home-manager/scripts/bin/nix-darwin-update-user-tools
```

日常模式会尝试更新：

- npm 全局包：`npm update -g`
- cargo 安装的二进制：`cargo install-update -a`
- conda 包管理器：`conda update -n base -c defaults conda -y`

cargo 批量更新依赖：

```sh
cargo install cargo-update
```

如果没有安装 `cargo-install-update`，脚本会跳过 cargo-installed binaries，并给出提示。

全量模式额外会尝试：

```sh
rustup update
conda update --all -y
```

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

## 推荐使用方式

忙的时候：

```sh
nix-darwin daily
```

有一点时间，但仍然不想碰 Emacs：

```sh
nix-darwin controlled-full
```

空闲时，允许所有东西升级，包括 Emacs：

```sh
nix-darwin full
```
