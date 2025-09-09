# Detect OS and architecture
OS   := $(shell uname -s)
ARCH ?= $(shell uname -m)

# Compiler and base flags
CC      ?= gcc
CFLAGS  ?= -O -Wall -I./inc -I./htslib
LDFLAGS ?=
HG_DEFS  = -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_GNU_SOURCE -DMACHTYPE_$(ARCH)

# macOS: prefer Homebrew OpenSSL depending on architecture
ifeq ($(OS),Darwin)
  ifeq ($(ARCH),x86_64)
    OPENSSL_PREFIX = /usr/local/opt/openssl@3
  else
    OPENSSL_PREFIX = /opt/homebrew/opt/openssl@3
  endif
  CFLAGS  += -I$(OPENSSL_PREFIX)/include
  LDFLAGS += -L$(OPENSSL_PREFIX)/lib
endif

# Linux: rely on system libs (libssl-dev, zlib1g-dev)
# OPENSSL_INC and OPENSSL_LIB remain empty

# Objects
O1 = aliType.o apacheLog.o asParse.o axt.o axtAffine.o \
     base64.o bits.o binRange.o \
     blastOut.o blastParse.o boxClump.o boxLump.o bPlusTree.o\
     cda.o chain.o chainBlock.o chainConnect.o chainToAxt.o \
     chainToPsl.o cheapcgi.o codebias.o colHash.o common.o \
     correlate.o dgRange.o diGraph.o dlist.o dnaLoad.o dnaMarkov.o \
     dnaseq.o dnautil.o dnaMotif.o dtdParse.o dystring.o \
     emblParse.o errabort.o errCatch.o \
     fa.o ffAli.o ffScore.o filePath.o fixColor.o flydna.o fof.o \
     fuzzyShow.o gapCalc.o gdf.o gemfont.o gfNet.o gff.o gfxPoly.o \
     gifcomp.o gifdecomp.o gifLabel.o gifread.o gifwrite.o hash.o hex.o \
     histogram.o hmmPfamParse.o hmmstats.o htmlPage.o htmshell.o \
     https.o internet.o intExp.o jointalign.o jpegSize.o \
     keys.o kxTok.o linefile.o localmem.o log.o \
     maf.o mafFromAxt.o mafScore.o md5.o \
     memalloc.o memgfx.o mgCircle.o mgPolygon.o mime.o net.o nib.o nibTwo.o \
     nt4.o obscure.o oldGff.o oligoTm.o options.o osunix.o pairHmm.o phyloTree.o \
     pipeline.o portimpl.o pscmGfx.o psGfx.o psl.o pslGenoShow.o \
     pslShow.o pslTbl.o pslTransMap.o psPoly.o pthreadWrap.o qa.o quickHeap.o quotedP.o \
     ra.o rangeTree.o rbTree.o repMask.o rle.o rnautil.o rudp.o scoreWindow.o \
     seqOut.o seqStats.o servBrcMcw.o servcis.o \
     servCrunx.o servcl.o servmsII.o servpws.o shaRes.o \
     slog.o snof.o snofmake.o snofsig.o \
     spacedColumn.o spacedSeed.o spaceSaver.o \
     sqlNum.o sqlList.o subText.o synQueue.o tabRow.o textOut.o tokenizer.o trix.o \
     twoBit.o udc.o verbose.o vGfx.o wildcmp.o wormdna.o \
     xa.o xAli.o xap.o xmlEscape.o xp.o 

O2 = bandExt.o crudeali.o ffAliHelp.o ffSeedExtend.o fuzzyFind.o \
     genoFind.o gfBlatLib.o gfClientLib.o gfInternal.o gfOut.o gfPcrLib.o gfWebLib.o ooc.o \
     patSpace.o supStitch.o trans3.o

# Build rules
all: blat.o jkOwnLib.a jkweb.a htslib/libhts.a
	$(CC) $(CFLAGS) -o pblat blat.o jkOwnLib.a jkweb.a htslib/libhts.a \
	    $(LDFLAGS) -lm -lpthread -lz -lssl -lcrypto
	rm -f *.o *.a

jkweb.a: $(O1)
	ar rcus jkweb.a $(O1)

jkOwnLib.a: $(O2)
	ar rcus jkOwnLib.a $(O2)

blat.o: blatSrc/blat.c
	$(CC) $(CFLAGS) $(HG_DEFS) -c -o blat.o blatSrc/blat.c

$(O1): %.o: lib/%.c
	$(CC) $(CFLAGS) $(HG_DEFS) -c -o $@ $<

$(O2): %.o: jkOwnLib/%.c
	$(CC) $(CFLAGS) $(HG_DEFS) -c -o $@ $<

htslib/libhts.a:
	cd htslib && make clean && make CFLAGS="$(CFLAGS)"

clean:
	rm -f *.o *.a pblat
