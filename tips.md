# Tips
## z= "Hallo" .. " Welt"
Lua kann strings zwar auf diese Art zusammenfügen. Das führt aber oft zu Abstürzen

#### Besser ist:
```
z={"Hallo"," Welt"}
z=table.concat(z)
```
#### oder
```
z={"Hallo","Welt"}
z=table.concat(z," ")
```
