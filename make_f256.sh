
# -------------------------------------

mkdir -p obj/

# -------------------------------------

64tass  --m65c02 \
        --flat \
        --nostart \
        -o obj/efmap.bin \
        data/MAP.inc

64tass  --m65c02 \
        --flat \
        --nostart \
        -o obj/eftiles.bin \
        data/TILES.inc

# -------------------------------------

64tass  --m65816 \
        --c256-pgz \
        --output-exec=BOOT_ \
        --long-address \
        -D PGZ=1 \
        -o obj/efront.pgz \
        --list=obj/efront.lst \
        --labels=obj/efront.lbl \
        efront.asm
