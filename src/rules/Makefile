QCC=fteqcc

all:
	mkdir -pv ../../progs/
	$(QCC) $(CFLAGS) -I../../../src/server deathmatch.qc 
	$(QCC) $(CFLAGS) -I../../../src/server singleplayer.qc
	$(QCC) $(CFLAGS) -I../../../src/server invasion.qc
