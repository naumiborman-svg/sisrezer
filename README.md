# 坦克大战

用 Godot 4.7 做的经典坦克大战（Battle City 风格）。

## 运行

本机已安装 `godot` 时：

```bash
godot --path .
```

或在 Godot 编辑器中打开本仓库。

## 操作

- **WASD / 方向键**：移动
- **空格 / J**：开火
- **Enter**：开始 / 结束后返回标题
- **P / Esc**：暂停

## 规则

- 保护底部老鹰基地，消灭本关全部敌军
- 共 3 关：普通坦克、快速坦克、装甲坦克（装甲需打 3 次）
- 砖墙可被炮弹打碎，钢墙和水无法摧毁
- 基地被毁或生命耗尽则失败

## 开发

```bash
godot --headless --path . --import --quit
godot --headless --path . -s res://tests/smoke.gd
```
