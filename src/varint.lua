-- Implementierung des varint Verfahrens, das "echte" Strings aus Zahlen erzeugt
do
   print 'load varint'
   local M= {}
   local max= 125 -- 250/2 256 Zeichen wären möglich, 6 sind ausgelassen

   -- codierung für kleine Zahlen, so dass \0, LF, CR, ", ' und \\ nicht vorkommen
   local function toS(a)
      if a>=92-5 then return a+6 -- \
      elseif a>=39-4 then return a+5 -- '
      elseif a>=34-3 then return a+4 -- "
      elseif a>=13-2 then return a+3 -- CR
      elseif a>=10-1 then return a+2 -- LF
      else return a+1 end end -- null

   -- Rückkodierung
   local function toZ(a)
      if a>92 then return a-6 -- \
      elseif a>39 then return a-5 -- '
      elseif a>34 then return a-4 -- "
      elseif a>13 then return a-3 -- CR
      elseif a>10 then return a-2 -- LF
      else return a-1 end end -- null
   --   for t=0, 249 do if t-toZ(toS(t))~=0 then print('fehler bei',t) end end
   --   for t=0, 249 do print(t, toS(t), string.char(toS(t)), toZ(toS(t)), t-toZ(toS(t))) end

   -- wandelt eine +/- Zahl (32Bit) in einen String
   local function var2str(z)
      z= z<0 and -1-z-z or z+z -- einschmugeln des Signbits als bit 0
      local out= {}
      repeat
         local a= z%max
         -- z= math.floor(z/max) -- float build
         z= z/max -- integer build
         if z~=0 then a= a+max end
         out[#out+1]=  string.char(toS(a))
      until z==0 return table.concat(out) end

   -- wandelt einen String in eine +/- Zahl (32Bit) und übergibt den Pointer im String zurück
   local function str2var(s,p)
      local z,f,b,c,x= 0,1
      for i= p or 1, #s do
         b= toZ(s:byte(i))
         if b<max then
            z=z+b*f -- erg berechnen
            local neg= z%2==1
            -- z= math.floor(z/2) -- float build
            z= z/2 -- integer build
            if neg then return -z-1,i -- negativ
            else return z,i end
         end
         z= z+(b-max)*f f= f*max
      end end

   --   do local a,b,c,d for i=0,1000000000 do
   --      a=var2str(i) b=var2str(-i) c=str2var(a) d=str2var(b)
   --      if i~=c or -i~=d then print(i,a,c,-i,b,d) end end end

   --      local q,j,l for i=0, 0x7fffffff ,57 do
   --         j,l=str2var(var2str(i))
   --         if i~=j then print (i,j,l) end end

   -- Dfferenziert die Werte in einer Tabelle -> Jeder Wert wird als differenz zum vorigen gespeichert.
   local function compress(a)
      local b,c= 0,{}
      for k,v in ipairs(a) do
         c[k]= v-b b= v end return c end

   -- Umkehr von tableCompress() Die ursprünglichen Werte werden wieder berechnet durch aufsummieren
   local function expand(a)
      local b,d= 0,{}
      for k,v in ipairs(a) do
         b= v+b d[k]= b end return d end

   -- wandelt ein array von Ints(31Bit) in einen String mit Varints um
   local function vars2str(a)
      local s={}
      if type(a)~='table' or #a<1 then return "" end
      for k,v in ipairs(compress(a)) do
         s[#s+1]=var2str(v)
      end return table.concat(s) end
   --   local a={} for i=1,60 do a[i]= i*(i+37)/19 end a= vars2str(a) print (a)
   --   local a={} for i=1,60 do a[i]= i*1000 end a= vars2str(a)
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
   local function str2vars(s)
      local a={}
      for k,v in nextZahl(s) do a[k]=v end
      return expand(a) end
   --   for k,v in ipairs(str2vars(a)) do print (k,v) end

   --   do local a,b,c= {}for i=1,1000000 do a[#a+1]= i*i a[#a+1]= -i*i end
   --      b=vars2str(a) c=str2vars(b) print (a,#a,#b,c,#c)
   --      for k,v in ipairs(c) do if a[k]~=v then print(k,a[k]-v) end end end

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
   --      local k1,n1,a1="test",9,{0,i*i*i*i*i*i,2,i*i,i*i*i*i,5}
   --      local l2=data2Line(k1,i,a1)
   --      local k2,n2,a2=line2Data(l2)
   --      print (k2,n2,#l2,a2[1],a2[2],a2[3],a2[4],a2[5],a2[6])
   --   end end

   -- decodierung für strings
   M.t2s= vars2str -- Tabelle -> String
   M.s2t= str2vars -- String -> Tabelle
   M.l2d= line2Data
   M.d2l= data2Line
   --   M.DIFF= tableDif -- Tabelle differenzieren (compress)
   --   M.INTG= tableExpand -- Tabelle integrieren (expand)
   print 'end varint'
   return M
end
