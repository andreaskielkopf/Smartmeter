do
   print 'load updateLFS'
   -- Teste ob ein Update des LFS notwendig ist, und führe ihn aus
   local function update()
      print 'auf update testen'
      local update_flag, remove_flag, lfs_img= 'update.flag', 'remove.flag', 'smartmeter.img'
      if file.exists(lfs_img) then -- wenn ein neues smartmeter.img da ist
         print(table.concat({lfs_img, ' exists'}))
         if file.exists(update_flag) then -- und es ist auch ein update.flag da
            print (table.concat({update_flag,' exists'}))
            if file.exists(remove_flag) then -- im 2.Durchlauf Aufräumen
               print (table.concat({remove_flag,' exists'}))
               file.remove(lfs_img) -- nach dem Update das image entfernen
               file.remove(update_flag) -- nach dem update das update.flag entfernen
               file.remove(remove_flag) -- und zuletzt das remove.flag auch entfernen
               print (table.concat({'removed',lfs_img,update_flag,remove_flag},', '))
            else -- Im 1.Durchlauf den Update durchführen
               print (table.concat({'create ',remove_flag}))
               -- remove.flag setzen damit der 2.Durchlauf anders ablaufen kann
               rm= file.open(remove_flag,'w') rm:writeline(remove_flag) rm:close() rm= nil
               print (table.concat({'reload ', lfs_img})) -- letzte Meldung vor dem Update
               node.LFS.reload(lfs_img) -- immage laden und programm neu starten
               --               print 'hier sollten wir eigentlich nicht mehr vorbeikommen'
            end end end end

   update()
   print 'end updateLFS'
   return update -- updatefunktion exportieren
end
