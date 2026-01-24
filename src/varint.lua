-- Implementierung des varint Verfahrens, das "echte" Strings aus Zahlen erzeugt
do
   print 'load varint'
   local M= {}
   local max= 125 -- 250/2 256 Zeichen sind möglich, 6 sind ausgelassen

   -- codierung für kleine Zahlen, so dass \0, LF, CR, ", ' und \\ nicht vorkommen
   local function toS(a)
      if a>=92-5 then return a+6 end -- \
      if a>=39-4 then return a+5 end -- '
      if a>=34-3 then return a+4 end -- "
      if a>=13-2 then return a+3 end -- CR
      if a>=10-1 then return a+2 end -- LF
      return a+1 end -- null

   -- Rückkodierung
   local function toZ(a)
      if a>92 then return a-6 end -- \
      if a>39 then return a-5 end -- '
      if a>34 then return a-4 end -- "
      if a>13 then return a-3 end -- CR
      if a>10 then return a-2 end -- LF
      return a-1 end -- null
   --for t=0, 249 do print(t, toS(t), string.char(toS(t)), toZ(toS(t)), t-toZ(toS(t))) end

   -- wandelt eine positive zahl in einen String um (31Bit)
   local function var2str(z)
      local out= {}
      repeat
         local a= z%max
         z= math.floor( z/max) -- float build
         --         z= z/max -- integer build
         if z~=0 then a= a+max end
         out[#out+1] =  string.char(toS(a))
      until z==0
      return table.concat(out)
   end

   -- wandelt einen String  in eine positive Zahl (31Bit) um
   local function str2var(s,p)      --p= p or 1
      local z,f,b,c,x= 0,1
      for i= p or 1, #s do
         --      print(s,i,#s)
         b= toZ(s:byte(i))         --         print(i,b,z,f)
         if b<max then return z+b*f,i end
         z= z+(b-max)*f f= f*max
      end end -- return nil
   --   local q,j,l -- test
   --   for i=0, 0x7fffffff ,57  do
   --      j,l=str2var(var2str(i))
   --      if i~=j then print (i,j,l) end end

   -- wandelt ein array von Ints(31Bit) in einen String mit Varints um
   local function vars2str(t)
      local s={} -- '0v' -- markierung für string mit varints -> table of ints
      if t==nil or type(t)~='table' or #t < 1 then return "" end
      for k,v in ipairs(t) do
         s[#s+1]=var2str(v)
      end return table.concat(s) end
   --   local a={} for i=1,60 do a[i]= i*(i+37)/19 end a= vars2str(a) print (a)
   local a={} for i=1,60 do a[i]= i*1000 end a= vars2str(a)
   --   print(a)

   -- Iterator über einen String der Zahlen findet und zurückgibt
   local function nextZahl(s)
      local i, p= 0, 0 -- index der Zahl, position im String
      return function()
         local z
         if p+1<=#s then i= i+1 -- print(s,p,#s)
            z,p= str2var(s,p+1) -- print (z,p)
            if z then return i, z end -- iterator läuft weiter
         end end end -- iterator beenden return nil
   --   for k,v in nextZahl(a) do print (k,v) end print (#a)

   -- wandelt einen String mit Varints in ein array von Ints(je 31Bit)
   local function str2vars(t)
      local a={}
      for k,v in nextZahl(t) do a[k]=v end
      return a end
   --   for k,v in ipairs(str2vars(a)) do print (k,v) end

   -- Wandelt einen Datensatz mit Kennung, Nr und Array[int] zu einer Zeile im Dateisystem
   local function data2Line(k,n,a)
      -- Ziel: kennung als text (0-x char, [a-z]), stunde (00-23 2char[0-9]), string mit varint beliebig (bis zu 60)
      local z1= (n<=9) and '0' or ''
      local l={k,z1,tostring(n),vars2str(a)}
      return table.concat(l) end

   -- Wandelt eine Zeile aus dem Dateisystem in einen Datensatz mit Kennung, Nr und Array[int]
   local function line2Data(l)
      local k,n,a=l:match("^(%a*)(%d%d)(.*)$") -- print(#k,#n,#a)
      return k,n,str2vars(a) end

   --   do for i=0,23 do
   --      local k1,n1,a1="test",9,{0,i*i*i*i*i*i*i,2,i*i,i*i*i*i,5}
   --      local l2=data2Line(k1,i,a1)
   --      local k2,n2,a2=line2Data(l2)
   --          print (k2,n2,#l2,a2[1],a2[2],a2[3],a2[4],a2[5],a2[6])
   --   end end

   -- decodierung für strings
   M.t2s= vars2str -- Tabelle -> String
   M.s2t= str2vars -- String -> Tabelle
   M.l2d= line2Data
   M.d2l= data2Line
   print 'end varint'
   return M
end
