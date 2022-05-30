m8i8            .macro
                sep #$30
                .as
                .xs
                .endmacro

m8i16           .macro
                sep #$20
                .as
                rep #$10
                .xl
                .endmacro

m16i8           .macro
                rep #$20
                .al
                sep #$10
                .xs
                .endmacro

m16i16          .macro
                rep #$30
                .al
                .xl
                .endmacro

m8              .macro
                sep #$20
                .as
                .endmacro

m16             .macro
                rep #$20
                .al
                .endmacro

i8              .macro
                sep #$10
                .xs
                .endmacro

i16             .macro
                rep #$10
                .xl
                .endmacro

setdp           .macro
                pha
                php

                .m16
                lda @w #\1
                tcd
                .dpage \1

                plp
                pla
                .endmacro

setbank         .macro
                pha
                php

                .m8
                lda #\1
                pha
                plb
                .databank \1

                plp
                pla
                .endmacro
