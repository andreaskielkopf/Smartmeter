
for F in *.lua; do luac.cross -o "./lc/${F%.*}.lc" $F ;done

luac.cross -o ./lc/smartmeter.img -f *.lua

for F in *.lua; do luac.cross -s -o "./nodebug/${F%.*}.lc" $F ;done

luac.cross -s -o ./nodebug/smartmeter.img -f *.lua

echo "first upload 'smartmeter.img', '_init.lc', 'start.lc'"
echo "then execute:"
echo "node.flashreload('smartmeter.img')"