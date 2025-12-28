
# Ausführen im ordner bin !
# das setzt vorraus, dass luac.cross im pfad vorhanden ist
for F in ../src/*.lua; do luac.cross.int -o "../src/lc/${F%.*}.lc" $F ;done
# for F in ../src/*.lua; do luac.cross.int -s -o "../src/nodebug/${F%.*}.lc" $F ;done

luac.cross.int -o ./smartmeter.img -f ../src/*.lua
# luac.cross.int -o ./lc/smartmeter.img -f ./lc/*.lc
# luac.cross.int -s -o ./nodebug/smartmeter.img -f ./nodebug/*.lc
