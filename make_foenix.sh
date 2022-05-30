
64tass  --m65816 \
        --long-address \
        --flat \
        --nostart \
        -o EFT18Combat.bin \
        --list=EFT18Combat.lst \
        EFT18Combat.asm

64tass  --m65816 \
        --long-address \
        --flat \
        --nostart \
        -o EFT18Data.bin \
        --list=EFT18Data.lst \
        EFT18Data.asm

64tass  --m65816 \
        --long-address \
        --flat \
        --nostart \
        -o EFT18Interrupt.bin \
        --list=EFT18Interrupt.lst \
        EFT18Interrupt.asm

64tass  --m65816 \
        --long-address \
        --flat \
        --nostart \
        -o EFT18Mainline.bin \
        --list=EFT18Mainline.lst \
        EFT18Mainline.asm

64tass  --m65816 \
        --long-address \
        --flat \
        --nostart \
        -o EFT18Thinking.bin \
        --list=EFT18Thinking.lst \
        EFT18Thinking.asm

cat EFT18Thinking.bin EFT18Combat.bin EFT18Data.bin EFT18Mainline.bin EFT18Interrupt.bin > efront.pgx
