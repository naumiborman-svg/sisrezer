; =============================================================
; hello.s - NES 自制程序示例 (Homebrew "HELLO NES WORLD!")
; 汇编器: ca65 (cc65 工具链)
; 目标:   NROM-128 (Mapper 0), 16KB PRG-ROM + 8KB CHR-ROM
; =============================================================

; ---------- iNES 文件头 ----------
.segment "HEADER"
        .byte "NES", $1A        ; iNES 魔数
        .byte $01               ; PRG-ROM: 1 x 16KB
        .byte $01               ; CHR-ROM: 1 x 8KB
        .byte $00               ; Mapper 0, 水平镜像
        .byte $00
        .res  8, $00

; ---------- 零页变量 ----------
.segment "ZEROPAGE"
frame:   .res 1                 ; 帧计数器
colidx:  .res 1                 ; 当前文字颜色索引

; ---------- 字符 → 图块索引 ----------
SP = 0                          ; 空格(空白图块)
H  = 1
E  = 2
L  = 3
O  = 4
N  = 5
S  = 6
W  = 7
R  = 8
D  = 9
EX = 10                         ; 感叹号

; ---------- 主程序 ----------
.segment "CODE"
reset:
        sei                     ; 关中断
        cld                     ; 关十进制模式(NES 无此功能,惯例清除)
        ldx #$40
        stx $4017               ; 禁用 APU 帧中断
        ldx #$FF
        txs                     ; 初始化栈指针
        inx                     ; X = 0
        stx $2000               ; 禁用 NMI
        stx $2001               ; 关闭渲染
        stx $4010               ; 禁用 DMC IRQ

        bit $2002               ; 清除 VBlank 标志
vblank1:                        ; 等待第一次 VBlank
        bit $2002
        bpl vblank1

clrmem:                         ; 清零 2KB 内存
        lda #$00
        sta $0000,x
        sta $0100,x
        sta $0200,x
        sta $0300,x
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne clrmem

vblank2:                        ; 等待第二次 VBlank,PPU 就绪
        bit $2002
        bpl vblank2

        ; ----- 写入调色板 -----
        lda $2002               ; 重置 PPU 地址锁存器
        lda #$3F
        sta $2006
        lda #$00
        sta $2006
        ldx #$00
palette_loop:
        lda palette,x
        sta $2007
        inx
        cpx #$20
        bne palette_loop

        ; ----- 清空命名表 0 (1024 字节) -----
        lda $2002
        lda #$20
        sta $2006
        lda #$00
        sta $2006
        ldx #$04
        ldy #$00
        lda #SP
clear_nt:
        sta $2007
        iny
        bne clear_nt
        dex
        bne clear_nt

        ; ----- 在屏幕中央写入文字 -----
        ; 第 14 行第 8 列: $2000 + 14*32 + 8 = $21C8
        lda $2002
        lda #$21
        sta $2006
        lda #$C8
        sta $2006
        ldx #$00
msg_loop:
        lda message,x
        sta $2007
        inx
        cpx #msg_len
        bne msg_loop

        ; ----- 重置滚动并开启渲染 -----
        lda #$00
        sta $2005
        sta $2005
        lda #%10000000          ; 开启 NMI
        sta $2000
        lda #%00001010          ; 显示背景(含最左 8 像素)
        sta $2001

forever:
        jmp forever             ; 主循环空转,逻辑都在 NMI 中

; ---------- NMI: 每帧执行,让文字颜色循环变化 ----------
nmi:
        pha
        txa
        pha

        inc frame
        lda frame
        and #$0F                ; 每 16 帧换一次颜色
        bne nmi_scroll

        inc colidx
        lda colidx
        and #$07                ; 8 种颜色循环
        tax
        lda colors,x
        ldx $2002               ; 重置地址锁存器
        ldx #$3F
        stx $2006
        ldx #$01
        stx $2006
        sta $2007               ; 更新调色板颜色 1(文字颜色)

nmi_scroll:
        lda $2002               ; 重置地址锁存器
        lda #%10000000          ; 重写 PPUCTRL,复位命名表选择位
        sta $2000               ; (写 $2006 会污染 t 寄存器的 NT 位,必须恢复)
        lda #$00
        sta $2005               ; 恢复滚动位置
        sta $2005

        pla
        tax
        pla
        rti

irq:
        rti

; ---------- 数据 ----------
palette:
        ; 背景调色板 4 组 + 精灵调色板 4 组(本例只用第 1 组)
        .byte $0F,$30,$30,$30, $0F,$30,$30,$30
        .byte $0F,$30,$30,$30, $0F,$30,$30,$30
        .byte $0F,$30,$30,$30, $0F,$30,$30,$30
        .byte $0F,$30,$30,$30, $0F,$30,$30,$30

colors: ; 文字循环颜色: 白、蓝、绿、橙、粉、青、黄、红
        .byte $30,$21,$2A,$27,$24,$2C,$28,$16

message:
        .byte H,E,L,L,O, SP, N,E,S, SP, W,O,R,L,D, EX
msg_len = * - message

; ---------- 中断向量 ----------
.segment "VECTORS"
        .word nmi               ; $FFFA NMI
        .word reset             ; $FFFC RESET
        .word irq               ; $FFFE IRQ/BRK

; ---------- CHR-ROM 图块数据 (8x8 像素/图块, 16 字节/图块) ----------
.segment "CHARS"
        ; 图块 0: 空白(空格)
        .res 16, $00

        ; 图块 1: H
        .byte $66,$66,$66,$7E,$66,$66,$66,$00
        .res 8, $00
        ; 图块 2: E
        .byte $7E,$60,$60,$7C,$60,$60,$7E,$00
        .res 8, $00
        ; 图块 3: L
        .byte $60,$60,$60,$60,$60,$60,$7E,$00
        .res 8, $00
        ; 图块 4: O
        .byte $3C,$66,$66,$66,$66,$66,$3C,$00
        .res 8, $00
        ; 图块 5: N
        .byte $66,$76,$7E,$7E,$6E,$66,$66,$00
        .res 8, $00
        ; 图块 6: S
        .byte $3E,$60,$60,$3C,$06,$06,$7C,$00
        .res 8, $00
        ; 图块 7: W
        .byte $63,$63,$63,$6B,$7F,$77,$63,$00
        .res 8, $00
        ; 图块 8: R
        .byte $7C,$66,$66,$7C,$6C,$66,$66,$00
        .res 8, $00
        ; 图块 9: D
        .byte $7C,$66,$66,$66,$66,$66,$7C,$00
        .res 8, $00
        ; 图块 10: !
        .byte $18,$18,$18,$18,$18,$00,$18,$00
        .res 8, $00
