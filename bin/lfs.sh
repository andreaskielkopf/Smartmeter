
# Ausführen im ordner bin !
# das setzt vorraus, dass luac.cross im pfad vorhanden ist
cd ../src/
for F in *.lua; do N="${F%.*}"; ../bin/luac.cross.int -o "./lc/$N.lc" $F;echo -n "$N " ;done
# for F in ../src/*.lua; do luac.cross.int -s -o "../src/nodebug/${F%.*}.lc" $F ;done
echo ' '
../bin/luac.cross.int -o ./smartmeter.img -f *.lua
# luac.cross.int -o ./lc/smartmeter.img -f ./lc/*.lc
# luac.cross.int -s -o ./nodebug/smartmeter.img -f ./nodebug/*.lc
