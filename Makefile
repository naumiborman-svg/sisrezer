CA65    := ca65
LD65    := ld65
BUILD   := build
ROM     := $(BUILD)/hello.nes

.PHONY: all clean run

all: $(ROM)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/hello.o: src/hello.s | $(BUILD)
	$(CA65) -g -o $@ $<

$(ROM): $(BUILD)/hello.o nes.cfg
	$(LD65) -C nes.cfg -o $@ $< -m $(BUILD)/hello.map
	@echo "==> 生成 $(ROM) ($$(stat -c%s $(ROM)) 字节)"

run: $(ROM)
	fceux $(ROM) || /usr/games/fceux $(ROM)

clean:
	rm -rf $(BUILD)
