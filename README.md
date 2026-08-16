# NES ROM 编译项目

使用开源 **cc65 工具链**(`ca65` 汇编器 + `ld65` 链接器)将 6502 汇编源码编译成
可在模拟器或真机上运行的 `.nes` ROM 文件。

内含一个原创自制(homebrew)示例程序:屏幕中央显示 "HELLO NES WORLD!",
文字颜色每 16 帧循环变化一次。

## 项目结构

```
.
├── Makefile        # 构建脚本
├── nes.cfg         # ld65 链接脚本 (NROM-128 / Mapper 0 内存布局)
├── src/
│   └── hello.s     # 6502 汇编源码(含 iNES 头、程序、调色板、CHR 图块)
└── build/          # 构建输出目录(git 忽略)
    └── hello.nes   # 编译生成的 ROM
```

## 环境依赖

```bash
# Debian / Ubuntu
sudo apt-get install cc65        # 编译工具链(必需)
sudo apt-get install fceux       # NES 模拟器(可选,用于运行测试)
```

## 编译

```bash
make
```

输出 `build/hello.nes`(24592 字节 = 16 字节 iNES 头 + 16KB PRG-ROM + 8KB CHR-ROM)。

## 运行

```bash
make run            # 使用 FCEUX 打开编译好的 ROM
```

也可以将 `build/hello.nes` 拖入任意 NES 模拟器(FCEUX、Mesen、Nestopia 等)。

## 工作原理

1. `ca65` 将 `src/hello.s` 汇编为目标文件 `build/hello.o`;
2. `ld65` 按照 `nes.cfg` 中定义的内存布局,把各段
   (`HEADER` / `CODE` / `VECTORS` / `CHARS`)拼装成最终的 `.nes` 文件;
3. `.nes` 文件采用 iNES 格式:前 16 字节是文件头(魔数 `NES\x1A`、
   PRG/CHR 大小、Mapper 编号等),之后依次是 PRG-ROM(程序)和
   CHR-ROM(图块数据)。

## 扩展

- 新增程序:在 `src/` 下编写 `.s` 文件,并在 `Makefile` 中添加对应规则;
- 想用 C 语言开发,可使用同一工具链中的 `cc65` 编译器配合 NES 运行时库;
- 更大的游戏需换用其他 Mapper(如 MMC1/MMC3),相应调整 `nes.cfg` 与 iNES 头。
