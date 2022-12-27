local e={}local t,a,o=require,{},{startup=e}
local function i(n)local s=o[n]
if s~=nil then if s==e then
error("loop or previous error loading module '"..n..
"'",2)end;return s end;o[n]=e;local h=a[n]if h then s=h(n)elseif t then s=t(n)else
error("cannot load '"..n.."'",2)end;if s==nil then s=true end;o[n]=s;return s end
a["moonscript.version"]=function(...)local n="0.5.0"return
{version=n,print_version=function()return
print("MoonScript version "..tostring(n))end}end
a["moonscript.util"]=function(...)local n;n=table.concat
local s=unpack or table.unpack;local h=type
local r={is_object=function(g)return h(g)=="table"and g.__class end,is_a=function(g,k)if
not(h(g)=="table")then return false end;local q=g.__class;while q do if
q==k then return true end;q=q.__parent end;return false end,type=function(g)
local k=h(g)if k=="table"then local q=g.__class;if q then return q end end;return k end}local d
d=function(g,k)local q=1;for j in g:sub(1,k):gmatch("\n")do q=q+1 end;return q end;local l
l=function(g)return g:match("^%s*(.-)%s*$")end;local u
u=function(g,k)
for q in g:gmatch("([^\n]*)\n?")do if k==1 then return q end;k=k-1 end end;local c
c=function(g,k)local q=u(g,k)if(not q or l(q)=="")and k>1 then return c(g,k-1)else return
q,k end end;local m
m=function(g,k)if g==""then return{}end;g=g..k;local q={}local j=1;for x in g:gmatch("(.-)"..k)do q[j]=x
j=j+1 end;return q end;local f
f=function(g)local k={}local q
q=function(g,j)if j==nil then j=0 end;local x=h(g)
if x=="string"then
return'"'..g..'"\n'elseif x=="table"then if k[g]then
return"recursion("..tostring(g)..")...\n"end;k[g]=true;j=j+1;local z
do local E={}local T=1;for A,O in pairs(g)do
E[T]=(" "):rep(
j*4).."["..tostring(A).."] = "..q(O,j)T=T+1 end;z=E end;k[g]=false;local _;if g.__class then
_="<"..tostring(g.__class.__name)..">"end;return
tostring(_ or"").."{\n"..n(z)..
(" "):rep((j-1)*4).."}\n"else return tostring(g).."\n"end end;return q(g)end;local w
w=function(g,k,q)local j
do local z={}local _=1;for E,T in pairs(g)do z[_]={E,T}_=_+1 end;j=z end
table.sort(j,function(z,_)return z[1]<_[1]end)local x
do local z={}local _=1
for E=1,#j do local T=j[E]local A,O=s(T)local I=d(k,O)local N=u(q,A)local S=c(k,I)
local H=
tostring(O).."\t "..
tostring(A)..":[ "..
tostring(l(N)).." ] >> "..tostring(I)..
":[ "..tostring(l(S)).." ]"z[_]=H;_=_+1 end;x=z end;return n(x,"\n")end
local y=setfenv or
function(g,k)local q;local j=1;while true do q=debug.getupvalue(g,j)
if not q or q=="_ENV"then break end;j=j+1 end;if q then
debug.upvaluejoin(g,j,(function()return k end),1)end;return g end
local p=getfenv or
function(g)local k=1
while true do local q,j=debug.getupvalue(g,k)if not(q)then break end;if q=="_ENV"then return
j end;k=k+1 end;return nil end;local v
v=function(...)local g=select("#",...)local k=select(g,...)if h(k)=="table"then return k,
s({...},nil,g-1)else return{},...end end;local b
b=function(g,k)return
setmetatable(k,{__index=function(q,j)return
error("Attempted to import non-existent `"..
tostring(j).."` from "..tostring(g))end})end
return
{moon=r,pos_to_line=d,get_closest_line=c,get_line=u,trim=l,split=m,dump=f,debug_posmap=w,getfenv=p,setfenv=y,get_options=v,unpack=s,safe_module=b}end
a["moonscript.types"]=function(...)local n=i("moonscript.util")local s
s=i("moonscript.data").Set;local h;h=table.insert;local r;r=n.unpack
local d=s({"foreach","for","while","return"})
local l=s({"if","unless","with","switch","class","do"})local u=s({"return","break"})local c
c=function(E)local T=type(E)if"nil"==T then return"nil"elseif
"table"==T then return E[1]else return"value"end end;local m;do local E=n.moon.type
m=function(T)local A=getmetatable(T)
if A and A.smart_node then return"table"end;return E(T)end end;local f
f=function(E)if not
(c(E)=="chain")then return false end;return c(E[#E])=="call"end;local w
w=function(E)local T=i("moonscript.compile")
local A=i("moonscript.transform")
return T.Block:is_value(E)or A.Value:can_transform(E)end;local y;y=function(E)
return type(E)~="table"or E[1]~="exp"or#E==2 end;local p
p=function(E)return
c(E)=="chain"and c(E[#E])=="slice"end;local v={}
local b={class={{"name","Tmp"},{"body",v}},fndef={{"args",v},{"whitelist",v},{"arrow","slim"},{"body",v}},foreach={{"names",v},{"iter"},{"body",v}},["for"]={{"name"},{"bounds",v},{"body",v}},["while"]={{"cond",v},{"body",v}},assign={{"names",v},{"values",v}},declare={{"names",v}},["if"]={{"cond",v},{"then",v}}}local g
g=function()local E={}for T,A in pairs(b)do local O={}for I,N in ipairs(A)do local S=N[1]O[S]=I+1 end
E[T]=O end;return E end;local k=g()local q
q=function(E)local T=b[E]if not T then
error("don't know how to build node: "..E)end
return
function(A)if A==nil then A={}end;local O={E}
for I,N in ipairs(T)do local S,H=r(N)
local R;if A[S]then R=A[S]else R=H end;if R==v then R={}end;O[I+1]=R end;return O end end;local j=nil
j=setmetatable({group=function(E)if E==nil then E={}end;return{"group",E}end,["do"]=function(E)return
{"do",E}end,assign_one=function(E,T)
return j.assign({names={E},values={T}})end,table=function(E)if E==nil then E={}end
for T=1,#E do local A=E[T]if
type(A[1])=="string"then A[1]={"key_literal",A[1]}end end;return{"table",E}end,block_exp=function(E)return
{"block_exp",E}end,chain=function(E)
local T=E.base or error("expecting base property for chain")if type(T)=="string"then T={"ref",T}end;local A={"chain",T}for O=1,#E do
local I=E[O]h(A,I)end;return A end},{__index=function(E,T)
E[T]=q(T)return rawget(E,T)end})
local x=setmetatable({},{__index=function(E,T)local A=k[T]
local O={smart_node=true,__index=function(I,N)
if A[N]then return rawget(I,A[N])elseif type(N)=="string"then return
error("unknown key: `"..N..
"` on node type: `"..c(I).."`")end end,__newindex=function(I,N,S)if
A[N]then N=A[N]end;return rawset(I,N,S)end}E[T]=O;return O end})local z
z=function(E)return setmetatable(E,x[c(E)])end;local _={"noop"}
return
{ntype=c,smart_node=z,build=j,is_value=w,is_slice=p,manual_return=d,cascading=l,value_is_singular=y,value_can_be_statement=f,mtype=m,terminating=u,NOOP=_}end
a["moonscript.transform"]=function(...)return
{Statement=i("moonscript.transform.statement"),Value=i("moonscript.transform.value")}end
a["moonscript.transform.value"]=function(...)local n
n=i("moonscript.transform.transformer").Transformer;local s,h,r
do local g=i("moonscript.types")s,h,r=g.build,g.ntype,g.smart_node end;local d
d=i("moonscript.transform.names").NameProxy;local l,u;do local g=i("moonscript.transform.accumulator")
l,u=g.Accumulator,g.default_accumulator end;local c
c=i("moonscript.data").lua_keywords;local m,f,w,y;do local g=i("moonscript.transform.statements")
m,f,w,y=g.Run,g.transform_last_stm,g.implicitly_return,g.chain_is_stub end;local p
p=i("moonscript.transform.comprehension").construct_comprehension;local v;v=table.insert;local b;b=i("moonscript.util").unpack
return
n({["for"]=u,["while"]=u,foreach=u,["do"]=function(g,k)return
s.block_exp(k[2])end,decorated=function(g,k)
return g.transform.statement(k)end,class=function(g,k)return s.block_exp({k})end,string=function(g,k)
local q=k[2]local j
j=function(z)
if type(z)=="string"or z==nil then return{"string",q,z or""}else return
s.chain({base="tostring",{"call",{z[2]}}})end end;if#k<=3 then
if type(k[3])=="string"then return k else return j(k[3])end end;local x={"exp",j(k[3])}for z=4,#k do
v(x,"..")v(x,j(k[z]))end;return x end,comprehension=function(g,k)
local q=l()
k=g.transform.statement(k,function(j)return q:mutate_body({j})end)return q:wrap(k)end,tblcomprehension=function(g,k)
local q,j=b(k,2)local x,z=b(q)local _=d("tbl")local E
if z then
local T=s.chain({base=_,{"index",x}})E={s.assign_one(T,z)}else local T,A=d("key"),d("val")
local O=s.chain({base=_,{"index",T}})
E={s.assign({names={T,A},values={x}}),s.assign_one(O,A)}end;return
s.block_exp({s.assign_one(_,s.table()),p(E,j),_})end,fndef=function(g,k)
r(k)k.body=f(k.body,w(g))
k.body={m(function(g)
return g:listen("varargs",function()end)end),b(k.body)}return k end,["if"]=function(g,k)return
s.block_exp({k})end,unless=function(g,k)return s.block_exp({k})end,with=function(g,k)return
s.block_exp({k})end,switch=function(g,k)return s.block_exp({k})end,chain=function(g,k)
for q=2,
#k do local j=k[q]if h(j)=="dot"and c[j[2]]then
k[q]={"index",{"string",'"',j[2]}}end end;if h(k[2])=="string"then k[2]={"parens",k[2]}end
if y(k)then
local q=d("base")local j=d("fn")local x=table.remove(k)local z=h(k[2])=="ref"and
k[2][2]=="super"
return
s.block_exp({s.assign({names={q},values={k}}),s.assign({names={j},values={s.chain({base=q,{"dot",x[2]}})}}),s.fndef({args={{"..."}},body={s.chain({base=j,{"call",{
z and"self"or q,"..."}}})}})})end end,block_exp=function(g,k)
local q=b(k,2)local j=nil;local x={}
j=r(s.fndef({body={m(function(g)return
g:listen("varargs",function()v(x,"...")v(j.args,{"..."})return
g:unlisten("varargs")end)end),b(q)}}))
return s.chain({base={"parens",j},{"call",x}})end})end
a["moonscript.transform.transformer"]=function(...)local n
n=i("moonscript.types").ntype;local s
do local h
local r={transform_once=function(d,l,u,...)if d.seen_nodes[u]then return u end;d.seen_nodes[u]=true
local c=d.transformers[n(u)]if c then return c(l,u,...)or u else return u end end,transform=function(d,l,u,...)if
d.seen_nodes[u]then return u end;d.seen_nodes[u]=true
while true do
local c=d.transformers[n(u)]local m;if c then m=c(l,u,...)or u else m=u end;if m==u then return u end;u=m end;return u end,bind=function(d,l)return function(...)return
d:transform(l,...)end end,__call=function(d,...)return
d:transform(...)end,can_transform=function(d,l)
return d.transformers[n(l)]~=nil end}r.__index=r
h=setmetatable({__init=function(d,l)d.transformers=l
d.seen_nodes=setmetatable({},{__mode="k"})end,__base=r,__name="Transformer"},{__index=r,__call=function(d,...)
local l=setmetatable({},r)d.__init(l,...)return l end})r.__class=h;s=h end;return{Transformer=s}end
a["moonscript.transform.statements"]=function(...)local n=i("moonscript.types")
local s,h,r,d;s,h,r,d=n.ntype,n.mtype,n.is_value,n.NOOP;local l
l=i("moonscript.transform.comprehension").comprehension_has_value;local u
do local y
local p={call=function(v,b)return v.fn(b)end}p.__index=p
y=setmetatable({__init=function(v,b)v.fn=b;v[1]="run"end,__base=p,__name="Run"},{__index=p,__call=function(v,...)
local b=setmetatable({},p)v.__init(b,...)return b end})p.__class=y;u=y end;local c
c=function(y)local p=0
for v=#y,1,-1 do local b=y[v]if b and h(b)~=u then
if s(b)=="group"then return c(b[2])end;p=v;break end end;return y[p],p,y end;local m
m=function(y,p)local v,b,g=c(y)if g~=y then
error("cannot transform last node in group")end;return
(function()local k={}local q=1
for j,x in ipairs(y)do if j==b then
k[q]={"transform",x,p}else k[q]=x end;q=q+1 end;return k end)()end;local f
f=function(y)local p=y[#y]return p and s(p)=="colon"end;local w
w=function(y)local p=true;local v
v=function(b)local g=s(b)if g=="decorated"then
b=y.transform.statement(b)g=s(b)end
if n.cascading[g]then p=false;return
y.transform.statement(b,v)elseif n.manual_return[g]or not r(b)then if p and g=="return"and
b[2]==""then return d else return b end else
if
g=="comprehension"and not l(b)then return b else return{"return",b}end end end;return v end
return{Run=u,last_stm=c,transform_last_stm=m,chain_is_stub=f,implicitly_return=w}end
a["moonscript.transform.statement"]=function(...)local n
n=i("moonscript.transform.transformer").Transformer;local s,h,r;do local T=i("moonscript.transform.names")
s,h,r=T.NameProxy,T.LocalName,T.is_name_proxy end;local d,l,u,c
do
local T=i("moonscript.transform.statements")d,l,u,c=T.Run,T.transform_last_stm,T.implicitly_return,T.last_stm end;local m=i("moonscript.types")local f,w,y,p,v,b,g
f,w,y,p,v,b,g=m.build,m.ntype,m.is_value,m.smart_node,m.value_is_singular,m.is_slice,m.NOOP;local k;k=table.insert
local q=i("moonscript.transform.destructure")local j
j=i("moonscript.transform.comprehension").construct_comprehension;local x;x=i("moonscript.util").unpack;local z
z=function(T)local A=nil
return
{d(function(O)return
O:listen("continue",function()if
not(A)then A=s("continue")O:put_name(A)end;return A end)end),f.group(T),d(function(O)if
not(A)then return end;local I=c(T)local N=m.terminating[I and w(I)]O:put_name(A,
nil)
return
O:splice(function(S)if N then S={"do",{S}}end;return
{{"assign",{A},{"false"}},{"repeat","true",{S,{"assign",{A},{"true"}}}},{"if",{"not",A},{{"break"}}}}end)end)}end;local _
_=function(T,A,O,I)if A==nil then A=T.current_stms end
if O==nil then O=T.current_stm_i+1 end;if I==nil then I={}end
for N=O,#A do local S=false
repeat local H=A[N]if H==nil then S=true;break end
H=T.transform.statement(H)A[N]=H;local R=H[1]
if"assign"==R or"declare"==R then local D=H[2]
for L=1,#D do local U=D[L]if
w(U)=="ref"then k(I,U)elseif type(U)=="string"then k(I,U)end end elseif"group"==R then _(T,H[2],1,I)end;S=true until true;if not S then break end end;return I end;local E
E=function(T)
for A=4,#T do local O=T[A]if w(O)=="elseif"and w(O[2])=="assign"then
local I={x(T,1,A-1)}
k(I,{"else",{{"if",O[2],O[3],x(T,A+1)}}})return I end end;return T end
return
n({transform=function(T,A)local O,I,N;O,I,N=A[1],A[2],A[3]return N(I)end,root_stms=function(T,A)
return l(A,u(T))end,["return"]=function(T,A)local O=A[2]local I=w(O)if I=="explist"and#O==2 then O=O[2]
I=w(O)end;if m.cascading[I]then return u(T)(O)end
if

I=="chain"or I=="comprehension"or I=="tblcomprehension"then local N=i("moonscript.transform.value")
O=N:transform_once(T,O)if w(O)=="block_exp"then return
f.group(l(O[2],function(S)return{"return",S}end))end end;A[2]=O;return A end,declare_glob=function(T,A)
local O=_(T)
if A[2]=="^"then
do local I={}local N=1
for S=1,#O do local H=false
repeat local R=O[S]local D
if w(R)=="ref"then D=R[2]else D=R end;if not(D:match("^%u"))then H=true;break end;local L=R;I[N]=L
N=N+1;H=true until true;if not H then break end end;O=I end end;return{"declare",O}end,assign=function(T,A)
local O,I=x(A,2)local N=#I;local S=#I
if S==1 and N==1 then local R=I[1]local D=O[1]local L=w(R)
if L=="chain"then
local C=i("moonscript.transform.value")R=C:transform_once(T,R)L=w(R)end;local U=w(R)
if"block_exp"==U then local C=R[2]local M=#C;C[M]=f.assign_one(D,C[M])return
f.group({{"declare",{D}},{"do",C}})elseif

"comprehension"==U or"tblcomprehension"==U or"foreach"==U or"for"==U or"while"==U then
local C=i("moonscript.transform.value")return f.assign_one(D,C:transform_once(T,R))else I[1]=R end end;local H
if N==1 then local R=I[1]local D=w(R)if D=="decorated"then
R=T.transform.statement(R)D=w(R)end
if m.cascading[D]then local L
L=function(U)if y(U)then
return{"assign",O,{U}}else return U end end
H=f.group({{"declare",O},T.transform.statement(R,L,A)})end end;A=H or A
if q.has_destructure(O)then return q.split_assign(T,A)end;return A end,continue=function(T,A)
local O=T:send("continue")
if not(O)then error("continue must be inside of a loop")end
return f.group({f.assign_one(O,"true"),{"break"}})end,export=function(T,A)
if
#A>2 then
if A[2]=="class"then local O=p(A[3])return
f.group({{"export",{O.name}},O})else return
f.group({{"export",A[2]},f.assign({names=A[2],values=A[3]})})end else return nil end end,update=function(T,A)
local O,I,N=x(A,2)local S=I:match("^(.+)=$")if not S then
error("Unknown op: "..I)end;local H
if w(O)=="chain"then H={}local D
do local L={}local U=1
for C=3,#O do local M=O[C]if
w(M)=="index"then local F=s("update")table.insert(H,{F,M[2]})
L[U]={"index",F}else L[U]=M end;U=U+1 end;D=L end;if next(H)then O={O[1],O[2],x(D)}end end;if not(v(N))then N={"parens",N}end
local R=f.assign_one(O,{"exp",O,S,N})
if H and next(H)then local D;do local U={}local C=1
for M=1,#H do local F=H[M]U[C]=F[1]C=C+1 end;D=U end;local L;do local U={}local C=1;for M=1,#H do local F=H[M]
U[C]=F[2]C=C+1 end;L=U end
R=f.group({{"assign",D,L},R})end;return R end,import=function(T,A)
local O,I=x(A,2)local N
do local H={}local R=1;for D=1,#O do local L=O[D]local U;if w(L)=="colon"then U=L[2]else U=L end
local C={{"key_literal",L},U}H[R]=C;R=R+1 end;N=H end;local S={"table",N}return{"assign",{S},{I},[-1]=A[-1]}end,comprehension=function(T,A,O)
local I,N=x(A,2)O=O or function(I)return{I}end;return j(O(I),N)end,["do"]=function(T,A,O)if
O then A[2]=l(A[2],O)end;return A end,decorated=function(T,A)
local O,I=x(A,2)local N;local S=I[1]
if"if"==S then local H,R=x(I,2)if R then R={"else",{R}}end
N={"if",H,{O},R}elseif"unless"==S then N={"unless",I[2],{O}}elseif"comprehension"==S then
N={"comprehension",O,I[2]}else N=error("Unknown decorator "..I[1])end
if w(O)=="assign"then
N=f.group({f.declare({names=(function()local H={}local R=1;local D=O[2]for L=1,#D do local U=D[L]if w(U)=="ref"then H[R]=U
R=R+1 end end;return H end)()}),N})end;return N end,unless=function(T,A)
local O=A[2]
if w(O)=="assign"then if q.has_destructure(O[2])then
error("destructure not allowed in unless assignment")end;return
f["do"]({O,{"if",{"not",O[2][1]},x(A,3)}})else
return{"if",{"not",{"parens",O}},x(A,3)}end end,["if"]=function(T,A,O)
if
w(A[2])=="assign"then local I,N=x(A,2)
if q.has_destructure(I[2])then local S=s("des")
N={q.build_assign(T,I[2][1],S),f.group(A[3])}return
f["do"]({f.assign_one(S,I[3][1]),{"if",S,N,x(A,4)}})else local S=I[2][1]return
f["do"]({I,{"if",S,x(A,3)}})end end;A=E(A)
if O then p(A)A['then']=l(A['then'],O)for I=4,#A do local N=A[I]local S=#A[I]
N[S]=l(N[S],O)end end;return A end,with=function(T,A,O)
local I,N=x(A,2)local S=true;local H,R;do local L=c(N)
if L then if m.terminating[w(L)]then O=false end end end
if w(I)=="assign"then local L,U=x(I,2)local C=L[1]
if w(C)==
"ref"then H=C;R=I;I=U[1]S=false else H=s("with")I=U[1]U[1]=H;R={"assign",L,U}end elseif T:is_local(I)then H=I;S=false end;H=H or s("with")
local D=f["do"]({S and f.assign_one(H,I)or g,R or g,d(function(T)return
T:set("scope_var",H)end),x(N)})if O then table.insert(D[2],O(H))end;return D end,foreach=function(T,A,O)
p(A)local I=x(A.iter)local N={}
do local S={}local H=1
for R,D in ipairs(A.names)do if w(D)=="table"then
do
local L=s("des")k(N,q.build_assign(T,D,L))S[H]=L end else S[H]=D end;H=H+1 end;A.names=S end;if next(N)then k(N,f.group(A.body))A.body=N end
if
w(I)=="unpack"then local S=I[2]local H=s("index")
local R=T:is_local(S)and S or s("list")local D=nil;local L
if b(S)then local C=S[#S]table.remove(S)table.remove(C,1)if
T:is_local(S)then R=S end;if C[2]and C[2]~=""then local M=s("max")
D=f.assign_one(M,C[2])C[2]={"exp",M,"<",0,"and",{"length",R},"+",M,"or",M}else
C[2]={"length",R}end;L=C else
L={1,{"length",R}}end;local U
do local C={}local M=1;local F=A.names;for W=1,#F do local Y=F[W]
C[M]=r(Y)and Y or h(Y)or Y;M=M+1 end;U=C end;return
f.group({R~=S and f.assign_one(R,S)or g,D or g,f["for"]({name=H,bounds=L,body={{"assign",U,{s.index(R,H)}},f.group(A.body)}})})end;A.body=z(A.body)end,["while"]=function(T,A)
p(A)A.body=z(A.body)end,["for"]=function(T,A)p(A)A.body=z(A.body)end,switch=function(T,A,O)
local I,N=x(A,2)local S=s("exp")local H
H=function(L)local U,C,M=x(L)local F={}
k(F,U=="case"and"elseif"or"else")
if U~="else"then local W={}for Y,P in ipairs(C)do if Y==1 then k(W,"exp")else k(W,"or")end;if not
(v(P))then P={"parens",P}end
k(W,{"exp",P,"==",S})end;k(F,W)else M=C end;if O then M=l(M,O)end;k(F,M)return F end;local R=true;local D={"if"}for L=1,#N do local U=N[L]local C=H(U)if R then R=false;k(D,C[2])k(D,C[3])else
k(D,C)end end;return
f.group({f.assign_one(S,I),D})end,class=i("moonscript.transform.class")})end
a["moonscript.transform.names"]=function(...)local n
n=i("moonscript.types").build;local s;s=i("moonscript.util").unpack;local h
do local l
local u={get_name=function(c)return c.name end}u.__index=u
l=setmetatable({__init=function(c,m)c.name=m;c[1]="temp_name"end,__base=u,__name="LocalName"},{__index=u,__call=function(c,...)
local m=setmetatable({},u)c.__init(m,...)return m end})u.__class=l;h=l end;local r
do local l
local u={get_name=function(c,m,f)if f==nil then f=true end;if not c.name then
c.name=m:free_name(c.prefix,f)end;return c.name end,chain=function(c,...)
local m={base=c,...}for f,w in ipairs(m)do
if type(w)=="string"then m[f]={"dot",w}else m[f]=w end end;return n.chain(m)end,index=function(c,m)if
type(m)=="string"then m={"ref",m}end;return
n.chain({base=c,{"index",m}})end,__tostring=function(c)if c.name then return
("name<%s>"):format(c.name)else
return("name<prefix(%s)>"):format(c.prefix)end end}u.__index=u
l=setmetatable({__init=function(c,m)c.prefix=m;c[1]="temp_name"end,__base=u,__name="NameProxy"},{__index=u,__call=function(c,...)
local m=setmetatable({},u)c.__init(m,...)return m end})u.__class=l;r=l end;local d
d=function(l)if not(type(l)=="table")then return false end
local u=l.__class;if h==u or r==u then return true end end;return{NameProxy=r,LocalName=h,is_name_proxy=d}end
a["moonscript.transform.destructure"]=function(...)local n,s,h;do
local p=i("moonscript.types")n,s,h=p.ntype,p.mtype,p.build end;local r
r=i("moonscript.transform.names").NameProxy;local d;d=table.insert;local l;l=i("moonscript.util").unpack;local u
u=i("moonscript.errors").user_error;local c
c=function(...)
do local p={}local v=1;local b={...}for g=1,#b do local k=b[g]
for q=1,#k do local j=k[q]p[v]=j;v=v+1 end end;return p end end;local m
m=function(p)
for v=1,#p do local b=p[v]if n(b)=="table"then return true end end;return false end;local f
f=function(p,v,b)if v==nil then v={}end;if b==nil then b={}end;local g=1;local k=p[2]
for q=1,#k do local j=k[q]local x,z
if
#j==1 then local E={"index",{"number",g}}g=g+1;x,z=j[1],E else local E=j[1]local T;if n(E)==
"key_literal"then local A=E[2]if n(A)=="colon"then T=A else T={"dot",A}end else
T={"index",E}end;x,z=j[2],T end;z=c(b,{z})local _=n(x)
if"value"==_ or"ref"==_ or"chain"==_ or
"self"==_ then d(v,{x,z})elseif"table"==_ then f(x,v,z)else
u(
"Can't destructure value of type: "..tostring(n(x)))end end;return v end;local w
w=function(p,v,b)
assert(b,"attempting to build destructure assign with no receiver")local g=f(v)local k={}local q={}local j={"assign",k,q}local x
if p:is_local(b)or#g==1 then
x=b else do x=r("obj")
j=h["do"]({h.assign_one(x,b),{"assign",k,q}})x=x end end;for z=1,#g do local _=g[z]d(k,_[1])local E
if x then E=r.chain(x,l(_[2]))else E="nil"end;d(q,E)end;return
h.group({{"declare",k},j})end;local y
y=function(p,v)local b,k=l(v,2)local q={}local j=#b;local x=#k;local z=1
for g,_ in ipairs(b)do
if n(_)=="table"then
if g>z then local E=g-1
d(q,{"assign",(function()
local T={}local A=1;for g=z,E do T[A]=b[g]A=A+1 end;return T end)(),(function()
local T={}local A=1;for g=z,E do T[A]=k[g]A=A+1 end;return T end)()})end;d(q,w(p,_,k[g]))z=g+1 end end
if j>=z or x>=z then local g;if j<z then g={"_"}else
do local E={}local T=1;for A=z,j do E[T]=b[A]T=T+1 end;g=E end end;local _
if x<z then _={"nil"}else do local E={}local T=1;for A=z,x do
E[T]=k[A]T=T+1 end;_=E end end;d(q,{"assign",g,_})end;return h.group(q)end
return{has_destructure=m,split_assign=y,build_assign=w,extract_assign_names=f}end
a["moonscript.transform.comprehension"]=function(...)local n
n=i("moonscript.types").is_value;local s
s=function(r,d)local l=r
for u=#d,1,-1 do local c=d[u]local m=c[1]local f=m
if"for"==f then local w,y,p;w,y,p=c[1],c[2],c[3]
l={"for",y,p,l}elseif"foreach"==f then local w,y,p;w,y,p=c[1],c[2],c[3]l={"foreach",y,{p},l}elseif"when"==f then
local w,y;w,y=c[1],c[2]l={"if",y,l}else
l=error("Unknown comprehension clause: "..m)end;l={l}end;return l[1]end;local h;h=function(r)return n(r[2])end
return{construct_comprehension=s,comprehension_has_value=h}end
a["moonscript.transform.class"]=function(...)local n,s;do
local y=i("moonscript.transform.names")n,s=y.NameProxy,y.LocalName end;local h
h=i("moonscript.transform.statements").Run;local r="new"local d;d=table.insert;local l,u,c;do local y=i("moonscript.types")
l,u,c=y.build,y.ntype,y.NOOP end;local m
m=i("moonscript.util").unpack;local f
f=function(y,p,v,b)if p==nil then p=true end
local g={"chain",y,{"dot","__parent"}}if not(b)then return g end;local k={m(b,3)}local q=k[1]if q==nil then return g end
local j=g;local x=q[1]
if"call"==x then if p then d(j,{"dot","__base"})end
local z=v:get("current_method")assert(z,"missing calling name")
k[1]={"call",{"self",m(q[2])}}
if u(z)=="key_literal"then d(j,{"dot",z[2]})else d(j,{"index",z})end elseif"colon"==x then local z=k[2]if z and z[1]=="call"then k[1]={"dot",q[2]}
k[2]={"call",{"self",m(z[2])}}end end;for z=1,#k do local _=k[z]d(j,_)end;return j end;local w
w=function(y,p,v)local b
return
{"scoped",h(function(g)b=g:get("current_method")
g:set("current_method",v)return g:set("super",p)end),y,h(function(g)return
g:set("current_method",b)end)}end
return
function(y,p,v,b)local g,k,q=m(p,2)if k==""then k=nil end;local j=n("parent")local x=n("base")
local z=n("self")local _=n("class")local E
E=function(...)return f(_,true,...)end;local T;T=function(...)return f(_,false,...)end;local A={}
local O={}
for U=1,#q do local C=q[U]local M=C[1]
if"stm"==M then d(A,C[2])elseif"props"==M then
for F=2,#C do local W=C[F]if
u(W[1])=="self"then local Y,P;Y,P=W[1],W[2]P=w(P,T,{"key_literal",Y[2]})
d(A,l.assign_one(Y,P))else d(O,W)end end end end;local I
do local U={}local C=1
for M=1,#O do local F=false
repeat local W=O[M]local Y=W[1]local P
if
Y[1]=="key_literal"and Y[2]==r then I=W[2]F=true;break else local V;Y,V=W[1],W[2]P={Y,w(V,E,Y)}end;U[C]=P;C=C+1;F=true until true;if not F then break end end;O=U end
if not(I)then if k then
I=l.fndef({args={{"..."}},arrow="fat",body={l.chain({base="super",{"call",{"..."}}})}})else I=l.fndef()end end;local N=g or b and b[2][1]local S=u(N)
if"chain"==S then local U=N[#N]local C=u(U)
if
"dot"==C then N={"string",'"',U[2]}elseif"index"==C then N=U[2]else N="nil"end elseif"nil"==S then N="nil"else local U=type(N)local C;if U=="string"then C=N elseif
U=="table"and N[1]=="ref"then C=N[2]else
C=error("don't know how to extract name from "..tostring(U))end
N={"string",'"',C}end
local H=l.table({{"__init",w(I,T,{"key_literal","__init"})},{"__base",x},{"__name",N},
k and{"__parent",j}or nil})local R
if k then
local U=l["if"]({cond={"exp",{"ref","val"},"==","nil"},["then"]={l.assign_one(s("parent"),l.chain({base="rawget",{"call",{{"ref","cls"},{"string",'"',"__parent"}}}})),l["if"]({cond=s("parent"),["then"]={l.chain({base=s("parent"),{"index","name"}})}})}})d(U,{"else",{"val"}})
R=l.fndef({args={{"cls"},{"name"}},body={l.assign_one(s("val"),l.chain({base="rawget",{"call",{x,{"ref","name"}}}})),U}})else R=x end
local D=l.table({{"__index",R},{"__call",l.fndef({args={{"cls"},{"..."}},body={l.assign_one(z,l.chain({base="setmetatable",{"call",{"{}",x}}})),l.chain({base="cls.__init",{"call",{z,"..."}}}),z}})}})
H=l.chain({base="setmetatable",{"call",{H,D}}})local L=nil
do
local U={h(function(y)if g then return y:put_name(g)end end),{"declare",{_}},{"declare_glob","*"},
k and l.assign_one(j,k)or c,l.assign_one(x,{"table",O}),l.assign_one(x:chain("__index"),x),
k and
l.chain({base="setmetatable",{"call",{x,l.chain({base=j,{"dot","__base"}})}}})or c,l.assign_one(_,H),l.assign_one(x:chain("__class"),_),l.group((function()if
#A>0 then
return{l.assign_one(s("self"),_),l.group(A)}end end)()),
k and
l["if"]({cond={"exp",j:chain("__inherited")},["then"]={j:chain("__inherited",{"call",{j,_}})}})or c,l.group((function()if
g then return{l.assign_one(g,_)}end end)()),(function()if
v then return v(_)end end)()}
L=l.group({l.group((function()
if u(g)=="value"then return{l.declare({names={g}})}end end)()),l["do"](U)})end;return L end end
a["moonscript.transform.accumulator"]=function(...)local n=i("moonscript.types")
local s,h,r;s,h,r=n.build,n.ntype,n.NOOP;local d
d=i("moonscript.transform.names").NameProxy;local l;l=table.insert;local u
u=function(w)if#w~=1 then return false end;if"group"==h(w)then
return u(w[2])else return w[1]end end;local c
c=i("moonscript.transform.statements").transform_last_stm;local m
do local w
local y={body_idx={["for"]=4,["while"]=3,foreach=4},convert=function(p,v)local b=p.body_idx[h(v)]
v[b]=p:mutate_body(v[b])return p:wrap(v)end,wrap=function(p,v,b)
if b==nil then b="block_exp"end;return
s[b]({s.assign_one(p.accum_name,s.table()),s.assign_one(p.len_name,1),v,
b=="block_exp"and p.accum_name or r})end,mutate_body=function(p,v)
local b=u(v)local g
if b and n.is_value(b)then v={}g=b else
v=c(v,function(q)if n.is_value(q)then
return s.assign_one(p.value_name,q)else
return s.group({{"declare",{p.value_name}},q})end end)g=p.value_name end
local k={s.assign_one(d.index(p.accum_name,p.len_name),g),{"update",p.len_name,"+=",1}}l(v,s.group(k))return v end}y.__index=y
w=setmetatable({__init=function(p,v)p.accum_name=d("accum")p.value_name=d("value")
p.len_name=d("len")end,__base=y,__name="Accumulator"},{__index=y,__call=function(p,...)
local v=setmetatable({},y)p.__init(v,...)return v end})y.__class=w;m=w end;local f;f=function(w,y)return m():convert(y)end;return
{Accumulator=m,default_accumulator=f}end
a["moonscript.parse"]=function(...)local n=false;local s=i("cc.lpeg")
s.setmaxstack(10000)local h="Failed to parse:%s\n [%d] >>    %s"local r
r=i("moonscript.data").Stack;local d,l,u
do local g=i("moonscript.util")d,l,u=g.trim,g.pos_to_line,g.get_line end;local c;c=i("moonscript.util").unpack;local m
m=i("moonscript.parse.env").wrap_env;local f,w,y,p,v,b,k,q,j,x;f,w,y,p,v,b,k,q,j,x=s.R,s.S,s.V,s.P,s.C,s.Ct,s.Cmt,s.Cg,s.Cb,s.Cc
local z,_,E,T,A,O,I,N,S,H,R,D,L
do local g=i("moonscript.parse.literals")
z,_,E,T,A,O,I,N,S,H,R,D,L=g.White,g.Break,g.Stop,g.Comment,g.Space,g.SomeSpace,g.SpaceBreak,g.EmptyLine,g.AlphaNum,g.Num,g.Shebang,g.L,g.Name end;local U=A*L;H=A*
(H/function(g)return{"number",g}end)local C,M,F,W,Y,P,V,B,G,K,Q,J,X,Z,ee,et,ea,eo,ei,en
do
local g=i("moonscript.parse.util")
C,M,F,W,Y,P,V,B,G,K,Q,J,X,Z,ee,et,ea,eo,ei,en=g.Indent,g.Cut,g.ensure,g.extract_line,g.mark,g.pos,g.flatten_or_mark,g.is_assignable,g.check_assignable,g.format_assign,g.format_single_assign,g.sym,g.symx,g.simple_string,g.wrap_func_arg,g.join_chain,g.wrap_decorator,g.check_lua_string,g.self_assign,g.got end
local es=m(n,function(g)local el=r(0)local eu=r(0)local ec={last_pos=0}local em;em=function(eO,P,eI)ec.last_pos=P
return el:top()==eI end;local ef
ef=function(eO,P,eI)
local eN=el:top()if eN~=-1 and eI>eN then el:push(eI)return true end end;local ew;ew=function(eO,P,eI)el:push(eI)return true end
local ey
ey=function()assert(el:pop(),"unexpected outdent")return true end;local ep
ep=function(eO,P,eI)local eN=eu:top()if eN==nil or eN then return true,eI end;return false end;local ev;ev=function()eu:push(false)return true end
local eb;eb=function()assert(eu:pop()~=nil,"unexpected do pop")
return true end
local eg=k("",ev)local ek=k("",eb)local eq={}local ej
ej=function(eO)eq[eO]=true;return A*eO*-S end;local ex
ex=function(eO)local eI=A*v(eO)
if eO:match("^%w*$")then eq[eO]=true;eI=eI*-S end;return eI end
local ez=
k(U,function(eO,P,eI)if eq[eI]then return false end;return true end)/d
local e_=A*"@"*
("@"*
(L/Y("self_class")+x("self.__class"))+L/Y("self")+x("self"))local eE=e_+A*L/Y("key_literal")
local eT=A*p("...")/d
local eA=p({g or File,File=R^-1* (Block+b("")),Block=b(Line* (_^1*Line)^0),CheckIndent=k(C,em),Line=(
CheckIndent*Statement+A*D(E)),Statement=

P(

Import+While+With+
For+ForEach+Switch+Return+Local+Export+BreakLoop+b(ExpList)* (Update+Assign)^-1/K)*A*
(
(

ej("if")*Exp* (
ej("else")*Exp)^-1*A/Y("if")+ej("unless")*Exp/Y("unless")+CompInner/Y("comprehension"))*A)^-1/ea,Body=
A^-1*_*N^0*InBlock+b(Statement),Advance=D(k(C,ef)),PushIndent=k(C,ew),PreventIndent=k(x(-1),ew),PopIndent=k("",ey),InBlock=
Advance*Block*PopIndent,Local=ej("local")*
((ex("*")+ex("^"))/
Y("declare_glob")+b(NameList)/Y("declare_with_shadows")),Import=

ej("import")*b(ImportNameList)*I^0*ej("from")*Exp/Y("import"),ImportName=(
J("\\")*b(x("colon")*ez)+ez),ImportNameList=I^0*ImportName* ((I^1+J(",")*I^0)*
ImportName)^0,BreakLoop=b(
ej("break")/d)+b(ej("continue")/d),Return=

ej("return")* (ExpListLow/Y("explist")+v(""))/Y("return"),WithExp=b(ExpList)*Assign^-1/K,With=

ej("with")*eg*F(WithExp,ek)*ej("do")^-1*Body/Y("with"),Switch=

ej("switch")*eg*F(Exp,ek)*ej("do")^-1*A^-1*_*SwitchBlock/Y("switch"),SwitchBlock=

N^0*Advance*b(SwitchCase* (_^1*SwitchCase)^0*
(_^1*SwitchElse)^-1)*PopIndent,SwitchCase=ej("when")*b(ExpList)*
ej("then")^-1*Body/Y("case"),SwitchElse=
ej("else")*Body/Y("else"),IfCond=Exp*Assign^-1/Q,IfElse=
(_*N^0*CheckIndent)^-1*ej("else")*Body/Y("else"),IfElseIf=
(
_*N^0*CheckIndent)^-1*ej("elseif")*
P(IfCond)*ej("then")^-1*Body/Y("elseif"),If=
ej("if")*IfCond*
ej("then")^-1*Body*IfElseIf^0*IfElse^-1/Y("if"),Unless=
ej("unless")*IfCond*ej("then")^-1*Body*
IfElseIf^0*IfElse^-1/Y("unless"),While=

ej("while")*eg*F(Exp,ek)*ej("do")^-1*Body/Y("while"),For=
ej("for")*eg*
F(ez*J("=")*b(Exp*J(",")*
Exp* (J(",")*Exp)^-1),ek)*ej("do")^-1*Body/Y("for"),ForEach=


ej("for")*b(AssignableNameList)*ej("in")*eg*
F(b(J("*")*Exp/Y("unpack")+ExpList),ek)*ej("do")^-1*Body/Y("foreach"),Do=
ej("do")*Body/Y("do"),Comprehension=J("[")*Exp*CompInner*J("]")/
Y("comprehension"),TblComprehension=J("{")*
b(Exp* (J(",")*Exp)^-1)*CompInner*J("}")/
Y("tblcomprehension"),CompInner=b((CompForEach+CompFor)*
CompClause^0),CompForEach=
ej("for")*b(AssignableNameList)*ej("in")*
(J("*")*Exp/Y("unpack")+Exp)/Y("foreach"),CompFor=ej(
"for"*ez*J("=")*
b(Exp*J(",")*Exp* (J(",")*Exp)^-1)/Y("for")),CompClause=
CompFor+CompForEach+ej("when")*Exp/Y("when"),Assign=
J("=")*
(b(With+If+Switch)+b(TableBlock+ExpListLow))/Y("assign"),Update=
(
(



J("..=")+J("+=")+J("-=")+J("*=")+J("/=")+J("%=")+J("or=")+
J("and=")+J("&=")+J("|=")+J(">>=")+J("<<="))/d)*Exp/Y("update"),CharOperators=
A*v(w("+-*/%^><|&")),WordOperators=



ex("or")+ex("and")+ex("<=")+ex(">=")+ex("~=")+ex("!=")+ex("==")+ex("..")+ex("<<")+ex(">>")+ex("//"),BinaryOperator=
(WordOperators+CharOperators)*I^0,Assignable=k(Chain,G)+ez+e_,Exp=b(Value*
(BinaryOperator*Value)^0)/V("exp"),SimpleValue=







If+
Unless+Switch+With+ClassDecl+ForEach+For+While+k(Do,ep)+
J("-")*-O*Exp/Y("minus")+
J("#")*Exp/Y("length")+J("~")*Exp/Y("bitnot")+ej("not")*Exp/Y("not")+TblComprehension+TableLit+Comprehension+FunLit+H,ChainValue=(
Chain+Callable)*b(InvokeArgs^-1)/et,Value=P(

SimpleValue+b(KeyValueList)/Y("table")+ChainValue+String),SliceValue=Exp,String=
A*DoubleString+A*SingleString+LuaString,SingleString=Z("'"),DoubleString=Z('"',true),LuaString=

q(LuaStringOpen,"string_open")*j("string_open")*_^-1*v(
(1-k(
v(LuaStringClose)*j("string_open"),eo))^0)*LuaStringClose/
Y("string"),LuaStringOpen=J("[")*
p("=")^0*"["/d,LuaStringClose="]"*p("=")^0*"]",Callable=
P(ez/Y("ref"))+e_+eT+Parens/Y("parens"),Parens=
J("(")*I^0*Exp*I^0*J(")"),FnArgs=X("(")*I^0*
b(FnArgsExpList^-1)*I^0*J(")")+
J("!")*-p("=")*b(""),FnArgsExpList=Exp*
((_+J(","))*z*Exp)^0,Chain=
(Callable+String+-w(".\\"))*ChainItems/Y("chain")+
A* (DotChainItem*
ChainItems^-1+ColonChain)/Y("chain"),ChainItems=
ChainItem^1*ColonChain^-1+ColonChain,ChainItem=Invoke+DotChainItem+
Slice+X("[")*Exp/Y("index")*J("]"),DotChainItem=
X(".")*L/Y("dot"),ColonChainItem=X("\\")*L/Y("colon"),ColonChain=ColonChainItem*
(Invoke*ChainItems^-1)^-1,Slice=

X("[")* (SliceValue+x(1))*J(",")* (SliceValue+x(""))* (
J(",")*SliceValue)^-1*J("]")/Y("slice"),Invoke=

FnArgs/Y("call")+SingleString/ee+DoubleString/ee+D(p("["))*LuaString/ee,TableValue=
KeyValue+b(Exp),TableLit=
J("{")*
b(TableValueList^-1*J(",")^-1*
(
I*TableLitLine* (
J(",")^-1*I*TableLitLine)^0*J(",")^-1)^-1)*z*J("}")/Y("table"),TableValueList=
TableValue* (J(",")*TableValue)^0,TableLitLine=
PushIndent* (
(TableValueList*PopIndent)+ (PopIndent*M))+A,TableBlockInner=b(KeyValueLine* (I^1*KeyValueLine)^0),TableBlock=
I^1*Advance*F(TableBlockInner,PopIndent)/Y("table"),ClassDecl=


ej("class")*-p(":")* (Assignable+x(nil))*
(
ej("extends")*PreventIndent*F(Exp,PopIndent)+v(""))^-1* (ClassBlock+b(""))/Y("class"),ClassBlock=
I^1*Advance*
b(ClassLine* (I^1*ClassLine)^0)*PopIndent,ClassLine=CheckIndent*
(
(
KeyValueList/Y("props")+Statement/Y("stm")+Exp/Y("stm"))*J(",")^-1),Export=ej("export")*
(
x("class")*ClassDecl+ex("*")+ex("^")+b(NameList)*
(J("=")*b(ExpListLow))^-1)/Y("export"),KeyValue=(
J(":")*-O*ez*s.Cp())/ei+
b(
(eE+
J("[")*Exp*J("]")+A*DoubleString+A*SingleString)*X(":")*
(Exp+TableBlock+I^1*Exp)),KeyValueList=KeyValue*
(J(",")*KeyValue)^0,KeyValueLine=CheckIndent*KeyValueList*J(",")^-1,FnArgsDef=


J("(")*z*b(FnArgDefList^-1)* (ej("using")*
b(NameList+A*"nil")+b(""))*z*J(")")+b("")*b(""),FnArgDefList=FnArgDef* (
(J(",")+_)*z*FnArgDef)^0* (
(J(",")+_)*z*b(eT))^0+
b(eT),FnArgDef=b((ez+e_)* (J("=")*Exp)^-1),FunLit=
FnArgsDef*
(J("->")*x("slim")+J("=>")*x("fat"))* (Body+b(""))/
Y("fndef"),NameList=ez* (J(",")*ez)^0,NameOrDestructure=ez+TableLit,AssignableNameList=
NameOrDestructure* (J(",")*NameOrDestructure)^0,ExpList=
Exp* (J(",")*Exp)^0,ExpListLow=Exp*
((J(",")+J(";"))*Exp)^0,InvokeArgs=-p("-")*
(ExpList*
(
J(",")* (TableBlock+I*Advance*ArgBlock*TableBlock^-
1)+TableBlock)^-1+TableBlock),ArgBlock=ArgLine*
(J(",")*I*ArgLine)^0*PopIndent,ArgLine=CheckIndent*ExpList})return eA,ec end)local eh,er=es()local ed
ed=function()local g=z*eh*z*-1
return
{match=function(el,eu)local ec
local em,ef=xpcall((function()ec=g:match(eu)end),function(ew)return
debug.traceback(ew,2)end)if type(ef)=="string"then return nil,ef end
if not(ec)then local ew
local ey=er.last_pos
if ef then local eb;eb,ew=c(ef)if ew then ew=" "..ew end;ey=eb[-1]end;local ep=l(eu,ey)local ev=u(eu,ep)or""
return nil,h:format(ew or"",ep,d(ev))end;return ec end}end;return
{extract_line=W,build_grammar=es,string=function(g)return ed():match(g)end}end
a["moonscript.parse.util"]=function(...)local n
n=i("moonscript.util").unpack;local s,h,r,d,l,u
do local R=i("cc.lpeg")s,h,r,d,l,u=R.P,R.C,R.S,R.Cp,R.Cmt,R.V end;local c;c=i("moonscript.types").ntype;local m
m=i("moonscript.parse.literals").Space
local f=h(r("\t ")^0)/function(R)
do local D=0;for L in R:gmatch("[\t ]")do local U=L
if" "==U then D=D+1 elseif"\t"==U then D=D+4 end end;return D end end;local w=s(function()return false end)local y
y=function(R,D)return R*D+D*w end;local p
p=function(R,D)R=R:sub(D)
do local L=R:match("^(.-)\n")if L then return L end end;return R:match("^.-$")end;local v
v=function(R,D,L)if L==nil then L=true end;local U={{}}
for F in R:gmatch(".")do local W=#U;U[W]=U[W]or{}table.insert(U[
#U],F)if F=="\n"then U[#U+1]={}end end;for F,W in ipairs(U)do U[F]=table.concat(W)end;local C;local M=D-1
for F,W in
ipairs(U)do
if M<#W then local Y=W:sub(1,M)local P=W:sub(M+1)
C={tostring(Y).."?"..tostring(P)}if L then
do local V=U[F-1]if V then table.insert(C,1,V)end end
do local V=U[F+1]if V then table.insert(C,V)end end end;break else M=M-#W end end;if not(C)then return"-"end;C=table.concat(C)
return(C:gsub("\n*$",""))end;local b
b=function(R)return function(...)return{R,...}end end;local g
g=function(R)return(d()*R)/
function(g,D)if type(D)=="table"then D[-1]=g end;return D end end;local k
k=function(R,D)if D==nil then D=true end;return
l("",function(L,g)
print("++ got "..tostring(R),"["..
tostring(v(L,g,D)).."]")return true end)end;local q
q=function(R)return
function(D)if#D==1 then return D[1]end;table.insert(D,1,R)return D end end;local j
do local R={index=true,dot=true,slice=true}
j=function(D)
if D=="..."then return false end;local L=c(D)
if
"ref"==L or"self"==L or"value"==L or"self_class"==L or"table"==L then return true elseif"chain"==L then
return R[c(D[#D])]else return false end end end;local x
x=function(R,g,D)if j(D)then return true,D else return false end end;local z
do local R=q("explist")
z=function(D,L)if not(L)then return R(D)end
for M=1,#D do local F=D[M]if not(j(F))then
error({F,"left hand expression is not assignable"})end end;local U=c(L)local C=U
if"assign"==C then return{"assign",D,n(L,2)}elseif"update"==C then return
{"update",D[1],n(L,2)}else return
error("unknown assign expression: "..tostring(U))end end end;local _
_=function(R,D)if D then return z({R},D)else return R end end;local E;E=function(R)return m*R end;local T;T=function(R)return R end;local A
A=function(R,D)
local L=s(
"\\"..tostring(R))+"\\\\"+ (1-s(R))if D then local U=T('#{')*u("Exp")*E('}')
L=(h((L-U)^1)+U/
b("interpolate"))^0 else L=h(L^0)end;return
h(T(R))*L*E(R)/b("string")end;local O;O=function(R)return{"call",{R}}end;local I
I=function(R,D)
if#D==0 then return R end;D={"call",D}
if c(R)=="chain"then table.insert(R,D)return R end;return{"chain",R,D}end;local N
N=function(R,D)if not(D)then return R end;return{"decorated",R,D}end;local S;S=function(R,g,D,L)return#L==#D end;local H
H=function(R,g)return
{{"key_literal",R},{"ref",R,[-1]=g}}end
return
{Indent=f,Cut=w,ensure=y,extract_line=p,mark=b,pos=g,flatten_or_mark=q,is_assignable=j,check_assignable=x,format_assign=z,format_single_assign=_,sym=E,symx=T,simple_string=A,wrap_func_arg=O,join_chain=I,wrap_decorator=N,check_lua_string=S,self_assign=H,got=k,show_line_position=v}end
a["moonscript.parse.literals"]=function(...)local n
n=i("moonscript.util").safe_module;local s,h,r,d;do local z=i("cc.lpeg")s,h,r,d=z.S,z.P,z.R,z.C end
local l=i("cc.lpeg")
local u=l.luversion and l.L or function(z)return#z end;local c=s(" \t\r\n")^0;local m=s(" \t")^0
local f=h("\r")^-1*h("\n")local w=f+-1
local y=h("--")* (1-s("\r\n"))^0*u(w)local p=m*y^-1;local v=s(" \t")^1*y^-1;local b=p*f;local g=b
local k=r("az","AZ","09","__")local q=d(r("az","AZ","__")*k^0)
local j=h("0x")*
r("09","af","AF")^1*
(s("uU")^-1*s("lL")^2)^-1+r("09")^1*
(s("uU")^-1*s("lL")^2)+
(r("09")^1* (
h(".")*r("09")^1)^-1+
h(".")*r("09")^1)* (
s("eE")*h("-")^-1*r("09")^1)^-1;local x=h("#!")*h(1-w)^0
return
n("moonscript.parse.literals",{L=u,White=c,Break=f,Stop=w,Comment=y,Space=p,SomeSpace=v,SpaceBreak=b,EmptyLine=g,AlphaNum=k,Name=q,Num=j,Shebang=x})end
a["moonscript.parse.env"]=function(...)local n,s;do local r=i("moonscript.util")
n,s=r.getfenv,r.setfenv end;local h
h=function(r,d)local l,u
do local f=i("cc.lpeg")l,u=f.V,f.Cmt end;local c=n(d)local m=l
if r then local f=0;local w="  "local y
y=function(...)
local p=table.concat((function(...)local v={}local b=1;local g={...}for k=1,#g do local q=g[k]
v[b]=tostring(q)b=b+1 end;return v end)(...),", ")return
io.stderr:write(tostring(w:rep(f))..tostring(p).."\n")end
m=function(p)local b=l(p)
b=

u("",function(v,g)local k=v:sub(g,-1):match("^([^\n]*)")
y("* "..
tostring(p).." ("..tostring(k)..")")f=f+1;return true end)*
u(b,function(v,g,...)y(p,true)f=f-1;return true,...end)+u("",function()y(p,false)f=f-1;return false end)return b end end
return
s(d,setmetatable({},{__index=function(f,w)local y=c[w]if y~=nil then return y end;if w:match("^[A-Z][A-Za-z0-9]*$")then
local p=m(w)return p end;return
error("unknown variable referenced: "..tostring(w))end}))end;return{wrap_env=h}end;a["moonscript.line_tables"]=function(...)return{}end
a["moonscript"]=function(...)

do local n=i("moonscript.base")n.insert_loader()return n end end
a["moonscript.errors"]=function(...)local n=i("moonscript.util")local s=i("cc.lpeg")
local h,r;do local y=table;h,r=y.concat,y.insert end;local d,l
d,l=n.split,n.pos_to_line;local u
u=function(...)return error({"user-error",...})end;local c
c=function(y,p,v)if not v[y]then do local b=assert(io.open(y))v[y]=b:read("*a")
b:close()end end;return
l(v[y],p)end;local m
m=function(y,p,v,b)for g=v,0,-1 do if p[g]then return c(y,p[g],b)end end;return
"unknown"end;local f
f=function(y,p)if p==nil then p="moonscript_chunk"end;y=d(y,"\n")local v=#y;while v>1 do if
y[v]:match(p)then break end;v=v-1 end
do local g={}local k=1;local q=v;for j=1,
q<0 and#y+q or q do local x=y[j]g[k]=x;k=k+1 end;y=g end;local b="function '"..p.."'"
y[#y]=y[#y]:gsub(b,"main chunk")return h(y,"\n")end;local w
w=function(y,p)local v=i("moonscript.line_tables")local b,k,q,j
b,k,q,j=s.V,s.S,s.Ct,s.C;local x="stack traceback:"local z,_=b("Header"),b("Line")local E=s.S("\n")
local T=s.P({z,Header=
x*E*q(_^1),Line="\t"*j((1-E)^0)* (E+-1)})local A={}local O
O=function(g)local N,S,H=g:match('^(.-):(%d+): (.*)$')
local R=v["@"..tostring(N)]if N and R then
return h({N,":",m(N,R,S,A),": ","(",S,") ",H})else return g end end;p=O(p)local I=T:match(y)if not(I)then return nil end
for g,N in ipairs(I)do I[g]=O(N)end
return h({"moon: "..p,x,"\t"..h(I,"\n\t")},"\n")end
return{rewrite_traceback=w,truncate_traceback=f,user_error=u,reverse_line_number=m}end
a["moonscript.dump"]=function(...)local n
n=function(r,d)if d==nil then d=1 end;if type(r)=="string"then
return'"'..r..'"'end
if type(r)~="table"then return tostring(r)end;local l
do local c={}local m=1;for f=1,#r do local w=r[f]c[m]=n(w,d+1)m=m+1 end;l=c end;local u=r[-1]
return"{".. (u and"["..u.."] "or"")..
table.concat(l,", ").."}"end;local s;s=function(r)return n(r)end;local h
h=function(r)return
table.concat((function()local d={}local l=1;for u=1,#r do local s=r[u]
d[l]=n(s)l=l+1 end;return d end)(),"\n")end;return{value=s,tree=h}end
a["moonscript.data"]=function(...)local n,s,h
do local u=table;n,s,h=u.concat,u.remove,u.insert end;local r
r=function(u)local c={}for m=1,#u do local f=u[m]c[f]=true end;return c end;local d
do local u
local c={__tostring=function(m)return"<Stack {"..n(m,", ").."}>"end,pop=function(m)return
s(m)end,push=function(m,f,...)h(m,f)if...then return m:push(...)else return f end end,top=function(m)return m[
#m]end}c.__index=c
u=setmetatable({__init=function(m,...)m:push(...)return nil end,__base=c,__name="Stack"},{__index=c,__call=function(m,...)
local f=setmetatable({},c)m.__init(f,...)return f end})c.__class=u;d=u end
local l=r({'and','break','do','else','elseif','end','false','for','function','if','in','local','nil','not','or','repeat','return','then','true','until','while'})return{Set=r,Stack=d,lua_keywords=l}end
a["moonscript.compile"]=function(...)local n=i("moonscript.util")
local s=i("moonscript.dump")local h=i("moonscript.transform")local r,d;do
local I=i("moonscript.transform.names")r,d=I.NameProxy,I.LocalName end;local l
l=i("moonscript.data").Set;local u,c
do local I=i("moonscript.types")u,c=I.ntype,I.value_can_be_statement end;local m=i("moonscript.compile.statement")
local f=i("moonscript.compile.value")local w,y;do local I=table;w,y=I.concat,I.insert end;local p,v,b,g
p,v,b,g=n.pos_to_line,n.get_closest_line,n.trim,n.unpack;local k=n.moon.type;local q="  "local j,x,z,_,E
do local I
local N={mark_pos=function(S,H,R)if R==nil then R=#S end;if
not(S.posmap[R])then S.posmap[R]=H end end,add=function(S,H)
local R=k(H)
if j==R then H:render(S)elseif _==R then H:render(S)else S[#S+1]=H end;return S end,flatten_posmap=function(S,H,R)
if H==nil then H=0 end;if R==nil then R={}end;local D=S.posmap
for L,U in ipairs(S)do local C=k(U)
if"string"==C or x==C then
H=H+1;R[H]=D[L]for M in U:gmatch("\n")do H=H+1 end;R[H]=D[L]elseif z==C then local M
M,H=U:flatten_posmap(H,R)else
error("Unknown item in Lines: "..tostring(U))end end;return R,H end,flatten=function(S,H,R)if
H==nil then H=nil end;if R==nil then R={}end
for D=1,#S do local L=S[D]local U=k(L)if U==x then
L=L:render()U="string"end;local C=U
if"string"==C then if H then y(R,H)end;y(R,L)if"string"==type(S[
D+1])then
if
L:sub(-1)~=','and L:sub(-3)~='end'and S[D+1]:sub(1,1)=="("then y(R,";")end end;y(R,"\n")elseif z==C then L:flatten(
H and H..q or q,R)else
error("Unknown item in Lines: "..tostring(L))end end;return R end,__tostring=function(S)
local H
H=function(R)if"table"==type(R)then local D={}local L=1
for U=1,#R do local C=R[U]D[L]=H(C)L=L+1 end;return D else return R end end;return"Lines<"..
tostring(n.dump(H(S)):sub(1,-2))..">"end}N.__index=N
I=setmetatable({__init=function(S)S.posmap={}end,__base=N,__name="Lines"},{__index=N,__call=function(S,...)
local H=setmetatable({},N)S.__init(H,...)return H end})N.__class=I;z=I end
do local I
local N={pos=nil,append_list=function(S,H,R)
for D=1,#H do S:append(H[D])if D<#H then y(S,R)end end;return nil end,append=function(S,H,...)
if j==k(H)then if not(S.pos)then
S.pos=H.pos end;for R=1,#H do local D=H[R]S:append(D)end else y(S,H)end;if...then return S:append(...)end end,render=function(S,H)
local R={}local D
D=function()H:add(w(R))return H:mark_pos(S.pos)end
for L=1,#S do local U=S[L]local C=k(U)if _==C then local M=U:render(z())
for F=1,#M do local W=M[F]if
"string"==type(W)then y(R,W)else D()H:add(W)R={}end end else y(R,U)end end;if R[1]then D()end;return H end,__tostring=function(S)return

"Line<"..tostring(n.dump(S):sub(1,-2))..">"end}N.__index=N
I=setmetatable({__init=function()end,__base=N,__name="Line"},{__index=N,__call=function(S,...)
local H=setmetatable({},N)S.__init(H,...)return H end})N.__class=I;j=I end
do local I
local N={prepare=function()end,render=function(S)S:prepare()return w(S)end}N.__index=N
I=setmetatable({__init=function(S,H)S.prepare=H end,__base=N,__name="DelayedLine"},{__index=N,__call=function(S,...)
local H=setmetatable({},N)S.__init(H,...)return H end})N.__class=I;x=I end
do local I
local N={header="do",footer="end",export_all=false,export_proper=false,value_compilers=f,statement_compilers=m,__tostring=function(S)local H;if"string"==type(S.header)then H=S.header else
H=g(S.header:render({}))end;return"Block<"..tostring(H)..
"> <- "..tostring(S.parent)end,set=function(S,H,R)
S._state[H]=R end,get=function(S,H)return S._state[H]end,get_current=function(S,H)
return rawget(S._state,H)end,listen=function(S,H,R)S._listeners[H]=R end,unlisten=function(S,H)S._listeners[H]=
nil end,send=function(S,H,...)do local R=S._listeners[H]
if R then return R(S,...)end end end,extract_assign_name=function(S,H)
local R=false;local D;local L=k(H)
if d==L then R=true;D=H:get_name(S)elseif r==L then D=H:get_name(S)elseif"table"==L then D=
H[1]=="ref"and H[2]elseif"string"==L then D=H end;return D,R end,declare=function(S,H)
local R
do local D={}local L=1
for U=1,#H do local C=false
repeat local M=H[U]local F,W=S:extract_assign_name(M)if
not(W or F and not
S:has_name(F,true))then C=true;break end;S:put_name(F)if
S:name_exported(F)then C=true;break end;local Y=F;D[L]=Y;L=L+1;C=true until true;if not C then break end end;R=D end;return R end,whitelist_names=function(S,H)
S._name_whitelist=l(H)end,name_exported=function(S,H)if S.export_all then return true end;if
S.export_proper and H:match("^%u")then return true end end,put_name=function(S,H,...)
local R=...if select("#",...)==0 then R=true end
if r==k(H)then H=H:get_name(S)end;S._names[H]=R end,has_name=function(S,H,R)if
not R and S:name_exported(H)then return true end
local D=S._names[H]if D==nil and S.parent then
if
not S._name_whitelist or S._name_whitelist[H]then return S.parent:has_name(H,true)end else return D end end,is_local=function(S,H)
local R=k(H)if R=="string"then return S:has_name(H,false)end;if
R==r or R==d then return true end;if R=="table"then
if H[1]=="ref"or
(H[1]=="chain"and#H==2)then return S:is_local(H[2])end end;return false end,free_name=function(S,H,R)H=
H or"moon"local D=true;local L,U=nil,0;while D do L=w({"",H,U},"_")U=U+1
D=S:has_name(L,true)end;if not R then S:put_name(L)end;return L end,init_free_var=function(S,H,R)
local D=S:free_name(H,true)S:stm({"assign",{D},{R}})return D end,add=function(S,H,R)

do local D=S._lines;D:add(H)if R then D:mark_pos(R)end end;return H end,render=function(S,H)H:add(S.header)
H:mark_pos(S.pos)
if S.next then H:add(S._lines)S.next:render(H)else
if#S._lines==0 and"string"==
type(H[#H])then local R=#H;H[R]=H[R].. (" "..
(g(z():add(S.footer))))else
H:add(S._lines)H:add(S.footer)H:mark_pos(S.pos)end end;return H end,block=function(S,H,R)return
_(S,H,R)end,line=function(S,...)do local H=j()H:append(...)return H end end,is_stm=function(S,H)return
S.statement_compilers[u(H)]~=nil end,is_value=function(S,H)local R=u(H)return
S.value_compilers[R]~=nil or R=="value"end,name=function(S,H,...)if
type(H)=="string"then return H else return S:value(H,...)end end,value=function(S,H,...)
H=S.transform.value(H)local R;if type(H)~="table"then R="raw_value"else R=H[1]end
local D=S.value_compilers[R]if not(D)then
error({"compile-error","Failed to find value compiler for: "..s.value(H),H[-1]})end;local L=D(S,H,...)
if
type(H)=="table"and H[-1]then if type(L)=="string"then
do local U=j()U:append(L)L=U end end;L.pos=H[-1]end;return L end,values=function(S,H,R)R=
R or', 'do local D=j()
D:append_list((function()local L={}local U=1
for C=1,#H do local M=H[C]L[U]=S:value(M)U=U+1 end;return L end)(),R)return D end end,stm=function(S,H,...)if
not H then return end;H=S.transform.statement(H)local R;do
local D=S.statement_compilers[u(H)]
if D then R=D(S,H,...)else if c(H)then R=S:value(H)else
R=S:stm({"assign",{"_"},{H}})end end end
if R then if type(H)==
"table"and type(R)=="table"and H[-1]then R.pos=H[
-1]end;S:add(R)end;return nil end,stms=function(S,H,R)
if
R then error("deprecated stms call, use transformer")end;local D,L;D,L=S.current_stms,S.current_stm_i;S.current_stms=H;for U=1,#H do S.current_stm_i=U
S:stm(H[U])end;S.current_stms=D;S.current_stm_i=L;return nil end,splice=function(S,H)
local R={"lines",S._lines}S._lines=z()return S:stms(H(R))end}N.__index=N
I=setmetatable({__init=function(S,H,R,D)S.parent,S.header,S.footer=H,R,D;S._lines=z()S._names={}
S._state={}S._listeners={}do
S.transform={value=h.Value:bind(S),statement=h.Statement:bind(S)}end
if S.parent then S.root=S.parent.root;S.indent=
S.parent.indent+1
setmetatable(S._state,{__index=S.parent._state})
return setmetatable(S._listeners,{__index=S.parent._listeners})else S.indent=0 end end,__base=N,__name="Block"},{__index=N,__call=function(S,...)
local H=setmetatable({},N)S.__init(H,...)return H end})N.__class=I;_=I end
do local I;local N=_
local S={__tostring=function(H)return"RootBlock<>"end,root_stms=function(H,R)if not
(H.options.implicitly_return_root==false)then
R=h.Statement.transformers.root_stms(H,R)end;return H:stms(R)end,render=function(H)
local R=H._lines:flatten()if R[#R]=="\n"then R[#R]=nil end;return table.concat(R)end}S.__index=S;setmetatable(S,N.__base)
I=setmetatable({__init=function(H,R)H.options=R;H.root=H;return
I.__parent.__init(H)end,__base=S,__name="RootBlock",__parent=N},{__index=function(H,R)
local D=rawget(S,R)
if D==nil then local L=rawget(H,"__parent")if L then return L[R]end else return D end end,__call=function(H,...)
local R=setmetatable({},S)H.__init(R,...)return R end})S.__class=I;if N.__inherited then N.__inherited(N,I)end;E=I end;local T
T=function(I,N,S)local H;if N then local R=p(S,N)local D;D,R=v(S,R)D=D or""
H=(" [%d] >>    %s"):format(R,b(D))end;return
w({"Compile error: "..I,H},"\n")end;local A
A=function(A)local I=nil
do local N=E()N:add(N:value(A))I=N:render()end;return I end;local O
O=function(O,I)if I==nil then I={}end;assert(O,"missing tree")
local N=(I.scope or E)(I)
local S=coroutine.create(function()return N:root_stms(O)end)local H,R=coroutine.resume(S)
if not(H)then local U,C
if type(R)=="table"then local M=R[1]if
"user-error"==M or"compile-error"==M then U,C=g(R,2)else
U,C=error("Unknown error thrown",n.dump(U))end else
U,C=w({R,debug.traceback(S)},"\n")end;return nil,U,C or N.last_pos end;local D=N:render()local L=N._lines:flatten_posmap()return D,L end
do local I=i("moonscript.data")for N,S in pairs({Line=j,Lines=z,DelayedLine=x})do
I[N]=S end end;return{tree=O,value=A,format_error=T,Block=_,RootBlock=E}end
a["moonscript.compile.value"]=function(...)local n=i("moonscript.util")
local s=i("moonscript.data")local h;h=i("moonscript.types").ntype;local r
r=i("moonscript.errors").user_error;local d,l;do local f=table;d,l=f.concat,f.insert end;local u;u=n.unpack
local c=","local m={["\r"]="\\r",["\n"]="\\n"}
return
{scoped=function(f,w)local y,p,v,b;y,p,v,b=w[1],w[2],w[3],w[4]y=p and
p:call(f)
do local g=f:value(v)y=b and b:call(f)return g end end,exp=function(f,w)local y
y=function(p,v)if p%2 ==1 and v==
"!="then v="~="end;return f:value(v)end
do local p=f:line()
p:append_list((function()local v={}local b=1;for g,k in ipairs(w)do
if g>1 then v[b]=y(g,k)b=b+1 end end;return v end)()," ")return p end end,explist=function(f,w)

do local y=f:line()
y:append_list((function()local p={}local v=1
for b=2,#w do local g=w[b]p[v]=f:value(g)v=v+1 end;return p end)(),", ")return y end end,parens=function(f,w)return
f:line("(",f:value(w[2]),")")end,string=function(f,w)local y,p=u(w,2)
local v=y:gsub("%[","]")if y=="'"or y=='"'then p=p:gsub("[\r\n]",m)end
return y..p..v end,chain=function(f,w)local y=w[2]
local p=h(y)local v=3
if p=="dot"or p=="colon"or p=="index"then
y=f:get("scope_var")if not(y)then
r("Short-dot syntax must be called within a with block")end;v=2 end;if p=="ref"and y[2]=="super"or y=="super"then
do
local q=f:get("super")if q then return f:value(q(f,w))end end end;local b
b=function(w)local q,j=u(w)
if
q=="call"then return"(",f:values(j),")"elseif q=="index"then return"[",f:value(j),"]"elseif q=="dot"then return".",
tostring(j)elseif q=="colon"then return":",tostring(j)elseif q=="colon_stub"then return
r("Uncalled colon stub")else return
error("Unknown chain action: "..tostring(q))end end
if(p=="self"or p=="self_class")and w[3]and
h(w[3])=="call"then y[1]=p.."_colon"end;local g=f:value(y)
if h(y)=="exp"then g=f:line("(",g,")")end;local k;do local q=f:line()for j=v,#w do local x=w[j]q:append(b(x))end
k=q end;return f:line(g,k)end,fndef=function(f,w)
local y,p,v,b=u(w,2)local g={}local k={}local q
do local j={}local x=1
for z=1,#y do local _=y[z]local E,T=u(_)
if type(E)=="string"then E=E else if
E[1]=="self"or E[1]=="self_class"then l(k,E)end;E=E[2]end;if T then l(g,_)end;local A=E;j[x]=A;x=x+1 end;q=j end;if v=="fat"then l(q,1,"self")end
do local j=f:block()if#p>0 then
j:whitelist_names(p)end;for z=1,#q do local _=q[z]j:put_name(_)end;for z=1,#g do
local _=g[z]local E,T=u(_)if type(E)=="table"then E=E[2]end
j:stm({'if',{'exp',{"ref",E},'==','nil'},{{'assign',{E},{T}}}})end;local x
do
local z={}local _=1;for E=1,#k do local T=k[E]z[_]=T[2]_=_+1 end;x=z end;if#k>0 then j:stm({"assign",k,x})end;j:stms(b)if
#y>#q then
do local z={}local _=1;for E=1,#y do local T=y[E]z[_]=T[1]_=_+1 end;q=z end end
j.header="function("..d(q,", ")..")"return j end end,table=function(f,w)
local y=u(w,2)
do local p=f:block("{","}")local v
v=function(b)
if#b==2 then local g,k=u(b)
if h(g)=="key_literal"and
s.lua_keywords[g[2]]then g={"string",'"',g[2]}end;local q
if h(g)=="key_literal"then q=g[2]else q=f:line("[",p:value(g),"]")end;local j=f:line(q," = ",p:value(k))return j else return
f:line(p:value(b[1]))end end
if y then local b=#y;for g,k in ipairs(y)do local q=v(k)if not(b==g)then q:append(c)end
p:add(q)end end;return p end end,minus=function(f,w)return
f:line("-",f:value(w[2]))end,temp_name=function(f,w,...)return w:get_name(f,...)end,number=function(f,w)return
w[2]end,bitnot=function(f,w)return f:line("~",f:value(w[2]))end,length=function(f,w)return
f:line("#",f:value(w[2]))end,["not"]=function(f,w)return
f:line("not ",f:value(w[2]))end,self=function(f,w)local y=f:name(w[2])
if
s.lua_keywords[y]then return
f:value({"chain","self",{"index",{"string",'"',y}}})else return"self."..tostring(y)end end,self_class=function(f,w)
local y=f:name(w[2])if s.lua_keywords[y]then return
f:value({"chain","self",{"dot","__class"},{"index",{"string",'"',y}}})else
return"self.__class."..tostring(y)end end,self_colon=function(f,w)return
"self:"..tostring(f:name(w[2]))end,self_class_colon=function(f,w)return
"self.__class:"..tostring(f:name(w[2]))end,ref=function(f,w)
do local y=w[2]=="super"and f:get("super")if y then return
f:value(y(f))end end;return
tostring(w[2])end,raw_value=function(f,w)if
w=="..."then f:send("varargs")end;return tostring(w)end}end
a["moonscript.compile.statement"]=function(...)local n
n=i("moonscript.types").ntype;local s,h;do local d=table;s,h=d.concat,d.insert end;local r
r=i("moonscript.util").unpack
return
{raw=function(d,l)return d:add(l[2])end,lines=function(d,l)local u=l[2]
for c=1,#u do local m=u[c]d:add(m)end end,declare=function(d,l)local u=l[2]local c=d:declare(u)
if#c>0 then
do
local m=d:line("local ")
m:append_list((function()local f={}local w=1
for y=1,#c do local p=c[y]f[w]=d:name(p)w=w+1 end;return f end)(),", ")return m end end end,declare_with_shadows=function(d,l)
local u=l[2]d:declare(u)
do local c=d:line("local ")
c:append_list((function()local m={}local f=1;for w=1,#u do local y=u[w]
m[f]=d:name(y)f=f+1 end;return m end)(),", ")return c end end,assign=function(d,l)
local u,c=r(l,2)local m=d:declare(u)local f="local "..s(m,", ")local w=false;local y=1;while y<=#c do if
n(c[y])=="fndef"then w=true end;y=y+1 end
do
local p=d:line()
if#m==#u and not w then p:append(f)else if#m>0 then d:add(f,l[-1])end
p:append_list((function()
local v={}local b=1;for g=1,#u do local k=u[g]v[b]=d:value(k)b=b+1 end;return v end)(),", ")end;p:append(" = ")
p:append_list((function()local v={}local b=1;for g=1,#c do local k=c[g]v[b]=d:value(k)
b=b+1 end;return v end)(),", ")return p end end,["return"]=function(d,l)return
d:line("return ",(function()if
l[2]~=""then return d:value(l[2])end end)())end,["break"]=function(d,l)return
"break"end,["if"]=function(d,l)local u,c=l[2],l[3]local m;do
local y=d:block(d:line("if ",d:value(u)," then"))y:stms(c)m=y end;local f=m;local w
w=function(y)local p=y[1]local v=2
local b;if p=="else"then b=d:block("else")else v=v+1
b=d:block(d:line("elseif ",d:value(y[2])," then"))end;b:stms(y[v])
f.next=b;f=b end;for y=4,#l do local u=l[y]w(u)end;return m end,["repeat"]=function(d,l)
local u,c=r(l,2)do
local m=d:block("repeat",d:line("until ",d:value(u)))m:stms(c)return m end end,["while"]=function(d,l)
local u,c=r(l,2)do
local m=d:block(d:line("while ",d:value(u)," do"))m:stms(c)return m end end,["for"]=function(d,l)
local u,c,m=r(l,2)
local f=d:line("for ",d:name(u)," = ",d:value({"explist",r(c)})," do")
do local w=d:block(f)w:declare({u})w:stms(m)return w end end,foreach=function(d,l)
local u,c,m=r(l,2)local f;do local w=d:line()w:append("for ")f=w end
do
local w=d:block(f)
f:append_list((function()local y={}local p=1
for v=1,#u do local b=u[v]y[p]=w:name(b,false)p=p+1 end;return y end)(),", ")f:append(" in ")
f:append_list((function()local y={}local p=1;for v=1,#c do local b=c[v]y[p]=d:value(b)
p=p+1 end;return y end)(),",")f:append(" do")w:declare(u)w:stms(m)return w end end,export=function(d,l)
local u=r(l,2)
if type(u)=="string"then
if u=="*"then d.export_all=true elseif u=="^"then d.export_proper=true end else d:declare(u)end;return nil end,run=function(d,l)
l:call(d)return nil end,group=function(d,l)return d:stms(l[2])end,["do"]=function(d,l)do
local u=d:block()u:stms(l[2])return u end end,noop=function(d)
end}end
a["moonscript.cmd.watchers"]=function(...)local n
n=function(l,u)local c={}
return
(function()local m={}local f=1
for w=1,#l do local y=false;repeat local p=l[w]local v;if u then
v=u(p)else v=p end;if c[v]then y=true;break end;c[v]=true;local b=p;m[f]=b;f=f+1;y=true until
true
if not y then break end end;return m end)()end;local s
s=function(l,u)
return tostring(l).." "..
tostring(u)..tostring(l==1 and""or"s")end;local h
do local l
local u={start_msg="Starting watch loop (Ctrl-C to exit)",print_start=function(c,m,f)return
io.stderr:write(tostring(c.start_msg)..
" with "..tostring(m)..
" ["..tostring(f).."]\n")end}u.__index=u
l=setmetatable({__init=function(c,m)c.file_list=m end,__base=u,__name="Watcher"},{__index=u,__call=function(c,...)
local m=setmetatable({},u)c.__init(m,...)return m end})u.__class=l;h=l end;local r
do local l;local u=h
local c={get_dirs=function(f)local w
w=i("moonscript.cmd.moonc").parse_dir;local y
do local p={}local v=1;local b=f.file_list;for g=1,#b do local k=b[g]local q;q=k[1]local j=w(q)
if j==""then j="./"end;local x=j;p[v]=x;v=v+1 end;y=p end;return n(y)end,each_update=function(f)
return
coroutine.wrap(function()
local w=f:get_dirs()f:print_start("inotify",s(#w,"dir"))local y={}
local p=i("inotify")local v=p.init()for b=1,#w do local g=w[b]
local k=v:addwatch(g,p.IN_CLOSE_WRITE,p.IN_MOVED_TO)y[k]=g end
while true do local b=v:read()if not(b)then
break end
for g=1,#b do local k=false
repeat local q=b[g]local j=q.name;if
not(j:match("%.moon$"))then k=true;break end;local x=y[q.wd]if x~="./"then j=x..j end
coroutine.yield(j)k=true until true;if not k then break end end end end)end}c.__index=c;setmetatable(c,u.__base)
l=setmetatable({__init=function(f,...)return
l.__parent.__init(f,...)end,__base=c,__name="InotifyWacher",__parent=u},{__index=function(f,w)
local y=rawget(c,w)
if y==nil then local p=rawget(f,"__parent")if p then return p[w]end else return y end end,__call=function(f,...)
local w=setmetatable({},c)f.__init(w,...)return w end})c.__class=l;local m=l
m.available=function(m)return
pcall(function()return i("inotify")end)end;if u.__inherited then u.__inherited(u,l)end;r=l end;local d
do local l;local u=h
local c={polling_rate=1.0,get_sleep_func=function(m)local f
pcall(function()f=i("socket").sleep end)f=f or i("moonscript")._sleep;if not(f)then
error("Missing sleep function; install LuaSocket")end;return f end,each_update=function(m)
return
coroutine.wrap(function()
local f=i("cc.lfs")local w=m:get_sleep_func()
m:print_start("polling",s(#m.file_list,"files"))local y={}
while true do local p=m.file_list
for v=1,#p do local b=false
repeat local g=p[v]local k;k=g[1]
local q=f.attributes(k,"modification")if not(q)then y[k]=nil;b=true;break end
if not(y[k])then y[k]=q;b=true;break end;if q>y[k]then y[k]=q;coroutine.yield(k)end;b=true until true;if not b then break end end;w(m.polling_rate)end end)end}c.__index=c;setmetatable(c,u.__base)
l=setmetatable({__init=function(m,...)return
l.__parent.__init(m,...)end,__base=c,__name="SleepWatcher",__parent=u},{__index=function(m,f)
local w=rawget(c,f)
if w==nil then local y=rawget(m,"__parent")if y then return y[f]end else return w end end,__call=function(m,...)
local f=setmetatable({},c)m.__init(f,...)return f end})c.__class=l;if u.__inherited then u.__inherited(u,l)end;d=l end;return{Watcher=h,SleepWatcher=d,InotifyWacher=r}end
a["moonscript.cmd.moonc"]=function(...)local n=i("cc.lfs")local s
s=i("moonscript.util").split;local h,r,d,l,u,c,m,f,w,y,p,v,b,g;h=package.config:sub(1,1)if h=="\\"then r="\\/"else
r=h end
d=function(k)local q=s(k,h)local j;for x=1,#q do local z=q[x]
j=j and tostring(j)..
tostring(h)..tostring(z)or z;n.mkdir(j)end;return
n.attributes(k,"mode")end
l=function(k)return
k:match("^(.-)["..tostring(r).."]*$")..h end
u=function(k)return
(k:match("^(.-)[^"..tostring(r).."]*$"))end
c=function(k)return
(k:match("^.-([^"..tostring(r).."]*)$"))end
m=function(k)local q=k:gsub("%.moon$",".lua")if q==k then q=k..".lua"end;return q end
f=function(k)return("%.3fms"):format(k*1000)end
do local k
w=function()if k==nil then pcall(function()k=i("socket")end)if not
(k)then k=false end end
if k then
return k.gettime()else return nil,"LuaSocket needed for benchmark"end end end
y=function(k,q)if q==nil then q={}end;local j=i("moonscript.parse")
local x=i("moonscript.compile")local z;if q.benchmark then z=assert(w())end;local _,E=j.string(k)if not(_)then
return nil,E end;if z then z=w()-z end
if q.show_parse_tree then
local N=i("moonscript.dump")print(N.tree(_))return true end;local T;if q.benchmark then T=w()end;do local N=q.transform_module
if N then
local S=assert(loadfile(N))local H=assert(S())_=assert(H(_))end end;local A,O,I=x.tree(_)if
not(A)then return nil,x.format_error(O,I,k)end
if T then T=w()-T end
if q.show_posmap then local N;N=i("moonscript.util").debug_posmap
print("Pos","Lua",">>","Moon")print(N(O,k,A))return true end;if q.benchmark then
print(table.concat({q.fname or"stdin","Parse time  \t"..f(z),"Compile time\t"..f(T),""},"\n"))return true end
return A end
p=function(k,q)d(u(k))local j,x=io.open(k,"wb")if not(j)then return nil,x end
assert(j:write(q))assert(j:write("\n"))j:close()return"build"end
v=function(k,q,j)if j==nil then j={}end;local x=io.open(k)
if not(x)then return nil,"Can't find file"end;local z=assert(x:read("*a"))x:close()local _,E=y(z,j)
if not _ then return nil,E end;if _==true then return true end;if j.print then print(_)return true end;return
p(q,_)end
b=function(k)local q=k:sub(1,1)if h=="\\"then return
q=="/"or q=="\\"or k:sub(2,1)==":"else return q==h end end
g=function(k,q,j)if q==nil then q=nil end;if j==nil then j=nil end;local x=m(k)if q then q=l(q)end
if j and q then
local z=j:match(
"^(.-)[^"..tostring(r).."]*["..tostring(r).."]?$")
if z then local _,E=x:find(z,1,true)if _==1 then x=x:sub(E+1)end end end;if q then if b(x)then x=c(x)end;x=q..x end;return x end
return
{dirsep=h,mkdir=d,normalize_dir=l,parse_dir=u,parse_file=c,convert_path=m,gettime=w,format_time=f,path_to_target=g,compile_file_text=y,compile_and_write=v}end
a["moonscript.cmd.lint"]=function(...)local n;n=table.insert;local s
s=i("moonscript.data").Set;local h;h=i("moonscript.compile").Block;local r
r=i("moonscript.util").moon.type
local d=s({'_G','_VERSION','assert','bit32','collectgarbage','coroutine','debug','dofile','error','getfenv','getmetatable','io','ipairs','load','loadfile','loadstring','math','module','next','os','package','pairs','pcall','print','rawequal','rawget','rawlen','rawset','require','select','setfenv','setmetatable','string','table','tonumber','tostring','type','unpack','xpcall',"nil","true","false"})local l
do local w;local y=h
local p={lint_mark_used=function(v,b)if v.lint_unused_names and v.lint_unused_names[b]then
v.lint_unused_names[b]=false;return end;if v.parent then return
v.parent:lint_mark_used(b)end end,lint_check_unused=function(v)if
not
(v.lint_unused_names and next(v.lint_unused_names))then return end;local b={}
for k,q in
pairs(v.lint_unused_names)do local j=false;repeat if not(q)then j=true;break end;local x=q;b[x]=b[x]or{}n(b[q],k)
j=true until true;if not j then break end end;local g
do local k={}local q=1;for j,x in pairs(b)do k[q]={j,x}q=q+1 end;g=k end
table.sort(g,function(k,q)return k[1]<q[1]end)
for k=1,#g do local q=g[k]local j,x;j,x=q[1],q[2]
n(v:get_root_block().lint_errors,{"assigned but unused "..
tostring(table.concat((function()
local z={}local _=1
for E=1,#x do local T=x[E]z[_]="`"..tostring(T).."`"_=_+1 end;return z end)(),", ")),j})end end,render=function(v,...)
v:lint_check_unused()return w.__parent.__base.render(v,...)end,block=function(v,...)

do local b=w.__parent.__base.block(v,...)
b.block=v.block;b.render=v.render;b.get_root_block=v.get_root_block
b.lint_check_unused=v.lint_check_unused;b.lint_mark_used=v.lint_mark_used;b.value_compilers=v.value_compilers
b.statement_compilers=v.statement_compilers;return b end end}p.__index=p;setmetatable(p,y.__base)
w=setmetatable({__init=function(v,b,...)if b==nil then b=d end
w.__parent.__init(v,...)v.get_root_block=function()return v end;v.lint_errors={}
local g=v.value_compilers
v.value_compilers=setmetatable({ref=function(q,j)local x=j[2]if not
(q:has_name(x)or b[x]or x:match("%."))then
n(v.lint_errors,{"accessing global `"..tostring(x).."`",j[
-1]})end
q:lint_mark_used(x)return g.ref(q,j)end},{__index=g})local k=v.statement_compilers
v.statement_compilers=setmetatable({assign=function(q,j)local x=j[2]
for z=1,#x do local _=false
repeat local E=x[z]
if
type(E)=="table"and E[1]=="temp_name"then _=true;break end;local T,A=q:extract_assign_name(E)
if not(A or
T and not q:has_name(T,true))then _=true;break end;if T=="_"then _=true;break end
q.lint_unused_names=q.lint_unused_names or{}q.lint_unused_names[T]=j[-1]or 0;_=true until true;if not _ then break end end;return k.assign(q,j)end},{__index=k})end,__base=p,__name="LinterBlock",__parent=y},{__index=function(v,b)
local g=rawget(p,b)
if g==nil then local k=rawget(v,"__parent")if k then return k[b]end else return g end end,__call=function(v,...)
local b=setmetatable({},p)v.__init(b,...)return b end})p.__class=w;if y.__inherited then y.__inherited(y,w)end;l=w end;local u
u=function(w,y,p)if not(next(w))then return end;local v,b;do
local k=i("moonscript.util")v,b=k.pos_to_line,k.get_line end;local g
do local k={}local q=1
for j=1,#w
do local x=w[j]local z,_;z,_=x[1],x[2]
if _ then local E=v(y,_)z="line "..
tostring(E)..": "..tostring(z)local T="> "..b(y,E)
local A=math.max(#z,#T)
k[q]=table.concat({z,("="):rep(A),T},"\n")else k[q]=z end;q=q+1 end;g=k end;if p then table.insert(g,1,p)end
return table.concat(g,"\n\n")end;local c
do local w
c=function(y)if not(w)then w={}
pcall(function()w=i("lint_config")end)end
if not(w.whitelist_globals)then return d end;local p={}
for v,b in pairs(w.whitelist_globals)do if y:match(v)then
for g=1,#b do local k=b[g]n(p,k)end end end;return setmetatable(s(p),{__index=d})end end;local m
m=function(w,y,p)if y==nil then y="string input"end
local v=i("moonscript.parse")local b,g=v.string(w)if not(b)then return nil,g end;local k=l(p)k:stms(b)
k:lint_check_unused()return u(k.lint_errors,w,y)end;local f
f=function(w)local y,p=io.open(w)if not(y)then return nil,p end;return
m(y:read("*a"),w,c(w))end;return{lint_code=m,lint_file=f}end
a["moonscript.cmd.coverage"]=function(...)local n
n=function(l)if l==nil then l=""end;return
io.stderr:write(l.."\n")end;local s
s=function()return
setmetatable({},{__index=function(l,u)do
local c=setmetatable({},{__index=function(l)return 0 end})l[u]=c;return c end end})end;local h
h=function(l,u)local c={}local m=0;local f=1
for w in l:gmatch(".")do
do local y=rawget(u,m)if y then c[f]=y end end;if w=="\n"then f=f+1 end;m=m+1 end;return c end;local r
r=function(l,u)l=l:gsub("^@","")local c=assert(io.open(l))
local m=c:read("*a")c:close()local f=h(m,u)
n("------| @"..tostring(l))local w=1
for y in(m.."\n"):gmatch("(.-)\n")do
local p=("% 5d"):format(w)local v=f[w]and"*"or" "n(tostring(v)..
tostring(p).."| "..tostring(y))w=w+1 end;return n()end;local d
do local l
local u={reset=function(c)c.line_counts=s()end,start=function(c)return
debug.sethook((function()local m=c;local f=m.process_line;return function(...)return
f(m,...)end end)(),"l")end,stop=function(c)return
debug.sethook()end,print_results=function(c)return c:format_results()end,process_line=function(c,m,f)
local w=debug.getinfo(2,"S")local y=w.source;local p,v=y,f
c.line_counts[p][v]=c.line_counts[p][v]+1 end,format_results=function(c)
local m=i("moonscript.line_tables")local f=s()
for w,y in pairs(c.line_counts)do local p=false
repeat local v=m[w]if not(v)then p=true;break end
for b,g in
pairs(y)do local k=false;repeat local q=v[b]if not(q)then k=true;break end;local j,x=w,q
f[j][x]=f[j][x]+g;k=true until true;if not k then break end end;p=true until true;if not p then break end end;for w,y in pairs(f)do r(w,y)end end}u.__index=u
l=setmetatable({__init=function(c)return c:reset()end,__base=u,__name="CodeCoverage"},{__index=u,__call=function(c,...)
local m=setmetatable({},u)c.__init(m,...)return m end})u.__class=l;d=l end;return{CodeCoverage=d}end
a["moonscript.cmd.args"]=function(...)local n;n=i("moonscript.util").unpack
local s
s=function(r)local d,l;if type(r)=="table"then d,l=n(r),r else d,l=r,{}end
assert("no flags for arguments")local u={}
for c in d:gmatch("%w:?")do if c:match(":$")then u[c:sub(1,1)]={value=true}else
u[c]={}end end;return u end;local h
h=function(r,d)r=s(r)local l={}local u={}local c=nil
for m=1,#d do local f=false
repeat local w=d[m]local y={}
if c then l[c]=w;f=true;break end
do local p=w:match("-(%w+)")if p then
do local v=r[p]if v then l[v]=true else
for b in p:gmatch(".")do l[b]=true end end end;f=true;break end end;table.insert(u,w)f=true until true;if not f then break end end;return l,u end;return{parse_arguments=h,parse_spec=s}end
a["moonscript.base"]=function(...)local n=i("moonscript.compile")
local s=i("moonscript.parse")local h,r,d;do local z=table;h,r,d=z.concat,z.insert,z.remove end
local l,u,c,m;do local z=i("moonscript.util")
l,u,c,m=z.split,z.dump,z.get_options,z.unpack end
local f={loadstring=loadstring,load=load}local w,y,p,v,b,g,k,q,j,x;w="/"y=i("moonscript.line_tables")
p=function(z)local _
do local E={}local T=1
local A=l(z,";")
for O=1,#A do local I=false
repeat local N=A[O]local S=N:match("^(.-)%.lua$")
if not(S)then I=true;break end;local H=S..".moon"E[T]=H;T=T+1;I=true until true;if not I then break end end;_=E end;return h(_,";")end
v=function(z,_)if _==nil then _={}end;if"string"~=type(z)then local N=type(z)return nil,
"expecting string (got "..N..")"end
local E,T=s.string(z)if not E then return nil,T end;local A,O,I=n.tree(E,_)if not A then
return nil,n.format_error(O,I,z)end;return A,O end
b=function(z)local _=z:gsub("%.",w)local E,T
for A in package.moonpath:gmatch("[^;]+")do
T=A:gsub("?",_)E=io.open(T)if E then break end end
if E then local A=E:read("*a")E:close()
local O,I=g(A,"@"..tostring(T))if not O then error(T..": "..I)end;return O end;return nil,"Could not find moon file"end
g=function(...)local z,_,E,T,A=c(...)E=E or"=(moonscript.loadstring)"local O,I=v(_,z)if not
(O)then return nil,I end;if E then y[E]=I end;return
(f.load or f.loadstring)(O,E,m({T,A}))end
k=function(z,...)local _,E=io.open(z)if not(_)then return nil,E end
local T=assert(_:read("*a"))_:close()return g(T,"@"..tostring(z),...)end
q=function(...)local z=assert(k(...))return z()end
j=function(z)if z==nil then z=2 end;if not package.moonpath then
package.moonpath=p(package.path)end
local _=package.loaders or package.searchers;for E=1,#_ do local T=_[E]if T==b then return false end end
r(_,z,b)return true end
x=function()local z=package.loaders or package.searchers;for _,E in ipairs(z)do if E==b then
d(z,_)return true end end;return false end;return
{_NAME="moonscript",insert_loader=j,remove_loader=x,to_lua=v,moon_loader=b,dirsep=w,dofile=q,loadfile=k,loadstring=g,create_moonpath=p}end
a["moon"]=function(...)local n={debug=debug,type=type}local s,h,r;do
local q=i("moonscript.util")s,h,r=q.getfenv,q.setfenv,q.dump end
local d,l,u,c,m,f,w,y,p,v,b,g,k;d=function(...)return print(r(...))end
l=function(q)return
n.type(q)=="table"and q.__class end
u=function(q)local j=n.type(q)
if j=="table"then local x=q.__class;if x then return x end end;return j end
c=setmetatable({upvalue=function(q,j,x)local z={}local _=1;while true do local E=n.debug.getupvalue(q,_)
if E==nil then break end;z[E]=_;_=_+1 end;if not z[j]then
error(
"Failed to find upvalue: "..tostring(j))end
if not x then
local E,T=n.debug.getupvalue(q,z[j])return T else return n.debug.setupvalue(q,z[j],x)end end},{__index=n.debug})
m=function(q,j,...)local x=s(q)
local z=setmetatable({},{__index=function(_,E)local T=j[E]if T~=nil then return T else return x[E]end end})h(q,z)return q(...)end
f=function(q)
return
setmetatable({},{__index=function(j,x)local z=q[x]if z and n.type(z)=="function"then local _
_=function(...)return z(q,...)end;j[x]=_;return _ else return z end end})end
w=function(q,j)if not j then j=q;q={}end;return
setmetatable(q,{__index=function(x,z)local _=j(x,z)rawset(x,z,_)return _ end})end
y=function(...)local q={...}if#q<2 then return end;for j=1,#q-1 do local x=q[j]local z=q[j+1]
setmetatable(x,{__index=z})end;return q[1]end
p=function(q)local j={}for x,z in pairs(q)do j[x]=z end;return j end
v=function(q,j,...)
for x,z in pairs(j.__base)do if not x:match("^__")then q[x]=z end end;return j.__init(q,...)end
b=function(q,j,x)
for z=1,#x do local _=x[z]q[_]=function(E,...)return j[_](j,...)end end end
g=function(q,j,x)
if x then for z=1,#x do local _=x[z]q[_]=j[_]end else for z,_ in pairs(j)do q[z]=_ end end end
k=function(q,j)local x=#q
if x>1 then local z=j(q[1],q[2])for _=3,x do z=j(z,q[_])end;return z else return q[1]end end;return
{dump=r,p=d,is_object=l,type=u,debug=c,run_with_scope=m,bind_methods=f,defaultbl=w,extend=y,copy=p,mixin=v,mixin_object=b,mixin_table=g,fold=k}end
a["moon.all"]=function(...)local n=i("moon")for s,h in pairs(n)do _G[s]=h end;return n end
a["cc.lpeg"]=function(...)local n,o,s,h,r=_ENV or _G,{},{},true,i
local function i(...)local d=...if o[d]then return o[d]elseif s[d]then
o[d]=s[d](d)return o[d]else return r(d)end end
do local n=n
s['API']=function(...)
local d,l,c,m,f,w,i,y,p,v,b=assert,error,ipairs,pairs,pcall,print,i,select,tonumber,tostring,type;local g,k=i"table",i"util"local n=k.noglobals()local q=g.concat
local j,x,z,_,E,T,A,O,I=k.checkstring,k.copy,k.fold,k.load,k.map_fold,k.map_foldr,k.setify,k.pack,k.unpack;local function N(u,S)
l("Character at position "..u+1 .." is not a valid "..S.." one.",2)end
return
function(u,S)local H=u.charset
local R,D=u.constructors,S.ispattern;local L,U,C=R.constant.truept,R.constant.falsept,R.constant.Cppt
local M,F=H.split_int,H.validate;local W,Y,P,V=u.Range,u.set.new,u.set.union,u.set.tostring;local B,G,K,Q;local function J(ew)return
R.aux("char",ew)end
local function X(...)local ew,ey=(...),y('#',...)if ey==0 then
l"bad argument #1 to 'P' (value expected)"end;local ep=b(ew)
if D(ew)then return ew elseif ep=="function"then
return S.Cmt("",ew)elseif ep=="string"then local ev,eb=F(ew)if not ev then N(eb,H.name)end
if ew==""then return L end;return T(M(ew),J,u.sequence)elseif ep=="table"then local ev=x(ew)if ev[1]==nil then
l("grammar has no initial rule")end
if not D(ev[1])then ev[1]=S.V(ev[1])end;return R.none("grammar",ev)elseif ep=="boolean"then return ew and L or U elseif
ep=="number"then
if ew==0 then return L elseif ew>0 then return R.aux("any",ew)else return-R.aux("any",-ew)end else
l("bad argument #1 to 'P' (lpeg-pattern expected, got "..ep..")")end end;S.P=X
local function Z(ew)if ew==""then return U else local ey;ew=j(ew,"S")
return R.aux("set",Y(M(ew)),ew)end end;S.S=Z
local function ee(...)
if y('#',...)==0 then return X(false)else local ew=W(1,0)
for ey,ep in c{...}do ep=j(ep,"R")
d(#ep==2,"bad argument #1 to 'R' (range must have two characters)")ew=P(ew,W(I(M(ep))))end;return R.aux("set",ew)end end;S.R=ee
local function et(ew)d(ew~=nil)return R.aux("ref",ew)end;S.V=et
do local ew=A{"set","range","one","char"}
local ey=A{"true","false","lookahead","unm"}
local ep=A{"Carg","Cb","C","Cf","Cg","Cs","Ct","/zero","Clb","Cmt","Cc","Cp","div_string","div_number","div_table","div_function","at least","at most","behind"}
local function ev(eb,eg,ek)local eq=eb.pkind
if ep[eq]then return false elseif ew[eq]then return 1 elseif ey[eq]then return 0 elseif eq=="string"then return#eb.as_is elseif eq==
"any"then return eb.aux elseif eq=="choice"then
local ej,ex=ev(eb[1],eg,ek),ev(eb[2],eg,ek)return(ej==ex)and ej elseif eq=="sequence"then
local ej,ex=ev(eb[1],eg,ek),ev(eb[2],eg,ek)return ej and ex and ej+ex elseif eq=="grammar"then if
eb.aux[1].pkind=="ref"then return ev(eb.aux[eb.aux[1].aux],eb.aux,{})else return
ev(eb.aux[1],eb.aux,{})end elseif
eq=="ref"then if ek[eb]then return false end;ek[eb]=true
return ev(eg[eb.aux],eg,ek)else w(eq,"is not handled by fixedlen()")end end
function S.B(eb)eb=X(eb)local eg=ev(eb)
d(eg,"A 'behind' pattern takes a fixed length pattern as argument.")if eg>=260 then
l("Subpattern too long in 'behind' pattern constructor.")end;return R.both("behind",eb,eg)end end
local function ea(ew,ey)return('%s:%s'):format(ew.id,ey.id)end
local function eo(ew,ey)local ep=ea(ew,ey)local ev=u.ptcache.choice[ep]
if not ev then ev=B(ew,ey)or
R.binary("choice",ew,ey)u.ptcache.choice[ep]=ev end;return ev end;function S.__add(ew,ey)return eo(X(ew),X(ey))end
local function ei(ew,ey)local ep=ea(ew,ey)
local ev=u.ptcache.sequence[ep]if not ev then ev=K(ew,ey)or R.binary("sequence",ew,ey)
u.ptcache.sequence[ep]=ev end;return ev end;u.sequence=ei;function S.__mul(ew,ey)return ei(X(ew),X(ey))end;local function en(ew)if
ew==L or
ew==U or ew.pkind=="unm"or ew.pkind=="lookahead"then return ew end
return R.subpt("lookahead",ew)end
S.__len=en;S.L=en
local function es(ew)return Q(ew)or R.subpt("unm",ew)end;S.__unm=es
local function eh(ew,ey)ew,ey=X(ew),X(ey)return es(ey)*ew end;S.__sub=eh
local function er(ew,ey)local ep;ep,ey=f(p,ey)
d(ep and b(ey)=="number","Invalid type encountered at right side of '^'.")return
R.both((ey<0 and"at most"or"at least"),ew,ey)end;S.__pow=er;for ew,ey in m{"C","Cs","Ct"}do
S[ey]=function(ep)ep=X(ep)return R.subpt(ey,ep)end end
S["Cb"]=function(ew)return R.aux("Cb",ew)end
S["Carg"]=function(ew)
d(b(ew)=="number","Number expected as parameter to Carg capture.")
d(0 <ew and ew<=200,"Argument out of bounds in Carg capture.")return R.aux("Carg",ew)end;local function ed()return C end;S.Cp=ed
local function el(...)return R.none("Cc",O(...))end;S.Cc=el
for ew,ey in m{"Cf","Cmt"}do
local ep="Function expected in "..ey.." capture"
S[ey]=function(ev,eb)d(b(eb)=="function",ep)ev=X(ev)
return R.both(ey,ev,eb)end end;local function eu(ew,ey)ew=X(ew)
if ey~=nil then return R.both("Clb",ew,ey)else return R.subpt("Cg",ew)end end;S.Cg=eu
local ec=A{"string","number","table","function"}
local function em(ew,ey)
if D(ey)then l"The right side of a '/' capture cannot be a pattern."elseif
not ec[b(ey)]then
l("The right side of a '/' capture must be of type ".."string, number, table or function.")end;local ep;if ey==0 then ep="/zero"else ep="div_"..b(ey)end;return
R.both(ep,ew,ey)end;S.__div=em;if u.proxymt then
for ew,ey in m(S)do if ew:match"^__"then u.proxymt[ew]=ey end end else S.__index=S end
local ef=u.factorizer(u,S)B,G,K,Q=ef.choice,ef.lookahead,ef.sequence,ef.unm end end end
do local n=n
s['analyzer']=function(...)local d=i"util"local l,u=d.nop,d.weakkey;local c,m,f=u{},u{},u{}return
{hasV=l,hasCmt=l,length=l,hasCapture=l}end end
do local n=n
s['charsets']=function(...)local d,l,c=i"string",i"table",i"util"local n=c.noglobals()
local m=c.copy;local f,w,y,p,v=d.char,d.sub,d.byte,l.concat,l.insert
local function b(u)
if u<128 then return 0,u elseif u<192 then
error("Byte values between 0x80 to 0xBF cannot start a multibyte sequence")elseif u<224 then return 1,u-192 elseif u<240 then return 2,u-224 elseif u<248 then return 3,u-240 elseif u<252 then return 4,u-248 elseif u<254 then return 5,
u-252 else
error("Byte values between 0xFE and OxFF cannot start a multibyte sequence")end end
local function g(u,C,M)C=C or 1;M=M or#u;local F,W=0
for Y=C,M do local P=y(u,Y)
if F==0 then W=Y;success,F=pcall(b,P)if not success then return
false,W-1 end else if not(127 <P and P<192)then
return false,W-1 end;F=F-1 end end;if F~=0 then return nil,W-1 end;return true,M end
local function k(u,C)C=C and C+1 or 1;if C>#u then return end;local M=y(u,C)local F,W=b(M)for C=C+1,C+F do
M=y(u,C)W=W*64+ (M-128)end;return C+F,C,W end;local function q(u,C)C=C and C+1 or 1;if C>#u then return end;local M=b(y(u,C))
return C+M,C,w(u,C,C+M)end;local function j(u)local C={}
for M,M,F in k,u do v(C,F)end;return C end
local function x(u)local C={}for M,M,F in q,u do v(C,F)end;return C end
local function z(u,C)if C>#u then return end;local M=y(u,C)local F,W=b(M)for C=C+1,C+F do M=y(u,C)
W=W*64+ (M-128)end;return W,C+F+1 end
local function _(u)if not u then return end;return
function(C)local M={}local F,W=true;while F do F,W=u(C,W)M[#M]=F end;return M end end
local function E(u)if not u then return end;return
function(C)local M={}for F=1,#C do v(M,u(C[F]))end;return p(M)end end
local function T(u,C)local M,F,W,Y,P,V=y(u,C)
if M<128 then return M,C+1 elseif M<192 then
error("Byte values between 0x80 to 0xBF cannot start a multibyte sequence")elseif M<224 then return(M-192)*64+y(u,C+1),C+2 elseif M<240 then
P,V=y(u,C+1,C+2)return(M-224)*4096+P%64*64+V%64,C+3 elseif M<248 then Y,P,V=y(u,
C+1,C+2,1+3)return(M-240)*262144+Y%64*4096+
P%64*64+V%64,C+4 elseif M<252 then W,Y,P,V=y(u,C+1,
C+2,1+3,C+4)return

(M-248)*16777216+W%64*262144+Y%64*4096+P%64*64+V%64,C+5 elseif M<254 then
F,W,Y,P,V=y(u,C+1,C+2,1+3,C+4,C+5)
return

(M-252)*1073741824+F%64*16777216+W%64*262144+Y%64*4096+P%64*64+V%64,C+6 else
error("Byte values between 0xFE and OxFF cannot start a multibyte sequence")end end
local function A(u,C)if C>#u then return end;local M=b(y(u,C))return w(u,C,C+M),C+M+1 end
local function O(u)
if u<128 then return f(u)elseif u<2048 then return f(192+u/64,128+u%64)elseif u<55296 or 57343 <u and u<
65536 then return
f(224+u/4096,128+u/64%64,128+u%64)elseif u<2097152 then return f(240+u/262144,128+u/4096%64,128+u/64%64,
128+u%64)elseif u<67108864 then return
f(248+u/
16777216,128+u/262144%64,128+u/4096%64,128+u/64%64,128+u%64)elseif u<2147483648 then
return f(252+u/1073741824,128+u/
16777216%64,128+u/262144%64,128+u/4096%64,128+u/64%64,
128+u%64)end
error("Bad Unicode code point: "..u..".")end;local function I(u,C,M)C=C or 1;M=M or#u;return true,M end
local function N(u,C)
C=C and C+1 or 1;if C>=#u then return end;return C,C,w(u,C,C)end
local function S(u,C)C=C and C+1 or 1;if C>#u then return end;return C,C,y(u,C)end
local function H(u)local C={}for M=1,#u do v(C,y(u,M))end;return C end
local function R(u)local C={}for M=1,#u do v(C,w(u,M,M))end;return C end;local function D(u,C)return y(u,C),C+1 end
local function L(u,C)return w(u,C,C),C+1 end
local U={binary={name="binary",binary=true,validate=I,split_char=R,split_int=H,next_char=S,next_int=N,get_char=L,get_int=D,tochar=f},["UTF-8"]={name="UTF-8",validate=g,split_char=x,split_int=j,next_char=q,next_int=k,get_char=A,get_int=z}}
return function(u)local C=u.options.charset or"binary"
if U[C]then u.charset=m(U[C])
u.binary_split_int=H else error("NYI: custom charsets")end end end end
do local n=n
s['compat']=function(...)local d,l,u;d,l=pcall(i,"debug")d,u=pcall(i,"jit")
u=d and u
local c={debug=l,lua51=(_VERSION=="Lua 5.1")and not u,lua52=_VERSION=="Lua 5.2",luajit=u and true or false,jit=
u and u.status(),lua52_len=not
#setmetatable({},{__len=function()end}),proxies=pcall(function()local m=newproxy(true)local f=newproxy(m)
assert(
type(getmetatable(m))=="table"and
(getmetatable(m))== (getmetatable(f)))end),_goto=
not not(loadstring or load)"::R::"}return c end end
do local n=n
s['compiler']=function(...)
local d,l,c,m,f,w,y,p,v=assert,error,pairs,print,rawset,select,setmetatable,tostring,type;local b,g,k=i"string",i"table",i"util"local n=k.noglobals()
local q,j,x,z,_,E=b.byte,b.sub,g.concat,g.insert,g.remove,k.unpack;local T,A,O,I=k.load,k.map,k.map_all,k.pack;local N=k.expose
return
function(u,S)
local H,R=S.evaluate,S.ispattern;local D=u.charset;local L={}
local function U(ea,eo)
if not R(ea)then l("pattern expected")end;local ei=ea.pkind
if ei=="grammar"then eo={}elseif
ei=="ref"or ei=="choice"or ei=="sequence"then if not eo[ea]then eo[ea]=L[ei](ea,eo)end;return eo[ea]end
if not ea.compiled then ea.compiled=L[ea.pkind](ea,eo)end;return ea.compiled end;S.compile=U;local function C(ea,eo)for ei=eo,#ea do ea[ei]=nil end end
local M,F,W=S.compile,S.evaluate,S.P
local function Y(ea,eo)
if ea==0 or ea==1 or ea==nil then return 1 elseif v(ea)~="number"then
l"number or nil expected for the stating index"elseif ea>0 then return ea>eo and eo+1 or ea else return
eo+ea<0 and 1 or eo+ea+1 end end
local function P()return{kind={},bounds={},openclose={},aux={}}end
local function V(ea,eo,ei,en,...)if ea then m("@!!! Match !!!@",eo)end;eo=W(eo)
d(v(ei)=="string","string expected for the match subject")en=Y(en,#ei)if ea then m(("-"):rep(30))m(eo.pkind)
S.pprint(eo)end;local es=U(eo,{})local eh=P()
local er={grammars={},args={n=w('#',...),...},tags={}}local ed,el,eu=es(ei,en,eh,1,er)if ea then
m("!!! Done Matching !!! success: ",ed,"final position",el,"final cap index",eu,"#caps",#
eh.openclose)end
if ed then
C(eh.kind,eu)C(eh.aux,eu)if ea then m("trimmed cap index = ",#eh+1)
S.cprint(eh,ei,1)end;local ec,em,ef=F(eh,ei,1,1)if ea then
m("#values",ef)N(ec)end;if ef==0 then return el else return E(ec,1,ef)end else if ea then
m("Failed")end;return nil end end;function S.match(...)return V(false,...)end
function S.dmatch(...)return V(true,...)end
for ea,eo in
c{"C","Cf","Cg","Cs","Ct","Clb","div_string","div_table","div_number","div_function"}do
L[eo]=T(([=[
    local compile, expose, type, LL = ...
    return function (pt, ccache)
        local matcher, this_aux = compile(pt.pattern, ccache), pt.aux
        return function (sbj, si, caps, ci, state)
            local ref_ci = ci
            local kind, bounds, openclose, aux
                = caps.kind, caps.bounds, caps.openclose, caps.aux
            kind      [ci] = "XXXX"
            bounds    [ci] = si
            openclose [ci] = 0
            caps.aux       [ci] = (this_aux or false)
            local success
            success, si, ci
                = matcher(sbj, si, caps, ci + 1, state)
            if success then
                if ci == ref_ci + 1 then
                    caps.openclose[ref_ci] = si
                else
                    kind      [ci] = "XXXX"
                    bounds    [ci] = si
                    openclose [ci] = ref_ci - ci
                    aux       [ci] = this_aux or false
                    ci = ci + 1
                end
            else
                ci = ci - 1
            end
            return success, si, ci
        end
    end]=]):gsub("XXXX",eo),
eo.." compiler")(U,N,v,S)end
L["Carg"]=function(ea,eo)local ei=ea.aux
return
function(en,es,eh,er,ed)if ed.args.n<ei then
l("reference to absent argument #"..ei)end;eh.kind[er]="value"
eh.bounds[er]=es
if ed.args[ei]==nil then eh.openclose[er]=1/0;eh.aux[er]=1/0 else
eh.openclose[er]=es;eh.aux[er]=ed.args[ei]end;return true,es,er+1 end end
for ea,eo in c{"Cb","Cc","Cp"}do
L[eo]=T(([=[
    return function (pt, ccache)
        local this_aux = pt.aux
        return function (sbj, si, caps, ci, state)
            caps.kind      [ci] = "XXXX"
            caps.bounds    [ci] = si
            caps.openclose [ci] = si
            caps.aux       [ci] = this_aux or false
            return true, si, ci + 1
        end
    end]=]):gsub("XXXX",eo),
eo.." compiler")(N)end
L["/zero"]=function(ea,eo)local ei=U(ea.pattern,eo)
return function(en,es,eh,er,ed)local el,eu=ei(en,es,eh,er,ed)
C(eh.aux,er)return el,eu,er end end;local function B(ea,...)return ea,I(...)end
L["Cmt"]=function(ea,eo)
local ei,en=U(ea.pattern,eo),ea.aux
return
function(es,eh,er,ed,el)local eu,ec,em=ei(es,eh,er,ed,el)
if not eu then C(er.aux,ed)return false,eh,ed end;local ef,ew;if em==ed then ef,ew=B(en(es,ec,j(es,eh,ec-1)))else
C(er.aux,em)C(er.kind,em)local ey,ep,ev=H(er,es,ed)
ef,ew=B(en(es,ec,E(ey,1,ev)))end;if not ef then return false,
eh,ed end;if ef==true then ef=ec end
if
v(ef)=="number"and eh<=ef and ef<=#es+1 then
local ey,ep,ev,eb=er.kind,er.bounds,er.openclose,er.aux
for eg=1,ew.n do ey[ed]="value"ep[ed]=eh
if ew[eg]==nil then er.openclose[ed]=1/0;er.aux[ed]=
1/0 else er.openclose[ed]=ef;er.aux[ed]=ew[eg]end;ed=ed+1 end elseif v(ef)=="number"then l"Index out of bounds returned by match-time capture."else
l(
"Match time capture must return a number, a boolean or nil".." as first argument, or nothing at all.")end;return true,ef,ed end end
L["string"]=function(ea,eo)local ei=ea.aux;local en=#ei
return
function(es,eh,er,ed,el)local eu=eh-1;for ec=1,en do local em;em=q(es,eu+ec)if
em~=ei[ec]then return false,eh,ed end end;return
true,eh+en,ed end end
L["char"]=function(ea,eo)
return
T(([=[
        local s_byte, s_char = ...
        return function(sbj, si, caps, ci, state)
            local c, nsi = s_byte(sbj, si), si + 1
            if c ~= __C0__ then
                return false, si, ci
            end
            return true, nsi, ci
        end]=]):gsub("__C0__",p(ea.aux)))(q,("").char)end;local function G(ea,eo,ei,en,es)return true,eo,en end
L["true"]=function(ea)return G end;local function K(ea,eo,ei,en,es)return false,eo,en end
L["false"]=function(ea)return K end;local function Q(ea,eo,ei,en,es)return eo>#ea,eo,en end
L["eos"]=function(ea)return Q end;local function J(ea,eo,ei,en,es)local eh,er=q(ea,eo),eo+1
if eh then return true,eo+1,en else return false,eo,en end end
L["one"]=function(ea)return J end
L["any"]=function(ea)local eo=ea.aux
if eo==1 then return J else eo=ea.aux-1;return
function(ei,en,es,eh,er)local ed=en+eo;if ed<=#ei then
return true,ed+1,eh else return false,en,eh end end end end
do local function ea(eo)
for ei,en in c(eo.aux)do if not R(en)then
l(("rule 'A' is not a pattern"):gsub("A",p(ei)))end end end
L["grammar"]=function(eo,ei)
ea(eo)local en=O(eo.aux,U,ei)local es=en[1]return
function(eh,er,ed,el,eu)z(eu.grammars,en)
local ec,em,el=es(eh,er,ed,el,eu)_(eu.grammars)return ec,em,el end end end;local X={kind={},bounds={},openclose={},aux={}}
L["behind"]=function(ea,eo)
local ei,en=U(ea.pattern,eo),ea.aux
return function(es,eh,er,ed,el)if eh<=en then return false,eh,ed end;local eu=ei(es,eh-en,X,ed,el)
X.aux={}return eu,eh,ed end end
L["range"]=function(ea)local eo=ea.aux
return
function(ei,en,es,eh,er)local ed,el=q(ei,en),en+1;for eu=1,#eo do local ec=eo[eu]if ed and ec[ed]then
return true,el,eh end end;return false,en,eh end end
L["set"]=function(ea)local b=ea.aux
return function(eo,ei,en,es,eh)local er,ed=q(eo,ei),ei+1
if b[er]then return true,ed,es else return false,ei,es end end end;L["range"]=L.set
L["ref"]=function(ea,eo)local ei=ea.aux;local en
return
function(es,eh,er,ed,el)
if not en then
if#el.grammars==0 then
l(("rule 'XXXX' used outside a grammar"):gsub("XXXX",p(ei)))elseif not el.grammars[#el.grammars][ei]then
l(("rule 'XXXX' undefined in given grammar"):gsub("XXXX",p(ei)))end;en=el.grammars[#el.grammars][ei]end;local eu,ec,em=en(es,eh,er,ed,el)return eu,ec,em end end
local Z=[=[
            success, si, ci = XXXX(sbj, si, caps, ci, state)
            if success then
                return true, si, ci
            else
            end]=]
local function ee(ea,eo,ei)if eo[2].pkind==ea then return U(eo[1],ei),ee(ea,eo[2],ei)else return U(eo[1],ei),
U(eo[2],ei)end end
L["choice"]=function(ea,eo)local ei={ee("choice",ea,eo)}local en,es={},{}
for er=1,#ei do
local ed="ch"..er;en[#en+1]=ed;es[#en]=Z:gsub("XXXX",ed)end;en[#en+1]="clear_captures"ei[#en]=C
local eh=x{"local ",x(en,", "),[=[ = ...
        return function (sbj, si, caps, ci, state)
            local aux, success = caps.aux, false
            ]=],x(es,"\n"),[=[--
            return false, si, ci
        end]=]}return T(eh,"Choice")(E(ei))end
local et=[=[
            success, si, ci = XXXX(sbj, si, caps, ci, state)
            if not success then
                return false, ref_si, ref_ci
            end]=]
L["sequence"]=function(ea,eo)local ei={ee("sequence",ea,eo)}local en,es={},{}
for er=1,#ei do
local ed="seq"..er;en[#en+1]=ed;es[#en]=et:gsub("XXXX",ed)end;en[#en+1]="clear_captures"ei[#en]=C
local eh=x{"local ",x(en,", "),[=[ = ...
        return function (sbj, si, caps, ci, state)
            local ref_si, ref_ci, success = si, ci
            ]=],x(es,"\n"),[=[
            return true, si, ci
        end]=]}return T(eh,"Sequence")(E(ei))end
L["at most"]=function(ea,eo)local ei,en=U(ea.pattern,eo),ea.aux;en=-en;return
function(es,eh,er,ed,el)local eu=true;for ec=1,en do
eu,eh,ed=ei(es,eh,er,ed,el)if not eu then break end end;return true,eh,ed end end
L["at least"]=function(ea,eo)local ei,en=U(ea.pattern,eo),ea.aux
if en==0 then
return
function(es,eh,er,ed,el)local eu,ec
while true do local em;eu,ec=eh,ed
em,eh,ed=ei(es,eh,er,ed,el)if not em then eh,ed=eu,ec;break end end;return true,eh,ed end elseif en==1 then
return
function(es,eh,er,ed,el)local eu,ec;local em=true;em,eh,ed=ei(es,eh,er,ed,el)
if not em then return false,eh,ed end;while true do local em;eu,ec=eh,ed;em,eh,ed=ei(es,eh,er,ed,el)
if not em then eh,ed=eu,ec;break end end;return true,eh,ed end else
return
function(es,eh,er,ed,el)local eu,ec;local em=true;for ef=1,en do em,eh,ed=ei(es,eh,er,ed,el)
if not em then return false,eh,ed end end
while true do local em;eu,ec=eh,ed
em,eh,ed=ei(es,eh,er,ed,el)if not em then eh,ed=eu,ec;break end end;return true,eh,ed end end end
L["unm"]=function(ea,eo)if ea.pkind=="any"and ea.aux==1 then return Q end
local ei=U(ea.pattern,eo)return
function(en,es,eh,er,ed)local el,eu,eu=ei(en,es,eh,er,ed)return not el,es,er end end
L["lookahead"]=function(ea,eo)local ei=U(ea.pattern,eo)
return function(en,es,eh,er,ed)local el,eu,eu=ei(en,es,eh,er,ed)return el,es,
er end end end end end
do local n=n
s['constructors']=function(...)local d,l,c,m,f=getmetatable,ipairs,newproxy,print,setmetatable
local w,y,p=i"table",i"util",i"compat"local v=w.concat;local b,g,k,q,j,x=y.copy,y.getuniqueid,y.id,y.map,y.weakkey,y.weakval
local n=y.noglobals()
local z={constant={"Cp","true","false"},aux={"string","any","char","range","set","ref","sequence","choice","Carg","Cb"},subpt={"unm","lookahead","C","Cf","Cg","Cs","Ct","/zero"},both={"behind","at least","at most","Clb","Cmt","div_string","div_number","div_table","div_function"},none="grammar","Cc"}
return
function(u,_)local E=u.set.tostring;local T,A;local O=1
if p.proxies and not p.lua52_len then local L=j{}
local U={__index=_}local C=c(true)A=d(C)u.proxymt=A
function A:__index(M)return L[self][M]end;function A:__newindex(M,F)L[self][M]=F end
function _.getdirect(M)return L[M]end
function T(M)local F=c(C)f(M,U)L[F]=M;F.id="__ptid"..O;O=O+1;return F end else if _.warnings and not p.lua52_len then
m("Warning: The `__len` metamethod won't work with patterns, "..
"use `LL.L(pattern)` for lookaheads.")end;A=_;function _.getdirect(L)return
L end
function T(L)L.id="__ptid"..O;O=O+1;return f(L,_)end end;u.newpattern=T;local function I(L)return d(L)==A end;_.ispattern=I;function _.type(L)if I(L)then
return"pattern"else return nil end end;local N,S
local function H()
N,S={},j{}u.ptcache=N;for L,U in l(z.aux)do N[U]=x{}end
for L,U in l(z.subpt)do N[U]=x{}end;for L,U in l(z.both)do N[U]={}end;return N end;_.resetptcache=H;H()local R={}u.constructors=R
R["constant"]={truept=T{pkind="true"},falsept=T{pkind="false"},Cppt=T{pkind="Cp"}}
local D={string=function(L,U)return U end,table=b,set=function(L,U)return E(L)end,range=function(L,U)return v(U,"|")end,sequence=function(L,U)return
v(q(g,L),"|")end}D.choice=D.sequence
R["aux"]=function(L,U,C)local M=N[L]local F=(D[L]or k)(U,C)
local W=M[F]if not W then W=T{pkind=L,aux=U,as_is=C}M[F]=W end
return W end
R["none"]=function(L,U)return T{pkind=L,aux=U}end
R["subpt"]=function(L,U)local C=N[L]local M=C[U.id]if not M then M=T{pkind=L,pattern=U}
C[U.id]=M end;return M end
R["both"]=function(L,U,C)local M=N[L][C]if not M then N[L][C]=x{}M=N[L][C]end
local F=M[U.id]
if not F then F=T{pkind=L,pattern=U,aux=C,cache=M}M[U.id]=F end;return F end
R["binary"]=function(L,U,C)return T{U,C,pkind=L}end end end end
do local n=n
s['datastructures']=function(...)local d,l,c,f=getmetatable,pairs,setmetatable,type
local w,y,p=i"math",i"table",i"util"local v=i"compat"local b;if v.luajit then b=i"ffi"end;local n=p.noglobals()
local g,k,q=p.extend,p.load,p.max;local j,x,z,_=w.max,y.concat,y.insert,y.sort;local E={}local T,A,O;local I={}local function N(u)
local m=c(k(x{"return{ [0]=false",(", false"):rep(u)," }"})(),I)return m end
if v.jit then local u,m={v={}}
function I.__index(Q,J)if
J==nil or J>Q.upper then return nil end;return Q.v[J]end;function I.__len(Q)return Q.upper end;function I.__newindex(Q,J,X)Q.v[J]=X end
m=b.metatype('struct { int upper; bool v[?]; }',I)
function T(y)if f(y)=="number"then local X=m(y+1)X.upper=y;return X end
local Q=q(y)u.upper=Q;if Q>255 then error"bool_set overflow"end;local J=m(Q+1)
J.upper=Q;for X=1,#y do J[y[X]]=true end;return J end
function A(Q)return f(Q)=="cdata"and b.istype(Q,m)end;O=A else function T(y)if f(y)=="number"then return N(y)end;local u=N(q(y))
for m=1,#y do u[y[m]]=true end;return u end
function A(u)return false end;function O(u)return d(u)==I end end
local function S(u,m)m=(u<=m)and m or-1;local Q=T(m)for J=u,m do Q[J]=true end;return Q end;local H,R={},{}
local function D(u,m)if f(u)=="number"then m[u]=true;return m else return u end end;local function L(u,m)H[u]=nil;R[m]=nil end
local function U(u,m)
local Q=j(f(u)=="number"and u or#u,
f(m)=="number"and m or#m)local J,X=D(u,H),D(m,R)local Z=T(Q)for ee=0,Q do
Z[ee]=J[ee]or X[ee]or false end;L(u,m)return Z end
local function C(u,m)local Q={}for J=0,255 do Q[J]=u[J]and not m[J]end;return Q end;local function M(u)local m={}
for Q=0,255 do m[#m+1]=(u[Q]==true)and Q or nil end;return x(m,", ")end
E.binary={set={new=T,union=U,difference=C,tostring=M},Range=S,isboolset=A,isbyteset=O,isset=O}local F={}
local function W(y)local u=c({},F)for m=1,#y do u[y[m]]=true end;return u end;local function Y(u,m)for Q in l(u)do m[Q]=true end;return m end
local function P(u,m)
u,m=
(f(u)=="number")and W{u}or u,(f(m)=="number")and W{m}or m;local Q=W{}Y(u,Q)Y(m,Q)return Q end
local function V(u,m)local Q={}u,m=(f(u)=="number")and W{u}or u,
(f(m)=="number")and W{m}or m;for J in l(u)do if u[J]and
not m[J]then Q[#Q+1]=J end end
return W(Q)end
local function B(u)local m={}for Q in l(u)do z(m,Q)end;_(m)return x(m,",")end;local function G(u)return(d(u)==F)end;local function K(u,m)local Q={}for J=u,m do Q[#Q+1]=J end
return W(Q)end
E.other={set={new=W,union=P,tostring=B,difference=V},Range=K,isboolset=A,isbyteset=O,isset=G,isrange=function(u)return false end}
return
function(u,m)
local Q=(u.options or{}).charset or"binary"
if f(Q)=="string"then
Q=(Q=="binary")and"binary"or"other"else Q=Q.binary and"binary"or"other"end;return g(u,E[Q])end end end
do local n=n
s['evaluator']=function(...)local d,l,c,m=select,tonumber,tostring,type
local f,w,y=i"string",i"table",i"util"local p,v=f.sub,w.concat;local b=y.unpack;local n=y.noglobals()
return
function(u,g)local k={}local function q(E,T,A,O,I)
local N,S=E.openclose,E.kind;while S[O]and N[O]>=0 do O,I=k[S[O]](E,T,A,O,I)end
return O,I end
function k.C(E,T,A,O,I)if
E.openclose[O]>0 then
A[I]=p(T,E.bounds[O],E.openclose[O]-1)return O+1,I+1 end;A[I]=false
local N,S=q(E,T,A,O+1,I+1)A[I]=p(T,E.bounds[O],E.bounds[N]-1)return N+1,S end
local function j(E,T,A)local O,I,N=E.aux,E.openclose,E.kind
repeat A=A-1;local S,H=O[A],I[A]if H<0 then A=A+H end;if H~=0 and
N[A]=="Clb"and T==S then return A end until A==1
T=m(T)=="string"and"'"..T.."'"or c(T)
error("back reference "..T.." not found")end
function k.Cb(E,T,A,O,I)local N=j(E,E.aux[O],O)N,I=k.Cg(E,T,A,N,I)return O+1,I end
function k.Cc(E,T,A,O,I)local N=E.aux[O]for S=1,N.n do I,A[I]=I+1,N[S]end;return O+1,I end;k["Cf"]=function()error("NYI: Cf")end
function k.Cf(E,T,A,O,I)if
E.openclose[O]>0 then error"No First Value"end
local N,S,H=E.aux[O],{}O=O+1;O,H=k[E.kind[O]](E,T,S,O,1)if H==1 then
error"No first value"end;local R=S[1]while E.kind[O]and E.openclose[O]>=0 do
O,H=k[E.kind[O]](E,T,S,O,1)R=N(R,b(S,1,H-1))end
A[I]=R;return O+1,I+1 end
function k.Cg(E,T,A,O,I)if E.openclose[O]>0 then
A[I]=p(T,E.bounds[O],E.openclose[O]-1)return O+1,I+1 end
local N,S=q(E,T,A,O+1,I)
if S==I then A[S]=p(T,E.bounds[O],E.bounds[N]-1)S=S+1 end;return N+1,S end
function k.Clb(E,T,A,O,I)local N=E.openclose;if N[O]>0 then return O+1,I end;local S=0;repeat if N[O]==0 then S=S+1 elseif N[O]<0 then
S=S-1 end;O=O+1 until S==0
return O,I end;function k.Cp(E,T,A,O,I)A[I]=E.bounds[O]return O+1,I+1 end
function k.Ct(E,T,A,O,I)
local N,S,H=E.aux,E.openclose,E.kind;local R={}A[I]=R;if S[O]>0 then return O+1,I+1 end;local D,L=1,{}O=O+1
while
H[O]and S[O]>=0 do if H[O]=="Clb"then local U,C=N[O],1;O,C=k.Cg(E,T,L,O,1)if C~=1 then R[U]=L[1]end else
O,D=k[H[O]](E,T,R,O,D)end end;return O+1,I+1 end;local x=1/0
function k.value(E,T,A,O,I)local N;if E.aux[O]~=x or E.openclose[O]~=x then
N=E.aux[O]end;A[I]=N;return O+1,I+1 end
function k.Cs(E,T,A,O,I)
if E.openclose[O]>0 then
A[I]=p(T,E.bounds[O],E.openclose[O]-1)else local N,S,H=E.bounds,E.kind,E.openclose;local R,D,L,U,C=N[O],{},{},1,1;local M;O=O+1;while H[O]>=0 do
M=N[O]D[U]=p(T,R,M-1)U=U+1;O,C=k[S[O]](E,T,L,O,1)
if C>1 then D[U]=L[1]U=U+1;R=H[
O-1]>0 and H[O-1]or N[O-1]else R=M end end;D[U]=p(T,R,
N[O]-1)A[I]=v(D)end;return O+1,I+1 end
local function z(E,T,...)local A=d('#',...)for O=1,A do T,E[T]=T+1,d(O,...)end;return T end
function k.div_function(E,T,A,O,I)local N=E.aux[O]local S,H;if E.openclose[O]>0 then S,H={p(T,E.bounds[O],
E.openclose[O]-1)},2 else S={}
O,H=q(E,T,S,O+1,1)end;O=O+1
I=z(A,I,N(b(S,1,H-1)))return O,I end
function k.div_number(E,T,A,O,I)local N=E.aux[O]local S,H;if E.openclose[O]>0 then
S,H={p(T,E.bounds[O],E.openclose[O]-1)},2 else S={}O,H=q(E,T,S,O+1,1)end;O=O+
1;if N>=H then
error("no capture '"..N.."' in /number capture.")end;A[I]=S[N]return O,I+1 end
local function _(E,T)local A=E.openclose;local O={open=E.bounds[T]}if A[T]>0 then O.close=A[T]
return T+1,O,0 end;local I=T;local N=1;T=T+1
repeat local S=A[T]
if N==1 and S>=0 then O[#O+1]=T end;if S==0 then N=N+1 elseif S<0 then N=N-1 end;T=T+1 until N==0;O.close=E.bounds[T-1]return T,O,#O end
function k.div_string(E,T,A,O,I)local N,S;local H;local H,R={},{}local D=E.aux[O]O,S,N=_(E,O)
A[I]=D:gsub("%%([%d%%])",function(L)
if L=="%"then return"%"end;L=l(L)
if not H[L]then if L>N then
error("no capture at index "..L.." in /string capture.")end
if L==0 then
H[L]=p(T,S.open,S.close-1)else local U,I=k[E.kind[S[L]]](E,T,R,S[L],1)if I==1 then
error(
"no values in capture at index"..L.." in /string capture.")end;H[L]=R[1]end end;return H[L]end)return O,I+1 end
function k.div_table(E,T,A,O,I)local N=E.aux[O]local S
if E.openclose[O]>0 then
S=p(T,E.bounds[O],E.openclose[O]-1)else local H,R={}O,R=q(E,T,H,O+1,1)S=H[1]end;O=O+1;if N[S]then A[I]=N[S]return O,I+1 else return O,I end end
function g.evaluate(E,T,A)local O={}local I,N=q(E,T,O,A,1)return O,1,N-1 end end end end
do local n=n
s['factorizer']=function(...)local d,l,c,m=ipairs,pairs,print,setmetatable;local f=i"util"
local w,y,p,v=f.id,f.nop,f.setify,f.weakkey;local n=f.noglobals()
local function b(u,x,z)local w,_=z.id,z.brk;if u==w then return true,x elseif x==w then return true,u elseif u==_ then return true,_ else return
false end end
local g=p{"unm","lookahead","C","Cf","Cg","Cs","Ct","/zero"}
local k=p{"behind","at least","at most","Clb","Cmt","div_string","div_number","div_table","div_function"}local q=p{"char","set","range"}local j
j=m({},{__mode="k",__index=function(u,x)local z,_=x.pkind,false
if z==
"Cmt"or z=="ref"then _=true elseif g[z]or k[z]then _=j[x.pattern]elseif z=="choice"or
z=="sequence"then _=j[x[1]]or j[x[2]]end;j[x]=_;return _ end})
return
function(u,x)
if u.options.factorize==false then return{choice=y,sequence=y,lookahead=y,unm=y}end;local z,_=u.constructors,x.P;local E,T=z.constant.truept,z.constant.falsept
local A=u.set.union;local O=p{"char","set"}
local I={["/zero"]="__div",["div_number"]="__div",["div_string"]="__div",["div_table"]="__div",["div_function"]="__div",["at least"]="__pow",["at most"]="__pow",["Clb"]="Cg"}
local function N(D,L)
do local M,F=b(D,L,{id=T,brk=E})if M then return F end end;local U,C=D.pkind,L.pkind
if D==L and not j[D]then return D elseif U=="choice"then local M,F={},1;while
D.pkind=="choice"do M[F],D,F=D[1],D[2],F+1 end;M[F]=D
for W=F,1,-1 do L=M[W]+L end;return L elseif O[U]and O[C]then return z.aux("set",A(D.aux,L.aux))elseif
O[U]and
C=="any"and L.aux==1 or O[C]and U=="any"and D.aux==1 then return U=="any"and D or L elseif U==C then
if(g[U]or k[U])and
(D.aux==L.aux)then
return x[I[U]or U](D.pattern+L.pattern,D.aux)elseif(U==C)and U=="sequence"then if D[1]==L[1]and not j[D[1]]then return D[1]*
(D[2]+L[2])end end end;return false end;local function S(D)return D end
local function H(D,L)
do local M,F=b(D,L,{id=E,brk=T})if M then return F end end;local U,C=D.pkind,L.pkind
if U=="sequence"then local M,F={},1;while D.pkind=="sequence"do
M[F],D,F=D[1],D[2],F+1 end;M[F]=D;for W=F,1,-1 do L=M[W]*L end;return L elseif
(U=="one"or U==
"any")and(C=="one"or C=="any")then return _(D.aux+L.aux)end;return false end
local function R(D)
if D==E then return T elseif D==T then return E elseif D.pkind=="unm"then return#D.pattern elseif D.pkind=="lookahead"then return
-D.pattern end end;return{choice=N,lookahead=S,sequence=H,unm=R}end end end
do local n=n
s['init']=function(...)local d,l,c=getmetatable,setmetatable,pcall;local m=i"util"
local f,w,y,p=m.copy,m.map,m.nop,m.unpack
local v,b,g,k,q,j,x,z,E,T=p(w(i,{"API","charsets","compiler","constructors","datastructures","evaluator","factorizer","locale","printers","re"}))local A,O=c(i,"package")local n=m.noglobals()local I="0.12"local N="0.1.0"local function S(u,_)
l(_,{__index=u})end
local function H(u,_)
c(function()O.loaded.lpeg=u;O.loaded.re=u.re end)if _ then _.lpeg,_.re=u,u.re end;return u end
local function R(u)u=u and f(u)or{}
local _,L={options=u,factorizer=x},{new=R,version=function()return I end,luversion=function()return N end,setmaxstack=y}L.util=m;L.global=S;L.register=H;b(_,L)q(_,L)E(_,L)k(_,L)v(_,L)j(_,L);(
u.compiler or g)(_,L)z(_,L)L.re=T(_,L)return L end;local D=R()return D end end
do local n=n
s['locale']=function(...)local d=i"util".extend;local n=i"util".noglobals()
return
function(l,u)
local c,m=u.R,u.S;local f={}f["cntrl"]=c"\0\31"+"\127"f["digit"]=c"09"
f["lower"]=c"az"f["print"]=c" ~"f["space"]=m" \f\n\r\t\v"f["upper"]=c"AZ"f["alpha"]=
f["lower"]+f["upper"]
f["alnum"]=f["alpha"]+f["digit"]f["graph"]=f["print"]-f["space"]f["punct"]=f["graph"]-
f["alnum"]
f["xdigit"]=f["digit"]+c"af"+c"AF"function u.locale(w)return d(w or{},f)end end end end;do local n=n;s['match']=function(...)end end;do local n=n;s['optimizer']=function(...)
end end
do local n=n
s['printers']=function(...)
return
function(d,l)
local c,m,f,w,y=ipairs,pairs,print,tostring,type;local p,v,b=i"string",i"table",i"util"local g=d.set.tostring
local n=b.noglobals()local k,q,j=p.char,p.sub,v.concat;local x,z,_=b.expose,b.load,b.map
local E={["\f"]="\\f",["\n"]="\\n",["\r"]="\\r",["\t"]="\\t",["\v"]="\\v",["\127"]="\\ESC"}local function T(u,L)
if L[2].pkind==u then return L[1],T(u,L[2])else return L[1],L[2]end end
for u=0,8 do E[k(u)]="\\"..u end;for u=14,31 do E[k(u)]="\\"..u end
local function A(u)return u:gsub("%c",E)end
local function O(u)return k(z("return "..g(u))())end;local I={}local function N(u,L,U)return I[u.pkind](u,L,U)end
function l.pprint(u)
local L=l.P(u)f"\nPrint pattern"N(L,"","")f"--- /pprint\n"return u end
for u,L in
m{string=[[ "P( \""..escape(pt.as_is).."\" )"       ]],char=[[ "P( \""..escape(to_char(pt.aux)).."\" )"]],["true"]=[[ "P( true )"                     ]],["false"]=[[ "P( false )"                    ]],eos=[[ "~EOS~"                         ]],one=[[ "P( one )"                      ]],any=[[ "P( "..pt.aux.." )"             ]],set=[[ "S( "..'"'..escape(set_repr(pt.aux))..'"'.." )" ]],["function"]=[[ "P( "..pt.aux.." )"             ]],ref=[[
        "V( ",
            (type(pt.aux) == "string" and "\""..pt.aux.."\"")
                          or tostring(pt.aux)
        , " )"
        ]],range=[[
        "R( ",
            escape(t_concat(map(
                pt.as_is,
                function(e) return '"'..e..'"' end)
            , ", "))
        ," )"
        ]]}do
I[u]=z(([==[
        local k, map, t_concat, to_char, escape, set_repr = ...
        return function (pt, offset, prefix)
            print(t_concat{offset,prefix,XXXX})
        end
    ]==]):gsub("XXXX",L),
u.." printer")(u,_,j,k,A,O)end
for u,L in
m{["behind"]=[[ LL_pprint(pt.pattern, offset, "B ") ]],["at least"]=[[ LL_pprint(pt.pattern, offset, pt.aux.." ^ ") ]],["at most"]=[[ LL_pprint(pt.pattern, offset, pt.aux.." ^ ") ]],unm=[[LL_pprint(pt.pattern, offset, "- ")]],lookahead=[[LL_pprint(pt.pattern, offset, "# ")]],choice=[[
        print(offset..prefix.."+")
        local ch, i = {}, 1
        while pt.pkind == "choice" do
            ch[i], pt, i = pt[1], pt[2], i + 1
        end
        ch[i] = pt
        map(ch, LL_pprint, offset.." :", "")
        ]],sequence=[=[
        print(offset..prefix.."*")
        local acc, p2 = {}
        offset = offset .. " |"
        while true do
            if pt.pkind ~= "sequence" then -- last element
                if pt.pkind == "char" then
                    acc[#acc + 1] = pt.aux
                    print(offset..'P( "'..s.char(u.unpack(acc))..'" )')
                else
                    if #acc ~= 0 then
                        print(offset..'P( "'..s.char(u.unpack(acc))..'" )')
                    end
                    LL_pprint(pt, offset, "")
                end
                break
            elseif pt[1].pkind == "char" then
                acc[#acc + 1] = pt[1].aux
            elseif #acc ~= 0 then
                print(offset..'P( "'..s.char(u.unpack(acc))..'" )')
                acc = {}
                LL_pprint(pt[1], offset, "")
            else
                LL_pprint(pt[1], offset, "")
            end
            pt = pt[2]
        end
        ]=],grammar=[[
        print(offset..prefix.."Grammar")
        for k, pt in pairs(pt.aux) do
            local prefix = ( type(k)~="string"
                             and tostring(k)
                             or "\""..k.."\"" )
            LL_pprint(pt, offset.."  ", prefix .. " = ")
        end
    ]]}do
I[u]=z(([[
        local map, LL_pprint, pkind, s, u, flatten = ...
        return function (pt, offset, prefix)
            XXXX
        end
    ]]):gsub("XXXX",L),
u.." printer")(_,N,y,p,b,T)end
for u,L in m{"C","Cs","Ct"}do I[L]=function(U,C,M)f(C..M..L)
N(U.pattern,C.."  ","")end end
for u,L in
m{"Cg","Clb","Cf","Cmt","div_number","/zero","div_function","div_table"}do
I[L]=function(U,C,M)
f(C..M..L.." "..w(U.aux or""))N(U.pattern,C.."  ","")end end
I["div_string"]=function(u,L,U)f(L..
U..'/string "'..w(u.aux or"")..'"')
N(u.pattern,L.."  ","")end;for u,L in m{"Carg","Cp"}do
I[L]=function(U,C,M)f(C..
M..L.."( "..w(U.aux).." )")end end
I["Cb"]=function(u,L,U)f(L..U..
"Cb( \""..u.aux.."\" )")end
I["Cc"]=function(u,L,U)f(L..
U.."Cc("..j(_(u.aux,w),", ").." )")end;local S={}local H="   "local function R(u)u=w(u)
u=u..".".. ((" "):rep(4-#u))return u end
local function D(u,L,U,C,M)local F,W=u.openclose,u.kind;U=U or 0
while W[L]and
F[L]>=0 do
if u.openclose[L]>0 then
f(j({R(M),H:rep(U),u.kind[L],": start = ",w(u.bounds[L])," finish = ",w(u.openclose[L]),
u.aux[L]and" aux = "or"",u.aux[L]and
(y(u.aux[L])=="string"and'"'..
w(u.aux[L])..'"'or w(u.aux[L]))or""," \t",q(C,u.bounds[L],
u.openclose[L]-1)}))if y(u.aux[L])=="table"then x(u.aux[L])end else
local W=u.kind[L]local Y=u.bounds[L]
f(j({R(M),H:rep(U),W,": start = ",Y,u.aux[L]and" aux = "or"",

u.aux[L]and(
y(u.aux[L])=="string"and'"'..w(u.aux[L])..'"'or w(u.aux[L]))or""}))L,M=D(u,L+1,U+1,C,M+1)
f(j({R(M),H:rep(U),"/",W," finish = ",w(u.bounds[L])," \t",q(C,Y,(
u.bounds[L]or 1)-1)}))end;M=M+1;L=L+1 end;return L,M end;function l.cprint(u,L,U)L=L or 1;f"\nCapture Printer:\n================"D(u,L,0,U,1)
f"================\n/Cprinter\n"end;return
{pprint=l.pprint,cprint=l.cprint}end end end
do local n=n
s['re']=function(...)
return
function(d,l)local u,c,f,w=tonumber,type,print,error;local y=setmetatable;local p=l;local v=p
local b=getmetatable(v.P(0))local g=_VERSION;if g=="Lua 5.2"then n=nil end;local k=p.P(1)
local q={nl=p.P"\n"}local j;local x;local z
local function _()v.locale(q)q.a=q.alpha;q.c=q.cntrl;q.d=q.digit;q.g=q.graph
q.l=q.lower;q.p=q.punct;q.s=q.space;q.u=q.upper;q.w=q.alnum;q.x=q.xdigit;q.A=k-q.a
q.C=k-q.c;q.D=k-q.d;q.G=k-q.g;q.L=k-q.l;q.P=k-q.p;q.S=k-q.s;q.U=k-q.u
q.W=k-q.w;q.X=k-q.x;j={}x={}z={}local b={__mode="v"}y(j,b)y(x,b)y(z,b)end;_()local function E(m,Z)local ee=Z and Z[m]
if not ee then w("undefined name: "..m)end;return ee end;local function T(m,Z)
local ee=
(#m<Z+20)and m:sub(Z)or m:sub(Z,Z+20).."..."
ee=("pattern error near '%s'"):format(ee)w(ee,2)end;local function A(m,Z)
local ee=v.P(true)while Z>=1 do if Z%2 >=1 then ee=ee*m end;m=m*m;Z=Z/2 end
return ee end;local function O(m,Z,ee)if c(ee)~="string"then
return nil end;local et=#ee+Z
if m:sub(Z,et-1)==ee then return et else return nil end end
local I=(q.space+"--"* (k-
q.nl)^0)^0
local N=p.R("AZ","az","__")*p.R("AZ","az","__","09")^0;local S=I*"<-"local H=p.P"/"+")"+"}"+":}"+"~}"+"|}"+ (N*
S)+-1
N=p.C(N)local R=N*p.Carg(1)local D=p.C(p.R"09"^1)*I/u;local L=
"'"*p.C((k-"'")^0)*"'"+
'"'*p.C((k-'"')^0)*'"'
local U="%"*R/
function(m,Z)local ee=
Z and Z[m]or q[m]if not ee then
w("name '"..m.."' undefined")end;return ee end
local C=p.Cs(k* (p.P"-"/"")* (k-"]"))/v.R;local M=U+C+p.C(k)
local F="["* (p.C(p.P"^"^-1))*p.Cf(M*
(M-"]")^0,b.__add)/function(m,Z)
return m=="^"and k-Z or Z end*"]"
local function W(m,Z,ee)if m[Z]then
w("'"..Z.."' already defined as a rule")else m[Z]=ee end;return m end;local function Y(m,Z)return W({m},m,Z)end
local function P(m,Z)if not Z then
w("rule '"..m.."' used outside a grammar")else return v.V(m)end end
local V=p.P{"Exp",Exp=I* (p.V"Grammar"+
p.Cf(p.V"Seq"* ("/"*I*p.V"Seq")^0,b.__add)),Seq=p.Cf(
p.Cc(p.P"")*p.V"Prefix"^0,b.__mul)* (p.L(H)+T),Prefix=

"&"*I*p.V"Prefix"/b.__len+"!"*I*p.V"Prefix"/b.__unm+p.V"Suffix",Suffix=p.Cf(p.V"Primary"*I*

(
(
p.P"+"*
p.Cc(1,b.__pow)+p.P"*"*p.Cc(0,b.__pow)+p.P"?"*
p.Cc(-1,b.__pow)+
"^"* (p.Cg(D*p.Cc(A))+
p.Cg(p.C(
p.S"+-"*p.R"09"^1)*p.Cc(b.__pow)))+
"->"*I*
(
p.Cg((L+D)*p.Cc(b.__div))+p.P"{}"*p.Cc(nil,p.Ct)+p.Cg(R/E*p.Cc(b.__div)))+"=>"*I*p.Cg(R/E*p.Cc(p.Cmt)))*I)^0,function(m,Z,ee)return
ee(m,Z)end),Primary=







"("*p.V"Exp"*")"+L/v.P+F+U+"{:"* (N*":"+
p.Cc(nil))*p.V"Exp"*":}"/function(m,Z)return
v.Cg(Z,m)end+"="*N/function(m)return v.Cmt(v.Cb(m),O)end+p.P"{}"/v.Cp+"{~"*p.V"Exp"*"~}"/v.Cs+"{|"*p.V"Exp"*"|}"/v.Ct+"{"*p.V"Exp"*"}"/v.C+p.P"."*p.Cc(k)+ (N*-S+"<"*N*">")*p.Cb("G")/P,Definition=
N*S*p.V"Exp",Grammar=
p.Cg(p.Cc(true),"G")*p.Cf(p.V"Definition"/Y*
p.Cg(p.V"Definition")^0,W)/v.P}
local B=I*p.Cg(p.Cc(false),"G")*V/v.P* (-k+T)
local function G(m,Z)if v.type(m)=="pattern"then return m end;local ee=B:match(m,1,Z)if
not ee then w("incorrect pattern",3)end;return ee end;local function K(m,Z,ee)local et=j[Z]if not et then et=G(Z)j[Z]=et end
return et:match(m,ee or 1)end
local function Q(m,Z,ee)local et=x[Z]if not et then
et=G(Z)/0
et=v.P{v.Cp()*et*v.Cp()+1*v.V(1)}x[Z]=et end
local ee,ea=et:match(m,ee or 1)if ee then return ee,ea-1 else return ee end end
local function J(m,Z,ee)local et=z[Z]or{}z[Z]=et;local ea=et[ee]if not ea then ea=G(Z)
ea=v.Cs((ea/ee+1)^0)et[ee]=ea end;return ea:match(m)end;local X={compile=G,match=K,find=Q,gsub=J,updatelocale=_}return X end end end
do local n=n
s['util']=function(...)
local d,l,u,c,f,w,y,p,v,b,g,k,q,j=getmetatable,setmetatable,load,loadstring,next,pairs,pcall,print,rawget,rawset,select,tostring,type,unpack;local x,z,_=i"math",i"string",i"table"
local E,T,A,O,I=x.max,z.match,z.gsub,_.concat,_.insert;local N=i"compat"local function S()end;local H,R,D
if y and not N.lua52 and not h then
local function m(en,es)error(
"illegal global read: "..k(es),2)end;local function eo(en,es,eh)
error("illegal global write: "..k(es)..": "..k(eh),2)end
local ei=l({},{__index=m,__newindex=eo})H=function()y(setfenv,3,ei)end
function R(en)return v(ei,en)end;function D(en,es)b(ei,en,es)end else H=S end;local n=H()local L={nop=S,noglobals=H,getglobal=R,setglobal=D}
L.unpack=_.unpack or j
L.pack=_.pack or function(...)return{n=g('#',...),...}end
if N.lua51 then local m=u
function L.load(eo,ei,en,es)local eh
if q(eo)=='string'then eh=c(eo)else eh=m(eo,ei)end;if es then setfenv(eh,es)end;return eh end else L.load=u end
if N.luajit and N.jit then
function L.max(m)local eo=0;for ei=1,#m do eo=E(eo,m[ei])end;return eo end elseif N.luajit then local m=L.unpack
function L.max(eo)local ei=#eo
if ei<=30 or ei>10240 then local en=0;for es=1,#eo do local eh=eo[es]if
eh>en then en=eh end end;return en else return E(m(eo))end end else local m=L.unpack;local eo=1000
function L.max(ei)local en=#ei;if en==0 then return-1 end;local es=1;local eh=eo
local er=ei[1]repeat if eh>en then eh=en end;local ed=E(m(ei,es,eh))if ed>er then er=ed end
es=es+eo;eh=eh+eo until es>=en;return er end end
local function U(_,m)local eo=d(_)or{}if eo.__mode then
error("The mode has already been set on table "..k(_)..".")end;eo.__mode=m;return l(_,eo)end;L.setmode=U;function L.weakboth(_)return U(_,"kv")end
function L.weakkey(_)return U(_,"k")end;function L.weakval(_)return U(_,"v")end
function L.strip_mt(_)return l(_,nil)end;local C;do local m,eo=0,{}
function C(ei)if not eo[ei]then m=m+1;eo[ei]=m end;return eo[ei]end end;L.getuniqueid=C;do local m=0;function L.gensym()m=m+1;return
"___SYM_"..m end end;function L.passprint(...)
p(...)return...end;local M,F,W,Y,P;local V=2;local function B(m,eo)eo=eo or 0;P={}local ei={}
M(m,ei,eo,eo)local en=O(ei,"")return en end
L.val_to_str=B
function M(m,eo,ei,en)en=en or 1
if"string"==q(m)then
m=A(m,"\n","\n".. (" "):rep(ei*V+en))
if T(A(m,"[^'\"]",""),'^"+$')then eo[#eo+1]=O{"'","",m,"'"}else eo[#
eo+1]=O{'"',A(m,'"','\\"'),'"'}end elseif"cdata"==q(m)then Y(m,eo,ei)elseif"table"==q(m)then if P[m]then eo[#eo+1]=P[m]else P[m]=k(m)
W(m,eo,ei)end else eo[#eo+1]=k(m)end end
function F(m,eo,ei)
if"string"==q(m)and T(m,"^[_%a][_%a%d]*$")then eo[#eo+1]=A(m,"\n",(" "):rep(
ei*V+1).."\n")else
eo[#eo+1]="[ "M(m,eo,ei)eo[#eo+1]=" ]"end end
function Y(m,eo,ei)eo[#eo+1]=(" "):rep(ei*V)eo[#eo+1]="["p(#eo)
for en=0,#m do if en%
16 ==0 and en~=0 then eo[#eo+1]="\n"
eo[#eo+1]=(" "):rep(ei*V+2)end
eo[#eo+1]=m[en]and 1 or 0;eo[#eo+1]=en~=#m and", "or""end;p(#eo,eo[1],eo[2])eo[#eo+1]="]"end
function W(m,eo,ei)eo[#eo+1]=P[m]eo[#eo+1]="{\n"
for en,es in w(m)do local eh=1;eo[#eo+1]=(" "):rep(
(ei+1)*V)F(en,eo,ei+1)
if eo[#eo]==" ]"and
eo[#eo-2]=="[ "then eh=8+#eo[#eo-1]end;eo[#eo+1]=" = "M(es,eo,ei+1,eh)eo[#eo+1]="\n"end;eo[#eo+1]=(" "):rep(ei*V)eo[#eo+1]="}"end;function L.expose(m)p(B(m))return m end
function L.map(m,eo,...)
if q(m)=="function"then m,eo=eo,m end;local ei={}for en=1,#m do ei[en]=eo(m[en],...)end;return ei end
function L.selfmap(m,eo,...)if q(m)=="function"then m,eo=eo,m end;for ei=1,#m do
m[ei]=eo(m[ei],...)end;return m end;local function G(m,eo,...)if q(m)=="function"then m,eo=eo,m end;local ei={}
for en,es in f,m do ei[en]=eo(es,...)end;return ei end
L.map_all=G;local function K(m,eo,ei)local en=1;if not ei then ei=m[1]en=2 end
for es=en,#m do ei=eo(ei,m[es])end;return ei end;L.fold=K;local function Q(m,eo,ei)
local en=0;if not ei then ei=m[#m]en=1 end
for es=#m-en,1,-1 do ei=eo(m[es],ei)end;return ei end
L.foldr=Q
local function J(m,eo,ei,en)local es=1;if not en then en=eo(m[1])es=2 end;for eh=es,#m do
en=ei(en,eo(m[eh]))end;return en end;L.map_fold=J
local function X(m,eo,ei,en)local es=0;if not en then en=eo(m[#en])es=1 end;for eh=#m-es,1,-1 do
en=ei(eo(m[eh],en))end;return en end;L.map_foldr=J;function L.zip(m,eo)local ei,en={},E(#m,#eo)
for es=1,en do ei[es]={m[es],eo[es]}end;return ei end
function L.zip_all(m,eo)local ei={}for en,es in w(m)do
ei[en]={es,eo[en]}end;for en,es in w(eo)do
if ei[en]==nil then ei[en]={m[en],es}end end;return ei end;function L.filter(m,eo)local ei={}
for en=1,#m do if eo(m[en])then I(ei,m[en])end end end;local function Z(...)return...end;L.id=Z;local function ee(m,eo)return
m and eo end;local function et(m,eo)return m or eo end;function L.copy(m)
return G(m,Z)end;function L.all(m,eo)
if eo then return J(m,eo,ee)else return K(m,ee)end end;function L.any(m,eo)
if eo then return J(m,eo,et)else return K(m,et)end end;function L.get(m)
return function(eo)return eo[m]end end
function L.lt(m)return function(eo)return eo<m end end
function L.compose(m,eo)return function(...)return m(eo(...))end end;function L.extend(m,...)
for eo=1,g('#',...)do for ei,en in w((g(eo,...)))do m[ei]=en end end;return m end;function L.setify(_)local m={}for eo=1,#_ do
m[_[eo]]=true end;return m end
function L.arrayify(...)return{...}end;local function ea(z)return z..""end
function L.checkstring(z,m)local eo,ei=y(ea,z)if not eo then if m==nil then m="?"end
error(
"bad argument to '"..k(m).."' (string expected, got "..q(z)..")",2)end;return ei end;return L end end;return i"init"end
a["cc.lfs"]=function(...)local n={}
function n.attributes(s,h)if not fs.exists(s)then
printError(debug.traceback())
error("File '"..s.."' does not exist",2)end
local r=fs.attributes(s)
local d={mode=r.isDir and"directory"or"file",size=r.size,modification=r.modified}if h then return d[h]else return d end end;function n.currentdir()return shell.dir()end
function n.dir(s)if not fs.isDir(s)then
error("Directory does not exist",2)end;local h=fs.list(s)local r=0;return
function()r=r+1;return h[r]end end;function n.mkdir(s)fs.makeDir(s)end
function n.rmdir(s)fs.delete(s)end;return n end
a["cc.argparse"]=function(...)local function n(L,U)
for C,M in pairs(U)do if type(M)=="table"then M=n({},M)end;L[C]=M end;return L end
local function s(L,U,C)local M={}M.__index=M;if C then
M.__prototype=n(n({},C.__prototype),L)else M.__prototype=L end
if U then local W={}for Y,P in ipairs(U)do
local V,B=P[1],P[2]
M[V]=function(G,K)if not B(G,K)then G["_"..V]=K end;return G end;W[V]=true end
function M.__call(Y,...)
if
type((...))=="table"then
for P,V in pairs((...))do if W[P]then Y[P](Y,V)end end else local P=select("#",...)
for V,B in ipairs(U)do if V>P or V>U.args then break end
local G=select(V,...)if G~=nil then Y[B[1]](Y,G)end end end;return Y end end;local F={}F.__index=C;function F.__call(W,...)local Y=n({},W.__prototype)
setmetatable(Y,W)return Y(...)end
return setmetatable(M,F)end
local function h(L,U,C)for M,F in ipairs(U)do if type(C)==F then return true end end
error(("bad property '%s' (%s expected, got %s)"):format(L,table.concat(U," or "),type(C)))end
local function r(L,...)local U={...}return{L,function(C,M)h(L,U,M)end}end
local d={"name",function(L,U)h("name",{"string"},U)
for C in U:gmatch("%S+")do
L._name=L._name or C;table.insert(L._aliases,C)
table.insert(L._public_aliases,C)if C:find("_",1,true)then
table.insert(L._aliases,(C:gsub("_","-")))end end;return true end}
local l={"hidden_name",function(L,U)h("hidden_name",{"string"},U)
for C in U:gmatch("%S+")do
table.insert(L._aliases,C)if C:find("_",1,true)then
table.insert(L._aliases,(C:gsub("_","-")))end end;return true end}
local function u(L)if tonumber(L)then return tonumber(L),tonumber(L)end;if
L=="*"then return 0,math.huge end;if L=="+"then return 1,math.huge end;if
L=="?"then return 0,1 end;if L:match"^%d+%-%d+$"then local U,C=L:match"^(%d+)%-(%d+)$"return
tonumber(U),tonumber(C)end
if
L:match"^%d+%+$"then local U=L:match"^(%d+)%+$"return tonumber(U),math.huge end end
local function c(L)
return
{L,function(U,C)h(L,{"number","string"},C)local M,F=u(C)if not M then
error(("bad property '%s'"):format(L))end;U["_min"..L],U["_max"..L]=M,F end}end;local m={}
local f={"action",function(L,U)h("action",{"function","string"},U)if
type(U)=="string"and not m[U]then
error(("unknown action '%s'"):format(U))end end}
local w={"init",function(L)L._has_init=true end}
local y={"default",function(L,U)
if type(U)~="string"then L._init=U;L._has_init=true;return true end end}
local p={"add_help",function(L,U)
h("add_help",{"boolean","string","table"},U)if L._help_option_idx then
table.remove(L._options,L._help_option_idx)L._help_option_idx=nil end
if U then
local C=L:flag():description"Show this help message and exit.":action(function()
print(L:get_help())error(nil,0)end)if U~=true then C=C(U)end;if not C._name then C"-h""--help"end;L._help_option_idx=
#L._options end end}
local v=s({_arguments={},_options={},_commands={},_mutexes={},_groups={},_require_command=true,_handle_options=true},{args=3,r("name","string"),r("description","string"),r("epilog","string"),r("usage","string"),r("help","string"),r("require_command","boolean"),r("handle_options","boolean"),r("action","function"),r("command_target","string"),r("help_vertical_space","number"),r("usage_margin","number"),r("usage_max_width","number"),r("help_usage_margin","number"),r("help_description_margin","number"),r("help_max_width","number"),p})
local b=s({_aliases={},_public_aliases={}},{args=3,d,r("description","string"),r("epilog","string"),l,r("summary","string"),r("target","string"),r("usage","string"),r("help","string"),r("require_command","boolean"),r("handle_options","boolean"),r("action","function"),r("command_target","string"),r("help_vertical_space","number"),r("usage_margin","number"),r("usage_max_width","number"),r("help_usage_margin","number"),r("help_description_margin","number"),r("help_max_width","number"),r("hidden","boolean"),p},v)
local g=s({_minargs=1,_maxargs=1,_mincount=1,_maxcount=1,_defmode="unused",_show_default=true},{args=5,r("name","string"),r("description","string"),y,r("convert","function","table"),c("args"),r("target","string"),r("defmode","string"),r("show_default","boolean"),r("argname","string","table"),r("choices","table"),r("hidden","boolean"),f,w})
local k=s({_aliases={},_public_aliases={},_mincount=0,_overwrite=true},{args=6,d,r("description","string"),y,r("convert","function","table"),c("args"),c("count"),l,r("target","string"),r("defmode","string"),r("show_default","boolean"),r("overwrite","boolean"),r("argname","string","table"),r("choices","table"),r("hidden","boolean"),f,w},g)
function v:_inherit_property(L,U)local C=self
while true do local M=C["_"..L]if M~=nil then return M end;if not C._parent then
return U end;C=C._parent end end
function g:_get_argument_list()local L={}local U=1
while U<=math.min(self._minargs,3)do
local C=self:_get_argname(U)
if self._default and self._defmode:find"a"then C="["..C.."]"end;table.insert(L,C)U=U+1 end
while U<=math.min(self._maxargs,3)do table.insert(L,"["..
self:_get_argname(U).."]")U=U+1;if
self._maxargs==math.huge then break end end;if U<self._maxargs then table.insert(L,"...")end
return L end
function g:_get_usage()
local L=table.concat(self:_get_argument_list()," ")if self._default and self._defmode:find"u"then
if self._maxargs>1 or
(
self._minargs==1 and not self._defmode:find"a")then L="["..L.."]"end end
return L end;function m.store_true(L,U)L[U]=true end;function m.store_false(L,U)L[U]=false end;function m.store(L,U,C)
L[U]=C end
function m.count(L,U,C,M)if not M then L[U]=L[U]+1 end end;function m.append(L,U,C,M)L[U]=L[U]or{}table.insert(L[U],C)if M then
table.remove(L[U],1)end end
function m.concat(L,U,C,M)if M then
error("'concat' action can't handle too many invocations")end;L[U]=L[U]or{}for F,W in ipairs(C)do
table.insert(L[U],W)end end
function g:_get_action()local L,U
if self._maxcount==1 then if self._maxargs==0 then L,U="store_true",nil else
L,U="store",nil end else if self._maxargs==0 then L,U="count",0 else
L,U="append",{}end end;if self._action then L=self._action end
if self._has_init then U=self._init end;if type(L)=="string"then L=m[L]end;return L,U end
function g:_get_argname(L)
local U=self._argname or self:_get_default_argname()if type(U)=="table"then return U[L]else return U end end;function g:_get_choices_list()return
"{"..table.concat(self._choices,",").."}"end
function g:_get_default_argname()if
self._choices then return self:_get_choices_list()else
return"<"..self._name..">"end end;function k:_get_default_argname()
if self._choices then return self:_get_choices_list()else return"<"..
self:_get_default_target()..">"end end
function g:_get_label_lines()if
self._choices then return{self:_get_choices_list()}else
return{self._name}end end
function k:_get_label_lines()local L=self:_get_argument_list()if#L==0 then return
{table.concat(self._public_aliases,", ")}end;local U=-1;for F,W in
ipairs(self._public_aliases)do U=math.max(U,#W)end
local C=table.concat(L," ")local M={}for F,W in ipairs(self._public_aliases)do
local Y=(" "):rep(U-#W)..W.." "..C;if F~=#self._public_aliases then Y=Y..","end
table.insert(M,Y)end
return M end;function b:_get_label_lines()
return{table.concat(self._public_aliases,", ")}end
function g:_get_description()
if
self._default and self._show_default then
if self._description then return
("%s (default: %s)"):format(self._description,self._default)else return
("default: %s"):format(self._default)end else return self._description or""end end;function b:_get_description()
return self._summary or self._description or""end
function k:_get_usage()
local L=self:_get_argument_list()table.insert(L,1,self._name)
L=table.concat(L," ")
if self._mincount==0 or self._default then L="["..L.."]"end;return L end;function g:_get_default_target()return self._name end
function k:_get_default_target()local L
for U,C in
ipairs(self._public_aliases)do if C:sub(1,1)==C:sub(2,2)then L=C:sub(3)break end end;L=L or self._name:sub(2)
return(L:gsub("-","_"))end
function k:_is_vararg()return self._maxargs~=self._minargs end
function v:_get_fullname(L)local U=self._parent;if L and not U then return""end
local C={self._name}while U do
if not L or U._parent then table.insert(C,1,U._name)end;U=U._parent end
return table.concat(C," ")end
function v:_update_charset(L)L=L or{}
for U,C in ipairs(self._commands)do C:_update_charset(L)end;for U,C in ipairs(self._options)do
for U,M in ipairs(C._aliases)do L[M:sub(1,1)]=true end end;return L end
function v:argument(...)local L=g(...)table.insert(self._arguments,L)return L end
function v:option(...)local L=k(...)table.insert(self._options,L)return L end
function v:flag(...)return self:option():args(0)(...)end;function v:command(...)local L=b():add_help(true)(...)L._parent=self
table.insert(self._commands,L)return L end
function v:mutex(...)local L={...}for U,C in
ipairs(L)do local M=getmetatable(C)
assert(M==k or M==g,("bad argument #%d to 'mutex' (Option or Argument expected)"):format(U))end
table.insert(self._mutexes,L)return self end
function v:group(L,...)
assert(type(L)=="string",("bad argument #1 to 'group' (string expected, got %s)"):format(type(L)))local U={name=L,...}
for C,M in ipairs(U)do local F=getmetatable(M)
assert(F==k or F==g or F==b,("bad argument #%d to 'group' (Option or Argument or Command expected)"):format(
C+1))end;table.insert(self._groups,U)return self end;local q="Usage: "
function v:get_usage()if self._usage then return self._usage end;local L=self:_inherit_property("usage_margin",
#q)
local U=self:_inherit_property("usage_max_width",70)local C={q..self:_get_fullname()}
local function M(G)if#C[#C]+1+
#G<=U then C[#C]=C[#C].." "..G else
C[#C+1]=(" "):rep(L)..G end end;local F={}local W={}local Y={}local P={}
local function V(G,K)if Y[G]then return end;Y[G]=true;local Q={}for J,X in ipairs(G)do
if
not X._hidden and not W[X]then if getmetatable(X)==k or X==K then
table.insert(Q,X:_get_usage())W[X]=true end end end;if
#Q==1 then M(Q[1])elseif#Q>1 then
M("("..table.concat(Q," | ")..")")end end;local function B(G)
if not G._hidden and not W[G]then M(G:_get_usage())W[G]=true end end
for G,K in ipairs(self._mutexes)do local Q=false
local J=false
for G,X in ipairs(K)do
if getmetatable(X)==k then if X:_is_vararg()then Q=true end else J=true;P[X]=
P[X]or{}table.insert(P[X],K)end;F[X]=true end;if not Q and not J then V(K)end end;for G,K in ipairs(self._options)do
if not F[K]and not K:_is_vararg()then B(K)end end
for G,K in ipairs(self._arguments)do local Q
if F[K]then for G,J in
ipairs(P[K])do if not Y[J]then Q=J end end end;if Q then V(Q,K)else B(K)end end;for G,K in ipairs(self._mutexes)do V(K)end
for G,K in ipairs(self._options)do B(K)end
if#self._commands>0 then if self._require_command then M("<command>")else
M("[<command>]")end;M("...")end;return table.concat(C,"\n")end
local function j(L)if L==""then return{}end;local U={}if L:sub(-1)~="\n"then L=L.."\n"end;for C in
L:gmatch("([^\n]*)\n")do table.insert(U,C)end;return U end
local function x(L,U)local C={}local M=L:match("^ *")
if L:find("^ *[%*%+%-]")then M=M.." "..
L:match("^ *[%*%+%-]( *)")end;local F={}local W=0;local Y=1
while true do local P,V,B=L:find("([^ ]+)",Y)if not P then break end
local G=L:sub(Y,P-1)Y=V+1;if(#F==0)or(W+#G+#B<=U)then table.insert(F,G)
table.insert(F,B)W=W+#G+#B else table.insert(C,table.concat(F))
F={M,B}W=#M+#B end end
if#F>0 then table.insert(C,table.concat(F))end;if#C==0 then C[1]=""end;return C end
local function z(L,U)local C={}for M,F in ipairs(L)do local W=x(F,U)
for M,Y in ipairs(W)do table.insert(C,Y)end end;return C end
function v:_get_element_help(L)local U=L:_get_label_lines()
local C=j(L:_get_description())local M={}
local F=self:_inherit_property("help_usage_margin",3)local W=(" "):rep(F)
local Y=self:_inherit_property("help_description_margin",25)local P=(" "):rep(Y)
local V=self:_inherit_property("help_max_width")if V then local B=math.max(V-Y,10)C=z(C,B)end
if
#U[1]>= (Y-F)then for B,G in ipairs(U)do table.insert(M,W..G)end;for B,G in ipairs(C)do table.insert(M,
P..G)end else
for B=1,math.max(#U,#C)do local G=U[B]
local K=C[B]local Q=""if G then Q=W..G end;if K and K~=""then
Q=Q.. (" "):rep(Y-#Q)..K end;table.insert(M,Q)end end;return table.concat(M,"\n")end;local function _(L)local U={}
for C,M in ipairs(L)do U[getmetatable(M)]=true end;return U end
function v:_add_group_help(L,U,C,M)local F={C}
for W,Y in
ipairs(M)do if not Y._hidden and not U[Y]then U[Y]=true
table.insert(F,self:_get_element_help(Y))end end;if#F>1 then
table.insert(L,table.concat(F,("\n"):rep(
self:_inherit_property("help_vertical_space",0)+1)))end end
function v:get_help()if self._help then return self._help end
local L={self:get_usage()}local U=self:_inherit_property("help_max_width")
if
self._description then local W=self._description
if U then W=table.concat(z(j(W),U),"\n")end;table.insert(L,W)end;local C={[g]={},[k]={},[b]={}}for W,Y in ipairs(self._groups)do local P=_(Y)
for W,V in
ipairs({g,k,b})do if P[V]then table.insert(C[V],Y)break end end end
local M={{name="Arguments",type=g,elements=self._arguments},{name="Options",type=k,elements=self._options},{name="Commands",type=b,elements=self._commands}}local F={}
for W,Y in ipairs(M)do local P=C[Y.type]for W,B in ipairs(P)do
self:_add_group_help(L,F,B.name..":",B)end;local V=Y.name..":"if#P>0 then V="Other "..
V:gsub("^.",string.lower)end
self:_add_group_help(L,F,V,Y.elements)end
if self._epilog then local W=self._epilog
if U then W=table.concat(z(j(W),U),"\n")end;table.insert(L,W)end;return table.concat(L,"\n\n")end
function v:add_help_command(L)if L then
assert(type(L)=="string"or type(L)=="table",("bad argument #1 to 'add_help_command' (string or table expected, got %s)"):format(type(L)))end
local U=self:command():description"Show help for commands."
U:argument"command":description"The command to show help for.":args"?":action(function(C,C,M)
if
not M then print(self:get_help())error(nil,0)else
for C,F in
ipairs(self._commands)do for C,W in ipairs(F._aliases)do
if W==M then print(F:get_help())error(nil,0)end end end end
U:error(("unknown command '%s'"):format(M))end)if L then U=U(L)end;if not U._name then U"help"end;U._is_help_command=true
return self end
function v:_is_shell_safe()
if self._basename then
if self._basename:find("[^%w_%-%+%.]")then return false end else
for L,U in ipairs(self._aliases)do if U:find("[^%w_%-%+%.]")then return false end end end
for L,U in ipairs(self._options)do for L,C in ipairs(U._aliases)do
if C:find("[^%w_%-%+%.]")then return false end end
if U._choices then for L,C in ipairs(U._choices)do if
C:find("[%s'\"]")then return false end end end end;for L,U in ipairs(self._arguments)do
if U._choices then for L,C in ipairs(U._choices)do
if C:find("[%s'\"]")then return false end end end end
for L,U in
ipairs(self._commands)do if not U:_is_shell_safe()then return false end end;return true end
function v:add_complete(L)if L then
assert(type(L)=="string"or type(L)=="table",("bad argument #1 to 'add_complete' (string or table expected, got %s)"):format(type(L)))end
local U=self:option():description"Output a shell completion script for the specified shell.":args(1):choices{"bash","zsh","fish"}:action(function(C,C,M)
io.write(self[
"get_"..M.."_complete"](self))error(nil,0)end)if L then U=U(L)end;if not U._name then U"--completion"end;return self end
function v:add_complete_command(L)
if L then
assert(type(L)=="string"or type(L)=="table",("bad argument #1 to 'add_complete_command' (string or table expected, got %s)"):format(type(L)))end
local U=self:command():description"Output a shell completion script."
U:argument"shell":description"The shell to output a completion script for.":choices{"bash","zsh","fish"}:action(function(C,C,M)
io.write(self[
"get_"..M.."_complete"](self))error(nil,0)end)if L then U=U(L)end;if not U._name then U"completion"end;return self end;local function E(L)return
L:gsub("[/\\]*$",""):match(".*[/\\]([^/\\]*)")or L end
local function T(L)
local U=L:_get_description():match("^(.-)%.%s")return
U or L:_get_description():match("^(.-)%.?$")end
function v:_get_options()local L={}for U,C in ipairs(self._options)do for U,M in ipairs(C._aliases)do
table.insert(L,M)end end;return
table.concat(L," ")end
function v:_get_commands()local L={}for U,C in ipairs(self._commands)do for U,M in ipairs(C._aliases)do
table.insert(L,M)end end;return
table.concat(L," ")end
function v:_bash_option_args(L,U)local C={}
for M,F in ipairs(self._options)do
if F._choices or F._minargs>0 then local W
if
F._choices then
W='COMPREPLY=($(compgen -W "'..table.concat(F._choices," ")..'" -- "$cur"))'else W='COMPREPLY=($(compgen -f -- "$cur"))'end
table.insert(C,(" "):rep(U+4)..table.concat(F._aliases,"|")..")")table.insert(C,(" "):rep(U+8)..W)table.insert(C,(" "):rep(
U+8).."return 0")table.insert(C,(" "):rep(
U+8)..";;")end end
if#C>0 then
table.insert(L,(" "):rep(U)..'case "$prev" in')table.insert(L,table.concat(C,"\n"))table.insert(L,
(" "):rep(U).."esac\n")end end
function v:_bash_get_cmd(L,U)if#self._commands==0 then return end
table.insert(L,
(" "):rep(U)..'args=("${args[@]:1}")')
table.insert(L,(" "):rep(U)..'for arg in "${args[@]}"; do')
table.insert(L,(" "):rep(U+4)..'case "$arg" in')
for C,M in ipairs(self._commands)do
table.insert(L,(" "):rep(U+8)..
table.concat(M._aliases,"|")..")")if self._parent then
table.insert(L,(" "):rep(U+12)..'cmd="$cmd '..M._name..'"')else
table.insert(L,(" "):rep(U+12)..'cmd="'..M._name..'"')end
table.insert(L,(" "):rep(
U+12)..'opts="$opts '..M:_get_options()..'"')M:_bash_get_cmd(L,U+12)
table.insert(L,(" "):rep(U+12).."break")
table.insert(L,(" "):rep(U+12)..";;")end
table.insert(L,(" "):rep(U+4).."esac")table.insert(L,(" "):rep(U).."done")end
function v:_bash_cmd_completions(L)local U={}
if self._parent then self:_bash_option_args(U,12)end
if#self._commands>0 then
table.insert(U,(" "):rep(12)..'COMPREPLY=($(compgen -W "'..
self:_get_commands()..'" -- "$cur"))')elseif self._is_help_command then
table.insert(U,(" "):rep(12)..'COMPREPLY=($(compgen -W "'..
self._parent:_get_commands()..'" -- "$cur"))')end
if#U>0 then
table.insert(L,(" "):rep(8)..
"'"..self:_get_fullname(true).."')")table.insert(L,table.concat(U,"\n"))table.insert(L,
(" "):rep(12)..";;")end
for C,M in ipairs(self._commands)do M:_bash_cmd_completions(L)end end
function v:get_bash_complete()self._basename=E(self._name)
assert(self:_is_shell_safe())
local L={([[
 _%s() {
     local IFS=$' \t\n'
     local args cur prev cmd opts arg
     args=("${COMP_WORDS[@]}")
     cur="${COMP_WORDS[COMP_CWORD]}"
     prev="${COMP_WORDS[COMP_CWORD-1]}"
     opts="%s"
 ]]):format(self._basename,self:_get_options())}self:_bash_option_args(L,4)
self:_bash_get_cmd(L,4)
if#self._commands>0 then table.insert(L,"")table.insert(L,
(" "):rep(4)..'case "$cmd" in')
self:_bash_cmd_completions(L)
table.insert(L,(" "):rep(4).."esac\n")end
table.insert(L,([=[
     if [[ "$cur" = -* ]]; then
         COMPREPLY=($(compgen -W "$opts" -- "$cur"))
     fi
 }
 
 complete -F _%s -o bashdefault -o default %s
 ]=]):format(self._basename,self._basename))return table.concat(L,"\n")end
function v:_zsh_arguments(L,U,C)
if self._parent then
table.insert(L,(" "):rep(C).."options=(")
table.insert(L,(" "):rep(C+2).."$options")else
table.insert(L,(" "):rep(C).."local -a options=(")end
for M,F in ipairs(self._options)do local W={}
if#F._aliases>1 then if F._maxcount>1 then
table.insert(W,'"*"')end
table.insert(W,"{"..
table.concat(F._aliases,",")..'}"')else table.insert(W,'"')
if F._maxcount>1 then table.insert(W,"*")end;table.insert(W,F._name)end;if F._description then local Y=T(F):gsub('["%]:`$]',"\\%0")
table.insert(W,"["..Y.."]")end;if F._maxargs==math.huge then
table.insert(W,":*")end
if F._choices then
table.insert(W,": :("..
table.concat(F._choices," ")..")")elseif F._maxargs>0 then table.insert(W,": :_files")end;table.insert(W,'"')
table.insert(L,(" "):rep(C+2)..table.concat(W))end;table.insert(L,(" "):rep(C)..")")
table.insert(L,
(" "):rep(C).."_arguments -s -S \\")
table.insert(L,(" "):rep(C+2).."$options \\")
if self._is_help_command then
table.insert(L,(" "):rep(C+2)..'": :('..
self._parent:_get_commands()..')" \\')else
for M,F in ipairs(self._arguments)do local W
if F._choices then W=": :("..
table.concat(F._choices," ")..")"else W=": :_files"end;if F._maxargs==math.huge then
table.insert(L,(" "):rep(C+2)..'"*'..W..'" \\')break end;for M=1,F._maxargs do
table.insert(L,
(" "):rep(C+2)..'"'..W..'" \\')end end;if#self._commands>0 then
table.insert(L,(" "):rep(C+2)..
'": :_'..U..'_cmds" \\')
table.insert(L,(" "):rep(C+2)..'"*:: :->args" \\')end end
table.insert(L,(" "):rep(C+2).."&& return 0")end
function v:_zsh_cmds(L,U)
table.insert(L,"\n_"..U.."_cmds() {")table.insert(L,"  local -a commands=(")
for C,M in
ipairs(self._commands)do local F={}
if#M._aliases>1 then
table.insert(F,"{"..
table.concat(M._aliases,",")..'}"')else table.insert(F,'"'..M._name)end;if M._description then
table.insert(F,":"..T(M):gsub('["`$]',"\\%0"))end;table.insert(L,"    "..
table.concat(F)..'"')end
table.insert(L,'  )\n  _describe "command" commands\n}')end
function v:_zsh_complete_help(L,U,C,M)if#self._commands==0 then return end
self:_zsh_cmds(U,C)
table.insert(L,"\n".. (" "):rep(M).."case $words[1] in")
for F,W in ipairs(self._commands)do local Y=C.."_"..W._name
table.insert(L,
(" "):rep(M+2)..table.concat(W._aliases,"|")..")")W:_zsh_arguments(L,Y,M+4)
W:_zsh_complete_help(L,U,Y,M+4)
table.insert(L,(" "):rep(M+4)..";;\n")end;table.insert(L,(" "):rep(M).."esac")end
function v:get_zsh_complete()self._basename=E(self._name)
assert(self:_is_shell_safe())
local L={("#compdef %s\n"):format(self._basename)}local U={}
table.insert(L,"_"..self._basename.."() {")
if#self._commands>0 then
table.insert(L,"  local context state state_descr line")table.insert(L,"  typeset -A opt_args\n")end;self:_zsh_arguments(L,self._basename,2)
self:_zsh_complete_help(L,U,self._basename,2)table.insert(L,"\n  return 1")
table.insert(L,"}")local C=table.concat(L,"\n")if#U>0 then C=C..
"\n"..table.concat(U,"\n")end;return C.."\n\n_"..
self._basename.."\n"end;local function A(L)return L:gsub("[\\']","\\%0")end
function v:_fish_get_cmd(L,U)if#
self._commands==0 then return end
table.insert(L,(" "):rep(U).."set -e cmdline[1]")
table.insert(L,(" "):rep(U).."for arg in $cmdline")
table.insert(L,(" "):rep(U+4).."switch $arg")
for C,M in ipairs(self._commands)do
table.insert(L,(" "):rep(U+8).."case "..
table.concat(M._aliases," "))
table.insert(L,(" "):rep(U+12).."set cmd $cmd "..M._name)M:_fish_get_cmd(L,U+12)
table.insert(L,(" "):rep(U+12).."break")end
table.insert(L,(" "):rep(U+4).."end")table.insert(L,(" "):rep(U).."end")end
function v:_fish_complete_help(L,U)local C="complete -c "..U;table.insert(L,"")
for M,F in
ipairs(self._commands)do local W=table.concat(F._aliases," ")local Y
if self._parent then
Y=("%s -n '__fish_%s_using_command %s' -xa '%s'"):format(C,U,self:_get_fullname(true),W)else
Y=("%s -n '__fish_%s_using_command' -xa '%s'"):format(C,U,W)end
if F._description then Y=("%s -d '%s'"):format(Y,A(T(F)))end;table.insert(L,Y)end
if self._is_help_command then
local M=("%s -n '__fish_%s_using_command %s' -xa '%s'"):format(C,U,self:_get_fullname(true),self._parent:_get_commands())table.insert(L,M)end
for M,F in ipairs(self._options)do local W={C}if self._parent then
table.insert(W,"-n '__fish_"..U.."_seen_command "..
self:_get_fullname(true).."'")end
for M,Y in ipairs(F._aliases)do
if
Y:match("^%-.$")then table.insert(W,"-s "..Y:sub(2))elseif Y:match("^%-%-.+")then table.insert(W,
"-l "..Y:sub(3))end end
if F._choices then
table.insert(W,"-xa '"..table.concat(F._choices," ").."'")elseif F._minargs>0 then table.insert(W,"-r")end;if F._description then
table.insert(W,"-d '"..A(T(F)).."'")end
table.insert(L,table.concat(W," "))end
for M,F in ipairs(self._commands)do F:_fish_complete_help(L,U)end end
function v:get_fish_complete()self._basename=E(self._name)
assert(self:_is_shell_safe())local L={}
if#self._commands>0 then
table.insert(L,([[
 function __fish_%s_print_command
     set -l cmdline (commandline -poc)
     set -l cmd]]):format(self._basename))self:_fish_get_cmd(L,4)
table.insert(L,([[
     echo "$cmd"
 end
 
 function __fish_%s_using_command
     test (__fish_%s_print_command) = "$argv"
     and return 0
     or return 1
 end
 
 function __fish_%s_seen_command
     string match -q "$argv*" (__fish_%s_print_command)
     and return 0
     or return 1
 end]]):format(self._basename,self._basename,self._basename,self._basename))end;self:_fish_complete_help(L,self._basename)return
table.concat(L,"\n").."\n"end
local function O(L,U)local C={}local M;local F={}
for Y in pairs(L)do if type(Y)=="string"then
for P=1,#Y do
M=Y:sub(1,P-1)..Y:sub(P+1)if not C[M]then C[M]={}end;table.insert(C[M],Y)end end end
for Y=1,#U+1 do M=U:sub(1,Y-1)..U:sub(Y+1)if L[M]then F[M]=true elseif C[M]then for P,V in
ipairs(C[M])do F[V]=true end end end;local W=next(F)
if W then
if next(F,W)then local Y={}for P in pairs(F)do
table.insert(Y,"'"..P.."'")end;table.sort(Y)return"\nDid you mean one of these: "..
table.concat(Y," ").."?"else return
"\nDid you mean '"..W.."'?"end else return""end end;local I=s({invocations=0})
function I:__call(L,U)self.state=L;self.result=L.result
self.element=U
self.target=U._target or U:_get_default_target()self.action,self.result[self.target]=U:_get_action()return
self end;function I:error(L,...)self.state:error(L,...)end
function I:convert(L,U)
local C=self.element._convert
if C then local M,F;if type(C)=="function"then M,F=C(L)elseif type(C[U])=="function"then M,F=C[U](L)else
M=C[L]end;if M==nil then
self:error(F and"%s"or
"malformed argument '%s'",F or L)end;L=M end;return L end;function I:default(L)return
self.element._defmode:find(L)and self.element._default end
local function N(L,U,C,M)
local F=""if U~=C then
F="at ".. (M and"most"or"least").." "end;local W=M and C or U
return F..tostring(W).." "..L..
(W==1 and""or"s")end;function I:set_name(L)
self.name=("%s '%s'"):format(L and"option"or"argument",L or
self.element._name)end
function I:invoke()self.open=true
self.overwrite=false
if self.invocations>=self.element._maxcount then
if self.element._overwrite then
self.overwrite=true else
local L=N("time",self.element._mincount,self.element._maxcount,true)self:error("%s must be used %s",self.name,L)end else self.invocations=self.invocations+1 end;self.args={}
if self.element._maxargs<=0 then self:close()end;return self.open end
function I:check_choices(L)
if self.element._choices then for M,F in ipairs(self.element._choices)do
if L==F then return end end
local U="'"..
table.concat(self.element._choices,"', '").."'"local C=getmetatable(self.element)==k
self:error("%s%s must be one of %s",
C and"argument for "or"",self.name,U)end end
function I:pass(L)self:check_choices(L)
L=self:convert(L,#self.args+1)table.insert(self.args,L)if
#self.args>=self.element._maxargs then self:close()end;return self.open end
function I:complete_invocation()while#self.args<self.element._minargs do
self:pass(self.element._default)end end
function I:close()
if self.open then self.open=false
if#self.args<self.element._minargs then
if
self:default("a")then self:complete_invocation()else
if#self.args==0 then
if
getmetatable(self.element)==g then self:error("missing %s",self.name)elseif
self.element._maxargs==1 then
self:error("%s requires an argument",self.name)end end
self:error("%s requires %s",self.name,N("argument",self.element._minargs,self.element._maxargs))end end;local L
if self.element._maxargs==0 then L=self.args[1]elseif
self.element._maxargs==1 then
if self.element._minargs==0 and
self.element._mincount~=self.element._maxcount then L=self.args else L=self.args[1]end else L=self.args end
self.action(self.result,self.target,L,self.overwrite)end end
local S=s({result={},options={},arguments={},argument_i=1,element_to_mutexes={},mutex_to_element_state={},command_actions={}})
function S:__call(L,U)self.parser=L;self.error_handler=U
self.charset=L:_update_charset()self:switch(L)return self end;function S:error(L,...)
self.error_handler(self.parser,L:format(...))end
function S:switch(L)self.parser=L;if L._action then
table.insert(self.command_actions,{action=L._action,name=L._name})end;for U,C in ipairs(L._options)do C=I(self,C)
table.insert(self.options,C)
for U,M in ipairs(C.element._aliases)do self.options[M]=C end end
for U,C in
ipairs(L._mutexes)do for U,M in ipairs(C)do if not self.element_to_mutexes[M]then
self.element_to_mutexes[M]={}end
table.insert(self.element_to_mutexes[M],C)end end
for U,C in ipairs(L._arguments)do C=I(self,C)
table.insert(self.arguments,C)C:set_name()C:invoke()end;self.handle_options=L._handle_options
self.argument=self.arguments[self.argument_i]self.commands=L._commands;for U,C in ipairs(self.commands)do for U,M in ipairs(C._aliases)do
self.commands[M]=C end end end
function S:get_option(L)local U=self.options[L]if not U then
self:error("unknown option '%s'%s",L,O(self.options,L))else return U end end
function S:get_command(L)local U=self.commands[L]
if not U then
if#self.commands>0 then
self:error("unknown command '%s'%s",L,O(self.commands,L))else self:error("too many arguments")end else return U end end
function S:check_mutexes(L)
if self.element_to_mutexes[L.element]then
for U,C in
ipairs(self.element_to_mutexes[L.element])do local M=self.mutex_to_element_state[C]
if M and M~=L then
self:error("%s can not be used together with %s",L.name,M.name)else self.mutex_to_element_state[C]=L end end end end
function S:invoke(L,U)self:close()L:set_name(U)
self:check_mutexes(L,U)if L:invoke()then self.option=L end end
function S:pass(L)
if self.option then
if not self.option:pass(L)then self.option=nil end elseif self.argument then self:check_mutexes(self.argument)if not
self.argument:pass(L)then self.argument_i=self.argument_i+1
self.argument=self.arguments[self.argument_i]end else
local U=self:get_command(L)self.result[U._target or U._name]=true;if
self.parser._command_target then
self.result[self.parser._command_target]=U._name end;self:switch(U)end end;function S:close()
if self.option then self.option:close()self.option=nil end end
function S:finalize()self:close()for L=self.argument_i,#
self.arguments do local U=self.arguments[L]
if
#U.args==0 and U:default("u")then U:complete_invocation()else U:close()end end;if
self.parser._require_command and#self.commands>0 then
self:error("a command is required")end
for L,U in ipairs(self.options)do
U.name=
U.name or("option '%s'"):format(U.element._name)
if U.invocations==0 then if U:default("u")then U:invoke()
U:complete_invocation()U:close()end end;local C=U.element._mincount
if U.invocations<C then
if U:default("a")then while U.invocations<C do
U:invoke()U:close()end elseif U.invocations==0 then
self:error("missing %s",U.name)else
self:error("%s must be used %s",U.name,N("time",C,U.element._maxcount))end end end;for L=#self.command_actions,1,-1 do
self.command_actions[L].action(self.result,self.command_actions[L].name)end end
function S:parse(L)
for U,C in ipairs(L)do local M=true
if self.handle_options then local F=C:sub(1,1)
if self.charset[F]then
if#C>1 then
M=false
if C:sub(2,2)==F then
if#C==2 then if self.options[C]then local W=self:get_option(C)
self:invoke(W,C)else self:close()end
self.handle_options=false else local W=C:find"="
if W then local Y=C:sub(1,W-1)local P=self:get_option(Y)if
P.element._maxargs<=0 then
self:error("option '%s' does not take arguments",Y)end;self:invoke(P,Y)self:pass(C:sub(
W+1))else local Y=self:get_option(C)
self:invoke(Y,C)end end else
for W=2,#C do local Y=F..C:sub(W,W)local P=self:get_option(Y)
self:invoke(P,Y)if W~=#C and P.element._maxargs>0 then
self:pass(C:sub(W+1))break end end end end end end;if M then self:pass(C)end end;self:finalize()return self.result end;function v:error(L)
io.stderr:write(("%s\n\nError: %s\n"):format(self:get_usage(),L))error(nil,0)end;local H=
rawget(_G,"arg")or{...}function v:_parse(L,U)
return S(self,U):parse(L or H)end;function v:parse(L)
return self:_parse(L,self.error)end;local function R(L)
return tostring(L).."\noriginal "..
debug.traceback("",2):sub(2)end
function v:pparse(L)local U
local C,M=xpcall(function()return self:_parse(L,function(F,W)U=W
error(W,0)end)end,R)if C then return true,M elseif not U then error(M,0)else return false,U end end;local D={}D.version="0.7.1"
setmetatable(D,{__call=function(L,...)
return v(H[0]):add_help(true)(...)end})return D end
a["bin/moon"]=function(...)local n=i("cc.argparse")local s=i("moonscript.base")
local h=i("moonscript.util")local r=i("moonscript.errors")local d=h.unpack
local l=n()({name="moon"})l:argument("script")
l:argument("args"):args("*")
l:option("-c --coverage","Collect and print code coverage")l:option("-d","Disable stack trace rewriting")
l:option("-v --version","Print version information")local u=0;local c=arg
for p=1,#c do local v=c[p]u=u+1;if v:sub(1,1)~="-"then break end end;local m={d(arg,1,u)}local f=l:parse(m)local w
w=function(...)
local p=table.concat((function(...)local v={}local b=1
local g={...}for k=1,#g do local q=g[k]v[b]=tostring(q)b=b+1 end;return v end)(...),"\t")return io.stderr:write(p.."\n")end;local y
y=function()if f.version then
i("moonscript.version").print_version()error(nil,0)end;local p=f.script
m={d(arg,u+1)}m[-1]=arg[0]m[0]=f.script;local v,b
local g,k=pcall(function()
v,b=s.loadfile(p,"t",_ENV,{implicitly_return_root=false})end)if not(g)then w(k)error(nil,0)end
if not(v)then if b then w(b)else
w("Can't file file: "..tostring(p))end;error(nil,0)end;h.getfenv(v).arg=m;local q;q=function()s.insert_loader()v(d(m))return
s.remove_loader()end;if
f.d then return q()end;local k,j,x
if f.coverage then print("starting coverage")
local z=i("moonscript.cmd.coverage")x=z.CodeCoverage()x:start()end
xpcall(q,function(z)k=z;j=debug.traceback("",2)end)
if k then local z=r.truncate_traceback(h.trim(j))
local _=r.rewrite_traceback(z,k)if _ then w(_)else
w(table.concat({k,h.trim(j)},"\n"))end;return error(nil,0)else if x then x:stop()return
x:print_results()end end end;return y()end;return a["bin/moon"](...)