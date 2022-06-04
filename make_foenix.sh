# convert colors within the header panel
# sed -i 's/\xb0/\x78/g' images/header.raw
# sed -i 's/\x1a/\x79/g' images/header.raw

# convert colors within the footer panel
# sed -i 's/\x10/\x7e/g' images/footer.raw
# sed -i 's/\x22/\x7a/g' images/footer.raw
# sed -i 's/\x8a/\x7d/g' images/footer.raw
# sed -i 's/\x3a/\x7b/g' images/footer.raw
# sed -i 's/\xd4/\x7c/g' images/footer.raw

64tass  --m65816 \
        --long-address \
        --flat \
        --nostart \
        -o efront.pgx \
        --list=efront.lst \
        efront.asm
