#!/usr/bin/env bash

set -ex

{

export MAKEFLAGS=-j16

STARTDIR=$(git rev-parse --show-toplevel)

./build-setup.sh riscv-tools -f

source $STARTDIR/.conda-env/etc/profile.d/conda.sh

source env.sh

./scripts/firesim-setup.sh
cd sims/firesim
source sourceme-f1-manager.sh --skip-ssh-setup

git apply ../../scripts/fsim-diff

cd sim
unset MAKEFLAGS
make verilator
export MAKEFLAGS=-j16

cd $STARTDIR/software/firemarshal
./init-submodules.sh
marshal -v build br-base.json

cd $STARTDIR
./scripts/repo-clean.sh

cd $STARTDIR
# use htif.ld with big heap
cd generators/compress-acc
cp htif.ld $RISCV/riscv64-unknown-elf/lib/

cd $STARTDIR

echo "export COMPRESSACC_FSIM=$(pwd)/generators/compress-acc/firesim-workloads/" >> env.sh
echo "export HYPER_RESULTS=$(pwd)/generators/compress-acc/firesim-workloads/hyper_results/" >> env.sh
echo "export COMPRESSACC_SRC=$(pwd)/generators/compress-acc/src/main/scala/" >> env.sh
echo "export BUILT_HWDB_ENTRIES=$(pwd)/sims/firesim/deploy/built-hwdb-entries/" >> env.sh

echo "first-clone-setup-fast.sh complete."

} 2>&1 | tee first-clone-setup-fast-log
