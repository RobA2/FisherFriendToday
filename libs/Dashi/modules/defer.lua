local a,b=...local c={}local function d()for a,e in next,c do if e.callback then local f,g=pcall(e.callback,unpack(e.args))if not f then error(g)end elseif e.object then local f,g=pcall(e.object[e.method],e.object,unpack(e.args))if not f then error(g)end end end;table.wipe(c)return true end;local function h(e)table.insert(c,e)if not b:IsEventRegistered('PLAYER_REGEN_ENABLED',d)then b:RegisterEvent('PLAYER_REGEN_ENABLED',d)end end;function b:Defer(i,...)if type(i)=='string'then i=_G[i]end;b:ArgCheck(i,1,'function')if InCombatLockdown()then h({callback=i,args={...}})else local f,g=pcall(i,...)if not f then error(g)end end end;function b:DeferMethod(j,k,...)b:ArgCheck(j,1,'table')b:ArgCheck(k,2,'string')b:ArgCheck(j[k],2,'function')if InCombatLockdown()then h({object=j,method=k,args={...}})else local f,g=pcall(j[k],j,...)if not f then error(g)end end end