Styled and inspired by [this](https://github.com/ThePrimeagen/init.lua).

Prerequisite: install [ripgrep](https://github.com/BurntSushi/ripgrep#installation)

## Install ripgrep

**Termux**
```
pkg install ripgrep
```

**PC**
```
cargo install ripgrep
```

## Backup config

**Termux**
```
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
```

**Windows**
```
rename %LOCALAPPDATA%\nvim %LOCALAPPDATA%\nvim.bak
rename %LOCALAPPDATA%\nvim-data %LOCALAPPDATA%\nvim-data.bak
```

## Clone to config

**Termux**
```
git clone ... ~/.config/nvim
```

**Windows**
```
git clone ... %LOCALAPPDATA%\nvim
```
