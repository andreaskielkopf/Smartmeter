do
   print 'load updateLFS'
   local function update()
      print 'update ???'
      local update_flag='update.flag'
      local remove_flag='remove.flag'
      local lfs_img='smartmeter.img'
      if file.exists(lfs_img) then
         print (table.concat({lfs_img,' exists'}))
         if file.exists(update_flag) then
            print (table.concat({update_flag,' exists'}))
            if file.exists(remove_flag) then
               print (table.concat({remove_flag,' exists'}))
               file.remove(lfs_img)
               file.remove(update_flag)
               file.remove(remove_flag)
               print (table.concat({'removed',lfs_img,update_flag,remove_flag},', '))
            else print (table.concat({'create ',remove_flag}))
               rm=file.open(remove_flag,'w')
               rm:writeline(remove_flag)
               rm:close()
               print (table.concat({'reload ', lfs_img}))
               node.LFS.reload(lfs_img)
               --               print 'hier sollten wir eigentlich nicht mehr vorbeikommen'
            end
         end
      end
   end
   update()
   print 'end updateLFS'
end
