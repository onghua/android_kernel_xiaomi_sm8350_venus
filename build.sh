#!/bin/bash
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

# 内核工作目录
export KERNEL_DIR=$(pwd)

# 内核 defconfig 文件
export KERNEL_DEFCONFIG=venus_defconfig

# 编译临时目录，避免污染根目录
export OUT=out

# 环境配置
export CLANG_PATH=/home/kkk/sm8350/clang-r383902
export GCC64_PATH=/home/kkk/sm8350/gcc-arm64-13

# 添加工具链到 PATH
export PATH=${CLANG_PATH}/bin:${GCC64_PATH}/bin:${PATH}

# arch平台
export ARCH=arm64
export SUBARCH=arm64

# 只使用clang编译需要配置
export LLVM=1

# 编译时线程指定
TH_COUNT=32
if [[ "" != "$1" ]]; then
    TH_COUNT=$1
fi

# 编译参数 - 使用 ARM 官方工具链前缀
export DEF_ARGS="O=${OUT} \
ARCH=${ARCH} \
CROSS_COMPILE=${GCC64_PATH}/bin/aarch64-none-linux-gnu- \
CLANG_TRIPLE=aarch64-none-linux-gnu- \
CC=${CLANG_PATH}/bin/clang \
AR=${CLANG_PATH}/bin/llvm-ar \
NM=${CLANG_PATH}/bin/llvm-nm \
LD=${CLANG_PATH}/bin/ld.lld \
HOSTCC=${CLANG_PATH}/bin/clang \
HOSTCXX=${CLANG_PATH}/bin/clang++ \
OBJCOPY=${CLANG_PATH}/bin/llvm-objcopy \
OBJDUMP=${CLANG_PATH}/bin/llvm-objdump \
READELF=${CLANG_PATH}/bin/llvm-readelf \
OBJSIZE=${CLANG_PATH}/bin/llvm-size \
STRIP=${CLANG_PATH}/bin/llvm-strip \
LLVM_IAS=1 \
LLVM=1"
                           
export BUILD_ARGS="-j${TH_COUNT} ${DEF_ARGS}"

echo "=============== Make defconfig ==============="
make ${DEF_ARGS} ${KERNEL_DEFCONFIG}
if [[ "0" != "$?" ]]; then
        echo -e ">>> make defconfig error!"
        exit 1
fi

echo "=============== Make Kernel  ==============="
make ${BUILD_ARGS}
if [[ "0" != "$?" ]]; then
        echo ">>> build kernel error!"
        exit 1
fi

echo ">>> build Kernel success!"
ls -lh ${OUT}/arch/arm64/boot/Image
exit 0
