.SUFFIXES:

.SECONDARY:

BUILD_DIR = ../build/progs
LIB_BUILD_DIR = $(BUILD_DIR)/lib
OUT_DIR = ../build

PLATAFORMA = riscv64-unknown-elf-
AS = $(PLATAFORMA)as
LD = $(PLATAFORMA)gcc
CC = $(PLATAFORMA)gcc
AR = $(PLATAFORMA)ar
OBJCOPY = $(PLATAFORMA)objcopy

ARCH = -march=rv32i -mabi=ilp32
CCFLAGS = $(ARCH) -Wall -Wextra -Werror
ASFLAGS = $(ARCH)
LDFLAGS = $(ARCH) -T link_script.ld -nostartfiles -nodefaultlibs

CPROGS = $(basename $(wildcard *.c))
MILIB = $(BUILD_DIR)/milib.a
MILIB_SRCS = $(strip $(wildcard lib/*.S lib/*.c))
MILIB_OBJS = $(addprefix $(BUILD_DIR)/,$(addsuffix .o,$(basename $(MILIB_SRCS))))

-include $(BUILD_DIR)/*.d
-include $(LIB_BUILD_DIR)/*.d

all : $(addprefix $(OUT_DIR)/,$(addsuffix .txt,$(basename $(wildcard *.c *.S))))

% : $(OUT_DIR)/%.txt ;

$(OUT_DIR)/%.txt : $(BUILD_DIR)/%.elf
	$(OBJCOPY) -O binary $^ $(BUILD_DIR)/$(*F).bin
	xxd -c 4 -e -g 4 -R never $(BUILD_DIR)/$(*F).bin | sed -nE '{s/^\S+\s+(\S+).*/\1/ ; p}'	>$@

$(BUILD_DIR)/%.elf : $(BUILD_DIR)/%.o
	$(LD) $(LDFLAGS) -o $@ $^ $(if $(findstring $(*F),$(CPROGS)),$(MILIB))

$(BUILD_DIR)/%.o : %.S | $(BUILD_DIR) $(LIB_BUILD_DIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/%.o : %.c | $(BUILD_DIR) $(LIB_BUILD_DIR) $(MILIB)
	$(CC) $(CCFLAGS) -c -MMD -o $@ $<

$(MILIB) : $(MILIB_OBJS)
	$(AR) rcs $(MILIB) $(MILIB_OBJS)

$(BUILD_DIR) $(LIB_BUILD_DIR) : % :
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)
