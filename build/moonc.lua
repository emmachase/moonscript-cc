local loading = {}
local oldRequire, preload, loaded = require, {}, { startup = loading }

local function require(name)
	local result = loaded[name]

	if result ~= nil then
		if result == loading then
			error("loop or previous error loading module '" .. name .. "'", 2)
		end

		return result
	end

	loaded[name] = loading
	local contents = preload[name]
	if contents then
		result = contents(name)
	elseif oldRequire then
		result = oldRequire(name)
	else
		error("cannot load '" .. name .. "'", 2)
	end

	if result == nil then result = true end
	loaded[name] = result
	return result
end
preload["moonscript.version"] = function(...)
local version = "0.5.0"
return {
  version = version,
  print_version = function()
    return print("MoonScript version " .. tostring(version))
  end
}
end
preload["moonscript.util"] = function(...)
local concat
concat = table.concat
local unpack = unpack or table.unpack
local type = type
local moon = {
  is_object = function(value)
    return type(value) == "table" and value.__class
  end,
  is_a = function(thing, t)
    if not (type(thing) == "table") then
      return false
    end
    local cls = thing.__class
    while cls do
      if cls == t then
        return true
      end
      cls = cls.__parent
    end
    return false
  end,
  type = function(value)
    local base_type = type(value)
    if base_type == "table" then
      local cls = value.__class
      if cls then
        return cls
      end
    end
    return base_type
  end
}
local pos_to_line
pos_to_line = function(str, pos)
  local line = 1
  for _ in str:sub(1, pos):gmatch("\n") do
    line = line + 1
  end
  return line
end
local trim
trim = function(str)
  return str:match("^%s*(.-)%s*$")
end
local get_line
get_line = function(str, line_num)
  for line in str:gmatch("([^\n]*)\n?") do
    if line_num == 1 then
      return line
    end
    line_num = line_num - 1
  end
end
local get_closest_line
get_closest_line = function(str, line_num)
  local line = get_line(str, line_num)
  if (not line or trim(line) == "") and line_num > 1 then
    return get_closest_line(str, line_num - 1)
  else
    return line, line_num
  end
end
local split
split = function(str, delim)
  if str == "" then
    return { }
  end
  str = str .. delim
  local _accum_0 = { }
  local _len_0 = 1
  for m in str:gmatch("(.-)" .. delim) do
    _accum_0[_len_0] = m
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
local dump
dump = function(what)
  local seen = { }
  local _dump
  _dump = function(what, depth)
    if depth == nil then
      depth = 0
    end
    local t = type(what)
    if t == "string" then
      return '"' .. what .. '"\n'
    elseif t == "table" then
      if seen[what] then
        return "recursion(" .. tostring(what) .. ")...\n"
      end
      seen[what] = true
      depth = depth + 1
      local lines
      do
        local _accum_0 = { }
        local _len_0 = 1
        for k, v in pairs(what) do
          _accum_0[_len_0] = (" "):rep(depth * 4) .. "[" .. tostring(k) .. "] = " .. _dump(v, depth)
          _len_0 = _len_0 + 1
        end
        lines = _accum_0
      end
      seen[what] = false
      local class_name
      if what.__class then
        class_name = "<" .. tostring(what.__class.__name) .. ">"
      end
      return tostring(class_name or "") .. "{\n" .. concat(lines) .. (" "):rep((depth - 1) * 4) .. "}\n"
    else
      return tostring(what) .. "\n"
    end
  end
  return _dump(what)
end
local debug_posmap
debug_posmap = function(posmap, moon_code, lua_code)
  local tuples
  do
    local _accum_0 = { }
    local _len_0 = 1
    for k, v in pairs(posmap) do
      _accum_0[_len_0] = {
        k,
        v
      }
      _len_0 = _len_0 + 1
    end
    tuples = _accum_0
  end
  table.sort(tuples, function(a, b)
    return a[1] < b[1]
  end)
  local lines
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #tuples do
      local pair = tuples[_index_0]
      local lua_line, pos = unpack(pair)
      local moon_line = pos_to_line(moon_code, pos)
      local lua_text = get_line(lua_code, lua_line)
      local moon_text = get_closest_line(moon_code, moon_line)
      local _value_0 = tostring(pos) .. "\t " .. tostring(lua_line) .. ":[ " .. tostring(trim(lua_text)) .. " ] >> " .. tostring(moon_line) .. ":[ " .. tostring(trim(moon_text)) .. " ]"
      _accum_0[_len_0] = _value_0
      _len_0 = _len_0 + 1
    end
    lines = _accum_0
  end
  return concat(lines, "\n")
end
local setfenv = setfenv or function(fn, env)
  local name
  local i = 1
  while true do
    name = debug.getupvalue(fn, i)
    if not name or name == "_ENV" then
      break
    end
    i = i + 1
  end
  if name then
    debug.upvaluejoin(fn, i, (function()
      return env
    end), 1)
  end
  return fn
end
local getfenv = getfenv or function(fn)
  local i = 1
  while true do
    local name, val = debug.getupvalue(fn, i)
    if not (name) then
      break
    end
    if name == "_ENV" then
      return val
    end
    i = i + 1
  end
  return nil
end
local get_options
get_options = function(...)
  local count = select("#", ...)
  local opts = select(count, ...)
  if type(opts) == "table" then
    return opts, unpack({
      ...
    }, nil, count - 1)
  else
    return { }, ...
  end
end
local safe_module
safe_module = function(name, tbl)
  return setmetatable(tbl, {
    __index = function(self, key)
      return error("Attempted to import non-existent `" .. tostring(key) .. "` from " .. tostring(name))
    end
  })
end
return {
  moon = moon,
  pos_to_line = pos_to_line,
  get_closest_line = get_closest_line,
  get_line = get_line,
  trim = trim,
  split = split,
  dump = dump,
  debug_posmap = debug_posmap,
  getfenv = getfenv,
  setfenv = setfenv,
  get_options = get_options,
  unpack = unpack,
  safe_module = safe_module
}
end
preload["moonscript.types"] = function(...)
local util = require("moonscript.util")
local Set
Set = require("moonscript.data").Set
local insert
insert = table.insert
local unpack
unpack = util.unpack
local manual_return = Set({
  "foreach",
  "for",
  "while",
  "return"
})
local cascading = Set({
  "if",
  "unless",
  "with",
  "switch",
  "class",
  "do"
})
local terminating = Set({
  "return",
  "break"
})
local ntype
ntype = function(node)
  local _exp_0 = type(node)
  if "nil" == _exp_0 then
    return "nil"
  elseif "table" == _exp_0 then
    return node[1]
  else
    return "value"
  end
end
local mtype
do
  local moon_type = util.moon.type
  mtype = function(val)
    local mt = getmetatable(val)
    if mt and mt.smart_node then
      return "table"
    end
    return moon_type(val)
  end
end
local value_can_be_statement
value_can_be_statement = function(node)
  if not (ntype(node) == "chain") then
    return false
  end
  return ntype(node[#node]) == "call"
end
local is_value
is_value = function(stm)
  local compile = require("moonscript.compile")
  local transform = require("moonscript.transform")
  return compile.Block:is_value(stm) or transform.Value:can_transform(stm)
end
local value_is_singular
value_is_singular = function(node)
  return type(node) ~= "table" or node[1] ~= "exp" or #node == 2
end
local is_slice
is_slice = function(node)
  return ntype(node) == "chain" and ntype(node[#node]) == "slice"
end
local t = { }
local node_types = {
  class = {
    {
      "name",
      "Tmp"
    },
    {
      "body",
      t
    }
  },
  fndef = {
    {
      "args",
      t
    },
    {
      "whitelist",
      t
    },
    {
      "arrow",
      "slim"
    },
    {
      "body",
      t
    }
  },
  foreach = {
    {
      "names",
      t
    },
    {
      "iter"
    },
    {
      "body",
      t
    }
  },
  ["for"] = {
    {
      "name"
    },
    {
      "bounds",
      t
    },
    {
      "body",
      t
    }
  },
  ["while"] = {
    {
      "cond",
      t
    },
    {
      "body",
      t
    }
  },
  assign = {
    {
      "names",
      t
    },
    {
      "values",
      t
    }
  },
  declare = {
    {
      "names",
      t
    }
  },
  ["if"] = {
    {
      "cond",
      t
    },
    {
      "then",
      t
    }
  }
}
local build_table
build_table = function()
  local key_table = { }
  for node_name, args in pairs(node_types) do
    local index = { }
    for i, tuple in ipairs(args) do
      local prop_name = tuple[1]
      index[prop_name] = i + 1
    end
    key_table[node_name] = index
  end
  return key_table
end
local key_table = build_table()
local make_builder
make_builder = function(name)
  local spec = node_types[name]
  if not spec then
    error("don't know how to build node: " .. name)
  end
  return function(props)
    if props == nil then
      props = { }
    end
    local node = {
      name
    }
    for i, arg in ipairs(spec) do
      local key, default_value = unpack(arg)
      local val
      if props[key] then
        val = props[key]
      else
        val = default_value
      end
      if val == t then
        val = { }
      end
      node[i + 1] = val
    end
    return node
  end
end
local build = nil
build = setmetatable({
  group = function(body)
    if body == nil then
      body = { }
    end
    return {
      "group",
      body
    }
  end,
  ["do"] = function(body)
    return {
      "do",
      body
    }
  end,
  assign_one = function(name, value)
    return build.assign({
      names = {
        name
      },
      values = {
        value
      }
    })
  end,
  table = function(tbl)
    if tbl == nil then
      tbl = { }
    end
    for _index_0 = 1, #tbl do
      local tuple = tbl[_index_0]
      if type(tuple[1]) == "string" then
        tuple[1] = {
          "key_literal",
          tuple[1]
        }
      end
    end
    return {
      "table",
      tbl
    }
  end,
  block_exp = function(body)
    return {
      "block_exp",
      body
    }
  end,
  chain = function(parts)
    local base = parts.base or error("expecting base property for chain")
    if type(base) == "string" then
      base = {
        "ref",
        base
      }
    end
    local node = {
      "chain",
      base
    }
    for _index_0 = 1, #parts do
      local part = parts[_index_0]
      insert(node, part)
    end
    return node
  end
}, {
  __index = function(self, name)
    self[name] = make_builder(name)
    return rawget(self, name)
  end
})
local smart_node_mt = setmetatable({ }, {
  __index = function(self, node_type)
    local index = key_table[node_type]
    local mt = {
      smart_node = true,
      __index = function(node, key)
        if index[key] then
          return rawget(node, index[key])
        elseif type(key) == "string" then
          return error("unknown key: `" .. key .. "` on node type: `" .. ntype(node) .. "`")
        end
      end,
      __newindex = function(node, key, value)
        if index[key] then
          key = index[key]
        end
        return rawset(node, key, value)
      end
    }
    self[node_type] = mt
    return mt
  end
})
local smart_node
smart_node = function(node)
  return setmetatable(node, smart_node_mt[ntype(node)])
end
local NOOP = {
  "noop"
}
return {
  ntype = ntype,
  smart_node = smart_node,
  build = build,
  is_value = is_value,
  is_slice = is_slice,
  manual_return = manual_return,
  cascading = cascading,
  value_is_singular = value_is_singular,
  value_can_be_statement = value_can_be_statement,
  mtype = mtype,
  terminating = terminating,
  NOOP = NOOP
}
end
preload["moonscript.transform"] = function(...)
return {
  Statement = require("moonscript.transform.statement"),
  Value = require("moonscript.transform.value")
}
end
preload["moonscript.transform.value"] = function(...)
local Transformer
Transformer = require("moonscript.transform.transformer").Transformer
local build, ntype, smart_node
do
  local _obj_0 = require("moonscript.types")
  build, ntype, smart_node = _obj_0.build, _obj_0.ntype, _obj_0.smart_node
end
local NameProxy
NameProxy = require("moonscript.transform.names").NameProxy
local Accumulator, default_accumulator
do
  local _obj_0 = require("moonscript.transform.accumulator")
  Accumulator, default_accumulator = _obj_0.Accumulator, _obj_0.default_accumulator
end
local lua_keywords
lua_keywords = require("moonscript.data").lua_keywords
local Run, transform_last_stm, implicitly_return, chain_is_stub
do
  local _obj_0 = require("moonscript.transform.statements")
  Run, transform_last_stm, implicitly_return, chain_is_stub = _obj_0.Run, _obj_0.transform_last_stm, _obj_0.implicitly_return, _obj_0.chain_is_stub
end
local construct_comprehension
construct_comprehension = require("moonscript.transform.comprehension").construct_comprehension
local insert
insert = table.insert
local unpack
unpack = require("moonscript.util").unpack
return Transformer({
  ["for"] = default_accumulator,
  ["while"] = default_accumulator,
  foreach = default_accumulator,
  ["do"] = function(self, node)
    return build.block_exp(node[2])
  end,
  decorated = function(self, node)
    return self.transform.statement(node)
  end,
  class = function(self, node)
    return build.block_exp({
      node
    })
  end,
  string = function(self, node)
    local delim = node[2]
    local convert_part
    convert_part = function(part)
      if type(part) == "string" or part == nil then
        return {
          "string",
          delim,
          part or ""
        }
      else
        return build.chain({
          base = "tostring",
          {
            "call",
            {
              part[2]
            }
          }
        })
      end
    end
    if #node <= 3 then
      if type(node[3]) == "string" then
        return node
      else
        return convert_part(node[3])
      end
    end
    local e = {
      "exp",
      convert_part(node[3])
    }
    for i = 4, #node do
      insert(e, "..")
      insert(e, convert_part(node[i]))
    end
    return e
  end,
  comprehension = function(self, node)
    local a = Accumulator()
    node = self.transform.statement(node, function(exp)
      return a:mutate_body({
        exp
      })
    end)
    return a:wrap(node)
  end,
  tblcomprehension = function(self, node)
    local explist, clauses = unpack(node, 2)
    local key_exp, value_exp = unpack(explist)
    local accum = NameProxy("tbl")
    local inner
    if value_exp then
      local dest = build.chain({
        base = accum,
        {
          "index",
          key_exp
        }
      })
      inner = {
        build.assign_one(dest, value_exp)
      }
    else
      local key_name, val_name = NameProxy("key"), NameProxy("val")
      local dest = build.chain({
        base = accum,
        {
          "index",
          key_name
        }
      })
      inner = {
        build.assign({
          names = {
            key_name,
            val_name
          },
          values = {
            key_exp
          }
        }),
        build.assign_one(dest, val_name)
      }
    end
    return build.block_exp({
      build.assign_one(accum, build.table()),
      construct_comprehension(inner, clauses),
      accum
    })
  end,
  fndef = function(self, node)
    smart_node(node)
    node.body = transform_last_stm(node.body, implicitly_return(self))
    node.body = {
      Run(function(self)
        return self:listen("varargs", function() end)
      end),
      unpack(node.body)
    }
    return node
  end,
  ["if"] = function(self, node)
    return build.block_exp({
      node
    })
  end,
  unless = function(self, node)
    return build.block_exp({
      node
    })
  end,
  with = function(self, node)
    return build.block_exp({
      node
    })
  end,
  switch = function(self, node)
    return build.block_exp({
      node
    })
  end,
  chain = function(self, node)
    for i = 2, #node do
      local part = node[i]
      if ntype(part) == "dot" and lua_keywords[part[2]] then
        node[i] = {
          "index",
          {
            "string",
            '"',
            part[2]
          }
        }
      end
    end
    if ntype(node[2]) == "string" then
      node[2] = {
        "parens",
        node[2]
      }
    end
    if chain_is_stub(node) then
      local base_name = NameProxy("base")
      local fn_name = NameProxy("fn")
      local colon = table.remove(node)
      local is_super = ntype(node[2]) == "ref" and node[2][2] == "super"
      return build.block_exp({
        build.assign({
          names = {
            base_name
          },
          values = {
            node
          }
        }),
        build.assign({
          names = {
            fn_name
          },
          values = {
            build.chain({
              base = base_name,
              {
                "dot",
                colon[2]
              }
            })
          }
        }),
        build.fndef({
          args = {
            {
              "..."
            }
          },
          body = {
            build.chain({
              base = fn_name,
              {
                "call",
                {
                  is_super and "self" or base_name,
                  "..."
                }
              }
            })
          }
        })
      })
    end
  end,
  block_exp = function(self, node)
    local body = unpack(node, 2)
    local fn = nil
    local arg_list = { }
    fn = smart_node(build.fndef({
      body = {
        Run(function(self)
          return self:listen("varargs", function()
            insert(arg_list, "...")
            insert(fn.args, {
              "..."
            })
            return self:unlisten("varargs")
          end)
        end),
        unpack(body)
      }
    }))
    return build.chain({
      base = {
        "parens",
        fn
      },
      {
        "call",
        arg_list
      }
    })
  end
})
end
preload["moonscript.transform.transformer"] = function(...)
local ntype
ntype = require("moonscript.types").ntype
local Transformer
do
  local _class_0
  local _base_0 = {
    transform_once = function(self, scope, node, ...)
      if self.seen_nodes[node] then
        return node
      end
      self.seen_nodes[node] = true
      local transformer = self.transformers[ntype(node)]
      if transformer then
        return transformer(scope, node, ...) or node
      else
        return node
      end
    end,
    transform = function(self, scope, node, ...)
      if self.seen_nodes[node] then
        return node
      end
      self.seen_nodes[node] = true
      while true do
        local transformer = self.transformers[ntype(node)]
        local res
        if transformer then
          res = transformer(scope, node, ...) or node
        else
          res = node
        end
        if res == node then
          return node
        end
        node = res
      end
      return node
    end,
    bind = function(self, scope)
      return function(...)
        return self:transform(scope, ...)
      end
    end,
    __call = function(self, ...)
      return self:transform(...)
    end,
    can_transform = function(self, node)
      return self.transformers[ntype(node)] ~= nil
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, transformers)
      self.transformers = transformers
      self.seen_nodes = setmetatable({ }, {
        __mode = "k"
      })
    end,
    __base = _base_0,
    __name = "Transformer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Transformer = _class_0
end
return {
  Transformer = Transformer
}
end
preload["moonscript.transform.statements"] = function(...)
local types = require("moonscript.types")
local ntype, mtype, is_value, NOOP
ntype, mtype, is_value, NOOP = types.ntype, types.mtype, types.is_value, types.NOOP
local comprehension_has_value
comprehension_has_value = require("moonscript.transform.comprehension").comprehension_has_value
local Run
do
  local _class_0
  local _base_0 = {
    call = function(self, state)
      return self.fn(state)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, fn)
      self.fn = fn
      self[1] = "run"
    end,
    __base = _base_0,
    __name = "Run"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Run = _class_0
end
local last_stm
last_stm = function(stms)
  local last_exp_id = 0
  for i = #stms, 1, -1 do
    local stm = stms[i]
    if stm and mtype(stm) ~= Run then
      if ntype(stm) == "group" then
        return last_stm(stm[2])
      end
      last_exp_id = i
      break
    end
  end
  return stms[last_exp_id], last_exp_id, stms
end
local transform_last_stm
transform_last_stm = function(stms, fn)
  local _, last_idx, _stms = last_stm(stms)
  if _stms ~= stms then
    error("cannot transform last node in group")
  end
  return (function()
    local _accum_0 = { }
    local _len_0 = 1
    for i, stm in ipairs(stms) do
      if i == last_idx then
        _accum_0[_len_0] = {
          "transform",
          stm,
          fn
        }
      else
        _accum_0[_len_0] = stm
      end
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)()
end
local chain_is_stub
chain_is_stub = function(chain)
  local stub = chain[#chain]
  return stub and ntype(stub) == "colon"
end
local implicitly_return
implicitly_return = function(scope)
  local is_top = true
  local fn
  fn = function(stm)
    local t = ntype(stm)
    if t == "decorated" then
      stm = scope.transform.statement(stm)
      t = ntype(stm)
    end
    if types.cascading[t] then
      is_top = false
      return scope.transform.statement(stm, fn)
    elseif types.manual_return[t] or not is_value(stm) then
      if is_top and t == "return" and stm[2] == "" then
        return NOOP
      else
        return stm
      end
    else
      if t == "comprehension" and not comprehension_has_value(stm) then
        return stm
      else
        return {
          "return",
          stm
        }
      end
    end
  end
  return fn
end
return {
  Run = Run,
  last_stm = last_stm,
  transform_last_stm = transform_last_stm,
  chain_is_stub = chain_is_stub,
  implicitly_return = implicitly_return
}
end
preload["moonscript.transform.statement"] = function(...)
local Transformer
Transformer = require("moonscript.transform.transformer").Transformer
local NameProxy, LocalName, is_name_proxy
do
  local _obj_0 = require("moonscript.transform.names")
  NameProxy, LocalName, is_name_proxy = _obj_0.NameProxy, _obj_0.LocalName, _obj_0.is_name_proxy
end
local Run, transform_last_stm, implicitly_return, last_stm
do
  local _obj_0 = require("moonscript.transform.statements")
  Run, transform_last_stm, implicitly_return, last_stm = _obj_0.Run, _obj_0.transform_last_stm, _obj_0.implicitly_return, _obj_0.last_stm
end
local types = require("moonscript.types")
local build, ntype, is_value, smart_node, value_is_singular, is_slice, NOOP
build, ntype, is_value, smart_node, value_is_singular, is_slice, NOOP = types.build, types.ntype, types.is_value, types.smart_node, types.value_is_singular, types.is_slice, types.NOOP
local insert
insert = table.insert
local destructure = require("moonscript.transform.destructure")
local construct_comprehension
construct_comprehension = require("moonscript.transform.comprehension").construct_comprehension
local unpack
unpack = require("moonscript.util").unpack
local with_continue_listener
with_continue_listener = function(body)
  local continue_name = nil
  return {
    Run(function(self)
      return self:listen("continue", function()
        if not (continue_name) then
          continue_name = NameProxy("continue")
          self:put_name(continue_name)
        end
        return continue_name
      end)
    end),
    build.group(body),
    Run(function(self)
      if not (continue_name) then
        return 
      end
      local last = last_stm(body)
      local enclose_lines = types.terminating[last and ntype(last)]
      self:put_name(continue_name, nil)
      return self:splice(function(lines)
        if enclose_lines then
          lines = {
            "do",
            {
              lines
            }
          }
        end
        return {
          {
            "assign",
            {
              continue_name
            },
            {
              "false"
            }
          },
          {
            "repeat",
            "true",
            {
              lines,
              {
                "assign",
                {
                  continue_name
                },
                {
                  "true"
                }
              }
            }
          },
          {
            "if",
            {
              "not",
              continue_name
            },
            {
              {
                "break"
              }
            }
          }
        }
      end)
    end)
  }
end
local extract_declarations
extract_declarations = function(self, body, start, out)
  if body == nil then
    body = self.current_stms
  end
  if start == nil then
    start = self.current_stm_i + 1
  end
  if out == nil then
    out = { }
  end
  for i = start, #body do
    local _continue_0 = false
    repeat
      local stm = body[i]
      if stm == nil then
        _continue_0 = true
        break
      end
      stm = self.transform.statement(stm)
      body[i] = stm
      local _exp_0 = stm[1]
      if "assign" == _exp_0 or "declare" == _exp_0 then
        local _list_0 = stm[2]
        for _index_0 = 1, #_list_0 do
          local name = _list_0[_index_0]
          if ntype(name) == "ref" then
            insert(out, name)
          elseif type(name) == "string" then
            insert(out, name)
          end
        end
      elseif "group" == _exp_0 then
        extract_declarations(self, stm[2], 1, out)
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return out
end
local expand_elseif_assign
expand_elseif_assign = function(ifstm)
  for i = 4, #ifstm do
    local case = ifstm[i]
    if ntype(case) == "elseif" and ntype(case[2]) == "assign" then
      local split = {
        unpack(ifstm, 1, i - 1)
      }
      insert(split, {
        "else",
        {
          {
            "if",
            case[2],
            case[3],
            unpack(ifstm, i + 1)
          }
        }
      })
      return split
    end
  end
  return ifstm
end
return Transformer({
  transform = function(self, tuple)
    local _, node, fn
    _, node, fn = tuple[1], tuple[2], tuple[3]
    return fn(node)
  end,
  root_stms = function(self, body)
    return transform_last_stm(body, implicitly_return(self))
  end,
  ["return"] = function(self, node)
    local ret_val = node[2]
    local ret_val_type = ntype(ret_val)
    if ret_val_type == "explist" and #ret_val == 2 then
      ret_val = ret_val[2]
      ret_val_type = ntype(ret_val)
    end
    if types.cascading[ret_val_type] then
      return implicitly_return(self)(ret_val)
    end
    if ret_val_type == "chain" or ret_val_type == "comprehension" or ret_val_type == "tblcomprehension" then
      local Value = require("moonscript.transform.value")
      ret_val = Value:transform_once(self, ret_val)
      if ntype(ret_val) == "block_exp" then
        return build.group(transform_last_stm(ret_val[2], function(stm)
          return {
            "return",
            stm
          }
        end))
      end
    end
    node[2] = ret_val
    return node
  end,
  declare_glob = function(self, node)
    local names = extract_declarations(self)
    if node[2] == "^" then
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #names do
          local _continue_0 = false
          repeat
            local name = names[_index_0]
            local str_name
            if ntype(name) == "ref" then
              str_name = name[2]
            else
              str_name = name
            end
            if not (str_name:match("^%u")) then
              _continue_0 = true
              break
            end
            local _value_0 = name
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        names = _accum_0
      end
    end
    return {
      "declare",
      names
    }
  end,
  assign = function(self, node)
    local names, values = unpack(node, 2)
    local num_values = #values
    local num_names = #values
    if num_names == 1 and num_values == 1 then
      local first_value = values[1]
      local first_name = names[1]
      local first_type = ntype(first_value)
      if first_type == "chain" then
        local Value = require("moonscript.transform.value")
        first_value = Value:transform_once(self, first_value)
        first_type = ntype(first_value)
      end
      local _exp_0 = ntype(first_value)
      if "block_exp" == _exp_0 then
        local block_body = first_value[2]
        local idx = #block_body
        block_body[idx] = build.assign_one(first_name, block_body[idx])
        return build.group({
          {
            "declare",
            {
              first_name
            }
          },
          {
            "do",
            block_body
          }
        })
      elseif "comprehension" == _exp_0 or "tblcomprehension" == _exp_0 or "foreach" == _exp_0 or "for" == _exp_0 or "while" == _exp_0 then
        local Value = require("moonscript.transform.value")
        return build.assign_one(first_name, Value:transform_once(self, first_value))
      else
        values[1] = first_value
      end
    end
    local transformed
    if num_values == 1 then
      local value = values[1]
      local t = ntype(value)
      if t == "decorated" then
        value = self.transform.statement(value)
        t = ntype(value)
      end
      if types.cascading[t] then
        local ret
        ret = function(stm)
          if is_value(stm) then
            return {
              "assign",
              names,
              {
                stm
              }
            }
          else
            return stm
          end
        end
        transformed = build.group({
          {
            "declare",
            names
          },
          self.transform.statement(value, ret, node)
        })
      end
    end
    node = transformed or node
    if destructure.has_destructure(names) then
      return destructure.split_assign(self, node)
    end
    return node
  end,
  continue = function(self, node)
    local continue_name = self:send("continue")
    if not (continue_name) then
      error("continue must be inside of a loop")
    end
    return build.group({
      build.assign_one(continue_name, "true"),
      {
        "break"
      }
    })
  end,
  export = function(self, node)
    if #node > 2 then
      if node[2] == "class" then
        local cls = smart_node(node[3])
        return build.group({
          {
            "export",
            {
              cls.name
            }
          },
          cls
        })
      else
        return build.group({
          {
            "export",
            node[2]
          },
          build.assign({
            names = node[2],
            values = node[3]
          })
        })
      end
    else
      return nil
    end
  end,
  update = function(self, node)
    local name, op, exp = unpack(node, 2)
    local op_final = op:match("^(.+)=$")
    if not op_final then
      error("Unknown op: " .. op)
    end
    local lifted
    if ntype(name) == "chain" then
      lifted = { }
      local new_chain
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 3, #name do
          local part = name[_index_0]
          if ntype(part) == "index" then
            local proxy = NameProxy("update")
            table.insert(lifted, {
              proxy,
              part[2]
            })
            _accum_0[_len_0] = {
              "index",
              proxy
            }
          else
            _accum_0[_len_0] = part
          end
          _len_0 = _len_0 + 1
        end
        new_chain = _accum_0
      end
      if next(lifted) then
        name = {
          name[1],
          name[2],
          unpack(new_chain)
        }
      end
    end
    if not (value_is_singular(exp)) then
      exp = {
        "parens",
        exp
      }
    end
    local out = build.assign_one(name, {
      "exp",
      name,
      op_final,
      exp
    })
    if lifted and next(lifted) then
      local names
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #lifted do
          local l = lifted[_index_0]
          _accum_0[_len_0] = l[1]
          _len_0 = _len_0 + 1
        end
        names = _accum_0
      end
      local values
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #lifted do
          local l = lifted[_index_0]
          _accum_0[_len_0] = l[2]
          _len_0 = _len_0 + 1
        end
        values = _accum_0
      end
      out = build.group({
        {
          "assign",
          names,
          values
        },
        out
      })
    end
    return out
  end,
  import = function(self, node)
    local names, source = unpack(node, 2)
    local table_values
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #names do
        local name = names[_index_0]
        local dest_name
        if ntype(name) == "colon" then
          dest_name = name[2]
        else
          dest_name = name
        end
        local _value_0 = {
          {
            "key_literal",
            name
          },
          dest_name
        }
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
      end
      table_values = _accum_0
    end
    local dest = {
      "table",
      table_values
    }
    return {
      "assign",
      {
        dest
      },
      {
        source
      },
      [-1] = node[-1]
    }
  end,
  comprehension = function(self, node, action)
    local exp, clauses = unpack(node, 2)
    action = action or function(exp)
      return {
        exp
      }
    end
    return construct_comprehension(action(exp), clauses)
  end,
  ["do"] = function(self, node, ret)
    if ret then
      node[2] = transform_last_stm(node[2], ret)
    end
    return node
  end,
  decorated = function(self, node)
    local stm, dec = unpack(node, 2)
    local wrapped
    local _exp_0 = dec[1]
    if "if" == _exp_0 then
      local cond, fail = unpack(dec, 2)
      if fail then
        fail = {
          "else",
          {
            fail
          }
        }
      end
      wrapped = {
        "if",
        cond,
        {
          stm
        },
        fail
      }
    elseif "unless" == _exp_0 then
      wrapped = {
        "unless",
        dec[2],
        {
          stm
        }
      }
    elseif "comprehension" == _exp_0 then
      wrapped = {
        "comprehension",
        stm,
        dec[2]
      }
    else
      wrapped = error("Unknown decorator " .. dec[1])
    end
    if ntype(stm) == "assign" then
      wrapped = build.group({
        build.declare({
          names = (function()
            local _accum_0 = { }
            local _len_0 = 1
            local _list_0 = stm[2]
            for _index_0 = 1, #_list_0 do
              local name = _list_0[_index_0]
              if ntype(name) == "ref" then
                _accum_0[_len_0] = name
                _len_0 = _len_0 + 1
              end
            end
            return _accum_0
          end)()
        }),
        wrapped
      })
    end
    return wrapped
  end,
  unless = function(self, node)
    local clause = node[2]
    if ntype(clause) == "assign" then
      if destructure.has_destructure(clause[2]) then
        error("destructure not allowed in unless assignment")
      end
      return build["do"]({
        clause,
        {
          "if",
          {
            "not",
            clause[2][1]
          },
          unpack(node, 3)
        }
      })
    else
      return {
        "if",
        {
          "not",
          {
            "parens",
            clause
          }
        },
        unpack(node, 3)
      }
    end
  end,
  ["if"] = function(self, node, ret)
    if ntype(node[2]) == "assign" then
      local assign, body = unpack(node, 2)
      if destructure.has_destructure(assign[2]) then
        local name = NameProxy("des")
        body = {
          destructure.build_assign(self, assign[2][1], name),
          build.group(node[3])
        }
        return build["do"]({
          build.assign_one(name, assign[3][1]),
          {
            "if",
            name,
            body,
            unpack(node, 4)
          }
        })
      else
        local name = assign[2][1]
        return build["do"]({
          assign,
          {
            "if",
            name,
            unpack(node, 3)
          }
        })
      end
    end
    node = expand_elseif_assign(node)
    if ret then
      smart_node(node)
      node['then'] = transform_last_stm(node['then'], ret)
      for i = 4, #node do
        local case = node[i]
        local body_idx = #node[i]
        case[body_idx] = transform_last_stm(case[body_idx], ret)
      end
    end
    return node
  end,
  with = function(self, node, ret)
    local exp, block = unpack(node, 2)
    local copy_scope = true
    local scope_name, named_assign
    do
      local last = last_stm(block)
      if last then
        if types.terminating[ntype(last)] then
          ret = false
        end
      end
    end
    if ntype(exp) == "assign" then
      local names, values = unpack(exp, 2)
      local first_name = names[1]
      if ntype(first_name) == "ref" then
        scope_name = first_name
        named_assign = exp
        exp = values[1]
        copy_scope = false
      else
        scope_name = NameProxy("with")
        exp = values[1]
        values[1] = scope_name
        named_assign = {
          "assign",
          names,
          values
        }
      end
    elseif self:is_local(exp) then
      scope_name = exp
      copy_scope = false
    end
    scope_name = scope_name or NameProxy("with")
    local out = build["do"]({
      copy_scope and build.assign_one(scope_name, exp) or NOOP,
      named_assign or NOOP,
      Run(function(self)
        return self:set("scope_var", scope_name)
      end),
      unpack(block)
    })
    if ret then
      table.insert(out[2], ret(scope_name))
    end
    return out
  end,
  foreach = function(self, node, _)
    smart_node(node)
    local source = unpack(node.iter)
    local destructures = { }
    do
      local _accum_0 = { }
      local _len_0 = 1
      for i, name in ipairs(node.names) do
        if ntype(name) == "table" then
          do
            local proxy = NameProxy("des")
            insert(destructures, destructure.build_assign(self, name, proxy))
            _accum_0[_len_0] = proxy
          end
        else
          _accum_0[_len_0] = name
        end
        _len_0 = _len_0 + 1
      end
      node.names = _accum_0
    end
    if next(destructures) then
      insert(destructures, build.group(node.body))
      node.body = destructures
    end
    if ntype(source) == "unpack" then
      local list = source[2]
      local index_name = NameProxy("index")
      local list_name = self:is_local(list) and list or NameProxy("list")
      local slice_var = nil
      local bounds
      if is_slice(list) then
        local slice = list[#list]
        table.remove(list)
        table.remove(slice, 1)
        if self:is_local(list) then
          list_name = list
        end
        if slice[2] and slice[2] ~= "" then
          local max_tmp_name = NameProxy("max")
          slice_var = build.assign_one(max_tmp_name, slice[2])
          slice[2] = {
            "exp",
            max_tmp_name,
            "<",
            0,
            "and",
            {
              "length",
              list_name
            },
            "+",
            max_tmp_name,
            "or",
            max_tmp_name
          }
        else
          slice[2] = {
            "length",
            list_name
          }
        end
        bounds = slice
      else
        bounds = {
          1,
          {
            "length",
            list_name
          }
        }
      end
      local names
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = node.names
        for _index_0 = 1, #_list_0 do
          local n = _list_0[_index_0]
          _accum_0[_len_0] = is_name_proxy(n) and n or LocalName(n) or n
          _len_0 = _len_0 + 1
        end
        names = _accum_0
      end
      return build.group({
        list_name ~= list and build.assign_one(list_name, list) or NOOP,
        slice_var or NOOP,
        build["for"]({
          name = index_name,
          bounds = bounds,
          body = {
            {
              "assign",
              names,
              {
                NameProxy.index(list_name, index_name)
              }
            },
            build.group(node.body)
          }
        })
      })
    end
    node.body = with_continue_listener(node.body)
  end,
  ["while"] = function(self, node)
    smart_node(node)
    node.body = with_continue_listener(node.body)
  end,
  ["for"] = function(self, node)
    smart_node(node)
    node.body = with_continue_listener(node.body)
  end,
  switch = function(self, node, ret)
    local exp, conds = unpack(node, 2)
    local exp_name = NameProxy("exp")
    local convert_cond
    convert_cond = function(cond)
      local t, case_exps, body = unpack(cond)
      local out = { }
      insert(out, t == "case" and "elseif" or "else")
      if t ~= "else" then
        local cond_exp = { }
        for i, case in ipairs(case_exps) do
          if i == 1 then
            insert(cond_exp, "exp")
          else
            insert(cond_exp, "or")
          end
          if not (value_is_singular(case)) then
            case = {
              "parens",
              case
            }
          end
          insert(cond_exp, {
            "exp",
            case,
            "==",
            exp_name
          })
        end
        insert(out, cond_exp)
      else
        body = case_exps
      end
      if ret then
        body = transform_last_stm(body, ret)
      end
      insert(out, body)
      return out
    end
    local first = true
    local if_stm = {
      "if"
    }
    for _index_0 = 1, #conds do
      local cond = conds[_index_0]
      local if_cond = convert_cond(cond)
      if first then
        first = false
        insert(if_stm, if_cond[2])
        insert(if_stm, if_cond[3])
      else
        insert(if_stm, if_cond)
      end
    end
    return build.group({
      build.assign_one(exp_name, exp),
      if_stm
    })
  end,
  class = require("moonscript.transform.class")
})
end
preload["moonscript.transform.names"] = function(...)
local build
build = require("moonscript.types").build
local unpack
unpack = require("moonscript.util").unpack
local LocalName
do
  local _class_0
  local _base_0 = {
    get_name = function(self)
      return self.name
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name)
      self.name = name
      self[1] = "temp_name"
    end,
    __base = _base_0,
    __name = "LocalName"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  LocalName = _class_0
end
local NameProxy
do
  local _class_0
  local _base_0 = {
    get_name = function(self, scope, dont_put)
      if dont_put == nil then
        dont_put = true
      end
      if not self.name then
        self.name = scope:free_name(self.prefix, dont_put)
      end
      return self.name
    end,
    chain = function(self, ...)
      local items = {
        base = self,
        ...
      }
      for k, v in ipairs(items) do
        if type(v) == "string" then
          items[k] = {
            "dot",
            v
          }
        else
          items[k] = v
        end
      end
      return build.chain(items)
    end,
    index = function(self, key)
      if type(key) == "string" then
        key = {
          "ref",
          key
        }
      end
      return build.chain({
        base = self,
        {
          "index",
          key
        }
      })
    end,
    __tostring = function(self)
      if self.name then
        return ("name<%s>"):format(self.name)
      else
        return ("name<prefix(%s)>"):format(self.prefix)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, prefix)
      self.prefix = prefix
      self[1] = "temp_name"
    end,
    __base = _base_0,
    __name = "NameProxy"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  NameProxy = _class_0
end
local is_name_proxy
is_name_proxy = function(v)
  if not (type(v) == "table") then
    return false
  end
  local _exp_0 = v.__class
  if LocalName == _exp_0 or NameProxy == _exp_0 then
    return true
  end
end
return {
  NameProxy = NameProxy,
  LocalName = LocalName,
  is_name_proxy = is_name_proxy
}
end
preload["moonscript.transform.destructure"] = function(...)
local ntype, mtype, build
do
  local _obj_0 = require("moonscript.types")
  ntype, mtype, build = _obj_0.ntype, _obj_0.mtype, _obj_0.build
end
local NameProxy
NameProxy = require("moonscript.transform.names").NameProxy
local insert
insert = table.insert
local unpack
unpack = require("moonscript.util").unpack
local user_error
user_error = require("moonscript.errors").user_error
local join
join = function(...)
  do
    local out = { }
    local i = 1
    local _list_0 = {
      ...
    }
    for _index_0 = 1, #_list_0 do
      local tbl = _list_0[_index_0]
      for _index_1 = 1, #tbl do
        local v = tbl[_index_1]
        out[i] = v
        i = i + 1
      end
    end
    return out
  end
end
local has_destructure
has_destructure = function(names)
  for _index_0 = 1, #names do
    local n = names[_index_0]
    if ntype(n) == "table" then
      return true
    end
  end
  return false
end
local extract_assign_names
extract_assign_names = function(name, accum, prefix)
  if accum == nil then
    accum = { }
  end
  if prefix == nil then
    prefix = { }
  end
  local i = 1
  local _list_0 = name[2]
  for _index_0 = 1, #_list_0 do
    local tuple = _list_0[_index_0]
    local value, suffix
    if #tuple == 1 then
      local s = {
        "index",
        {
          "number",
          i
        }
      }
      i = i + 1
      value, suffix = tuple[1], s
    else
      local key = tuple[1]
      local s
      if ntype(key) == "key_literal" then
        local key_name = key[2]
        if ntype(key_name) == "colon" then
          s = key_name
        else
          s = {
            "dot",
            key_name
          }
        end
      else
        s = {
          "index",
          key
        }
      end
      value, suffix = tuple[2], s
    end
    suffix = join(prefix, {
      suffix
    })
    local _exp_0 = ntype(value)
    if "value" == _exp_0 or "ref" == _exp_0 or "chain" == _exp_0 or "self" == _exp_0 then
      insert(accum, {
        value,
        suffix
      })
    elseif "table" == _exp_0 then
      extract_assign_names(value, accum, suffix)
    else
      user_error("Can't destructure value of type: " .. tostring(ntype(value)))
    end
  end
  return accum
end
local build_assign
build_assign = function(scope, destruct_literal, receiver)
  assert(receiver, "attempting to build destructure assign with no receiver")
  local extracted_names = extract_assign_names(destruct_literal)
  local names = { }
  local values = { }
  local inner = {
    "assign",
    names,
    values
  }
  local obj
  if scope:is_local(receiver) or #extracted_names == 1 then
    obj = receiver
  else
    do
      obj = NameProxy("obj")
      inner = build["do"]({
        build.assign_one(obj, receiver),
        {
          "assign",
          names,
          values
        }
      })
      obj = obj
    end
  end
  for _index_0 = 1, #extracted_names do
    local tuple = extracted_names[_index_0]
    insert(names, tuple[1])
    local chain
    if obj then
      chain = NameProxy.chain(obj, unpack(tuple[2]))
    else
      chain = "nil"
    end
    insert(values, chain)
  end
  return build.group({
    {
      "declare",
      names
    },
    inner
  })
end
local split_assign
split_assign = function(scope, assign)
  local names, values = unpack(assign, 2)
  local g = { }
  local total_names = #names
  local total_values = #values
  local start = 1
  for i, n in ipairs(names) do
    if ntype(n) == "table" then
      if i > start then
        local stop = i - 1
        insert(g, {
          "assign",
          (function()
            local _accum_0 = { }
            local _len_0 = 1
            for i = start, stop do
              _accum_0[_len_0] = names[i]
              _len_0 = _len_0 + 1
            end
            return _accum_0
          end)(),
          (function()
            local _accum_0 = { }
            local _len_0 = 1
            for i = start, stop do
              _accum_0[_len_0] = values[i]
              _len_0 = _len_0 + 1
            end
            return _accum_0
          end)()
        })
      end
      insert(g, build_assign(scope, n, values[i]))
      start = i + 1
    end
  end
  if total_names >= start or total_values >= start then
    local name_slice
    if total_names < start then
      name_slice = {
        "_"
      }
    else
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = start, total_names do
          _accum_0[_len_0] = names[i]
          _len_0 = _len_0 + 1
        end
        name_slice = _accum_0
      end
    end
    local value_slice
    if total_values < start then
      value_slice = {
        "nil"
      }
    else
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = start, total_values do
          _accum_0[_len_0] = values[i]
          _len_0 = _len_0 + 1
        end
        value_slice = _accum_0
      end
    end
    insert(g, {
      "assign",
      name_slice,
      value_slice
    })
  end
  return build.group(g)
end
return {
  has_destructure = has_destructure,
  split_assign = split_assign,
  build_assign = build_assign,
  extract_assign_names = extract_assign_names
}
end
preload["moonscript.transform.comprehension"] = function(...)
local is_value
is_value = require("moonscript.types").is_value
local construct_comprehension
construct_comprehension = function(inner, clauses)
  local current_stms = inner
  for i = #clauses, 1, -1 do
    local clause = clauses[i]
    local t = clause[1]
    local _exp_0 = t
    if "for" == _exp_0 then
      local _, name, bounds
      _, name, bounds = clause[1], clause[2], clause[3]
      current_stms = {
        "for",
        name,
        bounds,
        current_stms
      }
    elseif "foreach" == _exp_0 then
      local _, names, iter
      _, names, iter = clause[1], clause[2], clause[3]
      current_stms = {
        "foreach",
        names,
        {
          iter
        },
        current_stms
      }
    elseif "when" == _exp_0 then
      local _, cond
      _, cond = clause[1], clause[2]
      current_stms = {
        "if",
        cond,
        current_stms
      }
    else
      current_stms = error("Unknown comprehension clause: " .. t)
    end
    current_stms = {
      current_stms
    }
  end
  return current_stms[1]
end
local comprehension_has_value
comprehension_has_value = function(comp)
  return is_value(comp[2])
end
return {
  construct_comprehension = construct_comprehension,
  comprehension_has_value = comprehension_has_value
}
end
preload["moonscript.transform.class"] = function(...)
local NameProxy, LocalName
do
  local _obj_0 = require("moonscript.transform.names")
  NameProxy, LocalName = _obj_0.NameProxy, _obj_0.LocalName
end
local Run
Run = require("moonscript.transform.statements").Run
local CONSTRUCTOR_NAME = "new"
local insert
insert = table.insert
local build, ntype, NOOP
do
  local _obj_0 = require("moonscript.types")
  build, ntype, NOOP = _obj_0.build, _obj_0.ntype, _obj_0.NOOP
end
local unpack
unpack = require("moonscript.util").unpack
local transform_super
transform_super = function(cls_name, on_base, block, chain)
  if on_base == nil then
    on_base = true
  end
  local relative_parent = {
    "chain",
    cls_name,
    {
      "dot",
      "__parent"
    }
  }
  if not (chain) then
    return relative_parent
  end
  local chain_tail = {
    unpack(chain, 3)
  }
  local head = chain_tail[1]
  if head == nil then
    return relative_parent
  end
  local new_chain = relative_parent
  local _exp_0 = head[1]
  if "call" == _exp_0 then
    if on_base then
      insert(new_chain, {
        "dot",
        "__base"
      })
    end
    local calling_name = block:get("current_method")
    assert(calling_name, "missing calling name")
    chain_tail[1] = {
      "call",
      {
        "self",
        unpack(head[2])
      }
    }
    if ntype(calling_name) == "key_literal" then
      insert(new_chain, {
        "dot",
        calling_name[2]
      })
    else
      insert(new_chain, {
        "index",
        calling_name
      })
    end
  elseif "colon" == _exp_0 then
    local call = chain_tail[2]
    if call and call[1] == "call" then
      chain_tail[1] = {
        "dot",
        head[2]
      }
      chain_tail[2] = {
        "call",
        {
          "self",
          unpack(call[2])
        }
      }
    end
  end
  for _index_0 = 1, #chain_tail do
    local item = chain_tail[_index_0]
    insert(new_chain, item)
  end
  return new_chain
end
local super_scope
super_scope = function(value, t, key)
  local prev_method
  return {
    "scoped",
    Run(function(self)
      prev_method = self:get("current_method")
      self:set("current_method", key)
      return self:set("super", t)
    end),
    value,
    Run(function(self)
      return self:set("current_method", prev_method)
    end)
  }
end
return function(self, node, ret, parent_assign)
  local name, parent_val, body = unpack(node, 2)
  if parent_val == "" then
    parent_val = nil
  end
  local parent_cls_name = NameProxy("parent")
  local base_name = NameProxy("base")
  local self_name = NameProxy("self")
  local cls_name = NameProxy("class")
  local cls_instance_super
  cls_instance_super = function(...)
    return transform_super(cls_name, true, ...)
  end
  local cls_super
  cls_super = function(...)
    return transform_super(cls_name, false, ...)
  end
  local statements = { }
  local properties = { }
  for _index_0 = 1, #body do
    local item = body[_index_0]
    local _exp_0 = item[1]
    if "stm" == _exp_0 then
      insert(statements, item[2])
    elseif "props" == _exp_0 then
      for _index_1 = 2, #item do
        local tuple = item[_index_1]
        if ntype(tuple[1]) == "self" then
          local k, v
          k, v = tuple[1], tuple[2]
          v = super_scope(v, cls_super, {
            "key_literal",
            k[2]
          })
          insert(statements, build.assign_one(k, v))
        else
          insert(properties, tuple)
        end
      end
    end
  end
  local constructor
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #properties do
      local _continue_0 = false
      repeat
        local tuple = properties[_index_0]
        local key = tuple[1]
        local _value_0
        if key[1] == "key_literal" and key[2] == CONSTRUCTOR_NAME then
          constructor = tuple[2]
          _continue_0 = true
          break
        else
          local val
          key, val = tuple[1], tuple[2]
          _value_0 = {
            key,
            super_scope(val, cls_instance_super, key)
          }
        end
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    properties = _accum_0
  end
  if not (constructor) then
    if parent_val then
      constructor = build.fndef({
        args = {
          {
            "..."
          }
        },
        arrow = "fat",
        body = {
          build.chain({
            base = "super",
            {
              "call",
              {
                "..."
              }
            }
          })
        }
      })
    else
      constructor = build.fndef()
    end
  end
  local real_name = name or parent_assign and parent_assign[2][1]
  local _exp_0 = ntype(real_name)
  if "chain" == _exp_0 then
    local last = real_name[#real_name]
    local _exp_1 = ntype(last)
    if "dot" == _exp_1 then
      real_name = {
        "string",
        '"',
        last[2]
      }
    elseif "index" == _exp_1 then
      real_name = last[2]
    else
      real_name = "nil"
    end
  elseif "nil" == _exp_0 then
    real_name = "nil"
  else
    local name_t = type(real_name)
    local flattened_name
    if name_t == "string" then
      flattened_name = real_name
    elseif name_t == "table" and real_name[1] == "ref" then
      flattened_name = real_name[2]
    else
      flattened_name = error("don't know how to extract name from " .. tostring(name_t))
    end
    real_name = {
      "string",
      '"',
      flattened_name
    }
  end
  local cls = build.table({
    {
      "__init",
      super_scope(constructor, cls_super, {
        "key_literal",
        "__init"
      })
    },
    {
      "__base",
      base_name
    },
    {
      "__name",
      real_name
    },
    parent_val and {
      "__parent",
      parent_cls_name
    } or nil
  })
  local class_index
  if parent_val then
    local class_lookup = build["if"]({
      cond = {
        "exp",
        {
          "ref",
          "val"
        },
        "==",
        "nil"
      },
      ["then"] = {
        build.assign_one(LocalName("parent"), build.chain({
          base = "rawget",
          {
            "call",
            {
              {
                "ref",
                "cls"
              },
              {
                "string",
                '"',
                "__parent"
              }
            }
          }
        })),
        build["if"]({
          cond = LocalName("parent"),
          ["then"] = {
            build.chain({
              base = LocalName("parent"),
              {
                "index",
                "name"
              }
            })
          }
        })
      }
    })
    insert(class_lookup, {
      "else",
      {
        "val"
      }
    })
    class_index = build.fndef({
      args = {
        {
          "cls"
        },
        {
          "name"
        }
      },
      body = {
        build.assign_one(LocalName("val"), build.chain({
          base = "rawget",
          {
            "call",
            {
              base_name,
              {
                "ref",
                "name"
              }
            }
          }
        })),
        class_lookup
      }
    })
  else
    class_index = base_name
  end
  local cls_mt = build.table({
    {
      "__index",
      class_index
    },
    {
      "__call",
      build.fndef({
        args = {
          {
            "cls"
          },
          {
            "..."
          }
        },
        body = {
          build.assign_one(self_name, build.chain({
            base = "setmetatable",
            {
              "call",
              {
                "{}",
                base_name
              }
            }
          })),
          build.chain({
            base = "cls.__init",
            {
              "call",
              {
                self_name,
                "..."
              }
            }
          }),
          self_name
        }
      })
    }
  })
  cls = build.chain({
    base = "setmetatable",
    {
      "call",
      {
        cls,
        cls_mt
      }
    }
  })
  local value = nil
  do
    local out_body = {
      Run(function(self)
        if name then
          return self:put_name(name)
        end
      end),
      {
        "declare",
        {
          cls_name
        }
      },
      {
        "declare_glob",
        "*"
      },
      parent_val and build.assign_one(parent_cls_name, parent_val) or NOOP,
      build.assign_one(base_name, {
        "table",
        properties
      }),
      build.assign_one(base_name:chain("__index"), base_name),
      parent_val and build.chain({
        base = "setmetatable",
        {
          "call",
          {
            base_name,
            build.chain({
              base = parent_cls_name,
              {
                "dot",
                "__base"
              }
            })
          }
        }
      }) or NOOP,
      build.assign_one(cls_name, cls),
      build.assign_one(base_name:chain("__class"), cls_name),
      build.group((function()
        if #statements > 0 then
          return {
            build.assign_one(LocalName("self"), cls_name),
            build.group(statements)
          }
        end
      end)()),
      parent_val and build["if"]({
        cond = {
          "exp",
          parent_cls_name:chain("__inherited")
        },
        ["then"] = {
          parent_cls_name:chain("__inherited", {
            "call",
            {
              parent_cls_name,
              cls_name
            }
          })
        }
      }) or NOOP,
      build.group((function()
        if name then
          return {
            build.assign_one(name, cls_name)
          }
        end
      end)()),
      (function()
        if ret then
          return ret(cls_name)
        end
      end)()
    }
    value = build.group({
      build.group((function()
        if ntype(name) == "value" then
          return {
            build.declare({
              names = {
                name
              }
            })
          }
        end
      end)()),
      build["do"](out_body)
    })
  end
  return value
end
end
preload["moonscript.transform.accumulator"] = function(...)
local types = require("moonscript.types")
local build, ntype, NOOP
build, ntype, NOOP = types.build, types.ntype, types.NOOP
local NameProxy
NameProxy = require("moonscript.transform.names").NameProxy
local insert
insert = table.insert
local is_singular
is_singular = function(body)
  if #body ~= 1 then
    return false
  end
  if "group" == ntype(body) then
    return is_singular(body[2])
  else
    return body[1]
  end
end
local transform_last_stm
transform_last_stm = require("moonscript.transform.statements").transform_last_stm
local Accumulator
do
  local _class_0
  local _base_0 = {
    body_idx = {
      ["for"] = 4,
      ["while"] = 3,
      foreach = 4
    },
    convert = function(self, node)
      local index = self.body_idx[ntype(node)]
      node[index] = self:mutate_body(node[index])
      return self:wrap(node)
    end,
    wrap = function(self, node, group_type)
      if group_type == nil then
        group_type = "block_exp"
      end
      return build[group_type]({
        build.assign_one(self.accum_name, build.table()),
        build.assign_one(self.len_name, 1),
        node,
        group_type == "block_exp" and self.accum_name or NOOP
      })
    end,
    mutate_body = function(self, body)
      local single_stm = is_singular(body)
      local val
      if single_stm and types.is_value(single_stm) then
        body = { }
        val = single_stm
      else
        body = transform_last_stm(body, function(n)
          if types.is_value(n) then
            return build.assign_one(self.value_name, n)
          else
            return build.group({
              {
                "declare",
                {
                  self.value_name
                }
              },
              n
            })
          end
        end)
        val = self.value_name
      end
      local update = {
        build.assign_one(NameProxy.index(self.accum_name, self.len_name), val),
        {
          "update",
          self.len_name,
          "+=",
          1
        }
      }
      insert(body, build.group(update))
      return body
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, accum_name)
      self.accum_name = NameProxy("accum")
      self.value_name = NameProxy("value")
      self.len_name = NameProxy("len")
    end,
    __base = _base_0,
    __name = "Accumulator"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Accumulator = _class_0
end
local default_accumulator
default_accumulator = function(self, node)
  return Accumulator():convert(node)
end
return {
  Accumulator = Accumulator,
  default_accumulator = default_accumulator
}
end
preload["moonscript.parse"] = function(...)
local debug_grammar = false
local lpeg = require("cc.lpeg")
lpeg.setmaxstack(10000)
local err_msg = "Failed to parse:%s\n [%d] >>    %s"
local Stack
Stack = require("moonscript.data").Stack
local trim, pos_to_line, get_line
do
  local _obj_0 = require("moonscript.util")
  trim, pos_to_line, get_line = _obj_0.trim, _obj_0.pos_to_line, _obj_0.get_line
end
local unpack
unpack = require("moonscript.util").unpack
local wrap_env
wrap_env = require("moonscript.parse.env").wrap_env
local R, S, V, P, C, Ct, Cmt, Cg, Cb, Cc
R, S, V, P, C, Ct, Cmt, Cg, Cb, Cc = lpeg.R, lpeg.S, lpeg.V, lpeg.P, lpeg.C, lpeg.Ct, lpeg.Cmt, lpeg.Cg, lpeg.Cb, lpeg.Cc
local White, Break, Stop, Comment, Space, SomeSpace, SpaceBreak, EmptyLine, AlphaNum, Num, Shebang, L, _Name
do
  local _obj_0 = require("moonscript.parse.literals")
  White, Break, Stop, Comment, Space, SomeSpace, SpaceBreak, EmptyLine, AlphaNum, Num, Shebang, L, _Name = _obj_0.White, _obj_0.Break, _obj_0.Stop, _obj_0.Comment, _obj_0.Space, _obj_0.SomeSpace, _obj_0.SpaceBreak, _obj_0.EmptyLine, _obj_0.AlphaNum, _obj_0.Num, _obj_0.Shebang, _obj_0.L, _obj_0.Name
end
local SpaceName = Space * _Name
Num = Space * (Num / function(v)
  return {
    "number",
    v
  }
end)
local Indent, Cut, ensure, extract_line, mark, pos, flatten_or_mark, is_assignable, check_assignable, format_assign, format_single_assign, sym, symx, simple_string, wrap_func_arg, join_chain, wrap_decorator, check_lua_string, self_assign, got
do
  local _obj_0 = require("moonscript.parse.util")
  Indent, Cut, ensure, extract_line, mark, pos, flatten_or_mark, is_assignable, check_assignable, format_assign, format_single_assign, sym, symx, simple_string, wrap_func_arg, join_chain, wrap_decorator, check_lua_string, self_assign, got = _obj_0.Indent, _obj_0.Cut, _obj_0.ensure, _obj_0.extract_line, _obj_0.mark, _obj_0.pos, _obj_0.flatten_or_mark, _obj_0.is_assignable, _obj_0.check_assignable, _obj_0.format_assign, _obj_0.format_single_assign, _obj_0.sym, _obj_0.symx, _obj_0.simple_string, _obj_0.wrap_func_arg, _obj_0.join_chain, _obj_0.wrap_decorator, _obj_0.check_lua_string, _obj_0.self_assign, _obj_0.got
end
local build_grammar = wrap_env(debug_grammar, function(root)
  local _indent = Stack(0)
  local _do_stack = Stack(0)
  local state = {
    last_pos = 0
  }
  local check_indent
  check_indent = function(str, pos, indent)
    state.last_pos = pos
    return _indent:top() == indent
  end
  local advance_indent
  advance_indent = function(str, pos, indent)
    local top = _indent:top()
    if top ~= -1 and indent > top then
      _indent:push(indent)
      return true
    end
  end
  local push_indent
  push_indent = function(str, pos, indent)
    _indent:push(indent)
    return true
  end
  local pop_indent
  pop_indent = function()
    assert(_indent:pop(), "unexpected outdent")
    return true
  end
  local check_do
  check_do = function(str, pos, do_node)
    local top = _do_stack:top()
    if top == nil or top then
      return true, do_node
    end
    return false
  end
  local disable_do
  disable_do = function()
    _do_stack:push(false)
    return true
  end
  local pop_do
  pop_do = function()
    assert(_do_stack:pop() ~= nil, "unexpected do pop")
    return true
  end
  local DisableDo = Cmt("", disable_do)
  local PopDo = Cmt("", pop_do)
  local keywords = { }
  local key
  key = function(chars)
    keywords[chars] = true
    return Space * chars * -AlphaNum
  end
  local op
  op = function(chars)
    local patt = Space * C(chars)
    if chars:match("^%w*$") then
      keywords[chars] = true
      patt = patt * -AlphaNum
    end
    return patt
  end
  local Name = Cmt(SpaceName, function(str, pos, name)
    if keywords[name] then
      return false
    end
    return true
  end) / trim
  local SelfName = Space * "@" * ("@" * (_Name / mark("self_class") + Cc("self.__class")) + _Name / mark("self") + Cc("self"))
  local KeyName = SelfName + Space * _Name / mark("key_literal")
  local VarArg = Space * P("...") / trim
  local g = P({
    root or File,
    File = Shebang ^ -1 * (Block + Ct("")),
    Block = Ct(Line * (Break ^ 1 * Line) ^ 0),
    CheckIndent = Cmt(Indent, check_indent),
    Line = (CheckIndent * Statement + Space * L(Stop)),
    Statement = pos(Import + While + With + For + ForEach + Switch + Return + Local + Export + BreakLoop + Ct(ExpList) * (Update + Assign) ^ -1 / format_assign) * Space * ((key("if") * Exp * (key("else") * Exp) ^ -1 * Space / mark("if") + key("unless") * Exp / mark("unless") + CompInner / mark("comprehension")) * Space) ^ -1 / wrap_decorator,
    Body = Space ^ -1 * Break * EmptyLine ^ 0 * InBlock + Ct(Statement),
    Advance = L(Cmt(Indent, advance_indent)),
    PushIndent = Cmt(Indent, push_indent),
    PreventIndent = Cmt(Cc(-1), push_indent),
    PopIndent = Cmt("", pop_indent),
    InBlock = Advance * Block * PopIndent,
    Local = key("local") * ((op("*") + op("^")) / mark("declare_glob") + Ct(NameList) / mark("declare_with_shadows")),
    Import = key("import") * Ct(ImportNameList) * SpaceBreak ^ 0 * key("from") * Exp / mark("import"),
    ImportName = (sym("\\") * Ct(Cc("colon") * Name) + Name),
    ImportNameList = SpaceBreak ^ 0 * ImportName * ((SpaceBreak ^ 1 + sym(",") * SpaceBreak ^ 0) * ImportName) ^ 0,
    BreakLoop = Ct(key("break") / trim) + Ct(key("continue") / trim),
    Return = key("return") * (ExpListLow / mark("explist") + C("")) / mark("return"),
    WithExp = Ct(ExpList) * Assign ^ -1 / format_assign,
    With = key("with") * DisableDo * ensure(WithExp, PopDo) * key("do") ^ -1 * Body / mark("with"),
    Switch = key("switch") * DisableDo * ensure(Exp, PopDo) * key("do") ^ -1 * Space ^ -1 * Break * SwitchBlock / mark("switch"),
    SwitchBlock = EmptyLine ^ 0 * Advance * Ct(SwitchCase * (Break ^ 1 * SwitchCase) ^ 0 * (Break ^ 1 * SwitchElse) ^ -1) * PopIndent,
    SwitchCase = key("when") * Ct(ExpList) * key("then") ^ -1 * Body / mark("case"),
    SwitchElse = key("else") * Body / mark("else"),
    IfCond = Exp * Assign ^ -1 / format_single_assign,
    IfElse = (Break * EmptyLine ^ 0 * CheckIndent) ^ -1 * key("else") * Body / mark("else"),
    IfElseIf = (Break * EmptyLine ^ 0 * CheckIndent) ^ -1 * key("elseif") * pos(IfCond) * key("then") ^ -1 * Body / mark("elseif"),
    If = key("if") * IfCond * key("then") ^ -1 * Body * IfElseIf ^ 0 * IfElse ^ -1 / mark("if"),
    Unless = key("unless") * IfCond * key("then") ^ -1 * Body * IfElseIf ^ 0 * IfElse ^ -1 / mark("unless"),
    While = key("while") * DisableDo * ensure(Exp, PopDo) * key("do") ^ -1 * Body / mark("while"),
    For = key("for") * DisableDo * ensure(Name * sym("=") * Ct(Exp * sym(",") * Exp * (sym(",") * Exp) ^ -1), PopDo) * key("do") ^ -1 * Body / mark("for"),
    ForEach = key("for") * Ct(AssignableNameList) * key("in") * DisableDo * ensure(Ct(sym("*") * Exp / mark("unpack") + ExpList), PopDo) * key("do") ^ -1 * Body / mark("foreach"),
    Do = key("do") * Body / mark("do"),
    Comprehension = sym("[") * Exp * CompInner * sym("]") / mark("comprehension"),
    TblComprehension = sym("{") * Ct(Exp * (sym(",") * Exp) ^ -1) * CompInner * sym("}") / mark("tblcomprehension"),
    CompInner = Ct((CompForEach + CompFor) * CompClause ^ 0),
    CompForEach = key("for") * Ct(AssignableNameList) * key("in") * (sym("*") * Exp / mark("unpack") + Exp) / mark("foreach"),
    CompFor = key("for" * Name * sym("=") * Ct(Exp * sym(",") * Exp * (sym(",") * Exp) ^ -1) / mark("for")),
    CompClause = CompFor + CompForEach + key("when") * Exp / mark("when"),
    Assign = sym("=") * (Ct(With + If + Switch) + Ct(TableBlock + ExpListLow)) / mark("assign"),
    Update = ((sym("..=") + sym("+=") + sym("-=") + sym("*=") + sym("/=") + sym("%=") + sym("or=") + sym("and=") + sym("&=") + sym("|=") + sym(">>=") + sym("<<=")) / trim) * Exp / mark("update"),
    CharOperators = Space * C(S("+-*/%^><|&")),
    WordOperators = op("or") + op("and") + op("<=") + op(">=") + op("~=") + op("!=") + op("==") + op("..") + op("<<") + op(">>") + op("//"),
    BinaryOperator = (WordOperators + CharOperators) * SpaceBreak ^ 0,
    Assignable = Cmt(Chain, check_assignable) + Name + SelfName,
    Exp = Ct(Value * (BinaryOperator * Value) ^ 0) / flatten_or_mark("exp"),
    SimpleValue = If + Unless + Switch + With + ClassDecl + ForEach + For + While + Cmt(Do, check_do) + sym("-") * -SomeSpace * Exp / mark("minus") + sym("#") * Exp / mark("length") + sym("~") * Exp / mark("bitnot") + key("not") * Exp / mark("not") + TblComprehension + TableLit + Comprehension + FunLit + Num,
    ChainValue = (Chain + Callable) * Ct(InvokeArgs ^ -1) / join_chain,
    Value = pos(SimpleValue + Ct(KeyValueList) / mark("table") + ChainValue + String),
    SliceValue = Exp,
    String = Space * DoubleString + Space * SingleString + LuaString,
    SingleString = simple_string("'"),
    DoubleString = simple_string('"', true),
    LuaString = Cg(LuaStringOpen, "string_open") * Cb("string_open") * Break ^ -1 * C((1 - Cmt(C(LuaStringClose) * Cb("string_open"), check_lua_string)) ^ 0) * LuaStringClose / mark("string"),
    LuaStringOpen = sym("[") * P("=") ^ 0 * "[" / trim,
    LuaStringClose = "]" * P("=") ^ 0 * "]",
    Callable = pos(Name / mark("ref")) + SelfName + VarArg + Parens / mark("parens"),
    Parens = sym("(") * SpaceBreak ^ 0 * Exp * SpaceBreak ^ 0 * sym(")"),
    FnArgs = symx("(") * SpaceBreak ^ 0 * Ct(FnArgsExpList ^ -1) * SpaceBreak ^ 0 * sym(")") + sym("!") * -P("=") * Ct(""),
    FnArgsExpList = Exp * ((Break + sym(",")) * White * Exp) ^ 0,
    Chain = (Callable + String + -S(".\\")) * ChainItems / mark("chain") + Space * (DotChainItem * ChainItems ^ -1 + ColonChain) / mark("chain"),
    ChainItems = ChainItem ^ 1 * ColonChain ^ -1 + ColonChain,
    ChainItem = Invoke + DotChainItem + Slice + symx("[") * Exp / mark("index") * sym("]"),
    DotChainItem = symx(".") * _Name / mark("dot"),
    ColonChainItem = symx("\\") * _Name / mark("colon"),
    ColonChain = ColonChainItem * (Invoke * ChainItems ^ -1) ^ -1,
    Slice = symx("[") * (SliceValue + Cc(1)) * sym(",") * (SliceValue + Cc("")) * (sym(",") * SliceValue) ^ -1 * sym("]") / mark("slice"),
    Invoke = FnArgs / mark("call") + SingleString / wrap_func_arg + DoubleString / wrap_func_arg + L(P("[")) * LuaString / wrap_func_arg,
    TableValue = KeyValue + Ct(Exp),
    TableLit = sym("{") * Ct(TableValueList ^ -1 * sym(",") ^ -1 * (SpaceBreak * TableLitLine * (sym(",") ^ -1 * SpaceBreak * TableLitLine) ^ 0 * sym(",") ^ -1) ^ -1) * White * sym("}") / mark("table"),
    TableValueList = TableValue * (sym(",") * TableValue) ^ 0,
    TableLitLine = PushIndent * ((TableValueList * PopIndent) + (PopIndent * Cut)) + Space,
    TableBlockInner = Ct(KeyValueLine * (SpaceBreak ^ 1 * KeyValueLine) ^ 0),
    TableBlock = SpaceBreak ^ 1 * Advance * ensure(TableBlockInner, PopIndent) / mark("table"),
    ClassDecl = key("class") * -P(":") * (Assignable + Cc(nil)) * (key("extends") * PreventIndent * ensure(Exp, PopIndent) + C("")) ^ -1 * (ClassBlock + Ct("")) / mark("class"),
    ClassBlock = SpaceBreak ^ 1 * Advance * Ct(ClassLine * (SpaceBreak ^ 1 * ClassLine) ^ 0) * PopIndent,
    ClassLine = CheckIndent * ((KeyValueList / mark("props") + Statement / mark("stm") + Exp / mark("stm")) * sym(",") ^ -1),
    Export = key("export") * (Cc("class") * ClassDecl + op("*") + op("^") + Ct(NameList) * (sym("=") * Ct(ExpListLow)) ^ -1) / mark("export"),
    KeyValue = (sym(":") * -SomeSpace * Name * lpeg.Cp()) / self_assign + Ct((KeyName + sym("[") * Exp * sym("]") + Space * DoubleString + Space * SingleString) * symx(":") * (Exp + TableBlock + SpaceBreak ^ 1 * Exp)),
    KeyValueList = KeyValue * (sym(",") * KeyValue) ^ 0,
    KeyValueLine = CheckIndent * KeyValueList * sym(",") ^ -1,
    FnArgsDef = sym("(") * White * Ct(FnArgDefList ^ -1) * (key("using") * Ct(NameList + Space * "nil") + Ct("")) * White * sym(")") + Ct("") * Ct(""),
    FnArgDefList = FnArgDef * ((sym(",") + Break) * White * FnArgDef) ^ 0 * ((sym(",") + Break) * White * Ct(VarArg)) ^ 0 + Ct(VarArg),
    FnArgDef = Ct((Name + SelfName) * (sym("=") * Exp) ^ -1),
    FunLit = FnArgsDef * (sym("->") * Cc("slim") + sym("=>") * Cc("fat")) * (Body + Ct("")) / mark("fndef"),
    NameList = Name * (sym(",") * Name) ^ 0,
    NameOrDestructure = Name + TableLit,
    AssignableNameList = NameOrDestructure * (sym(",") * NameOrDestructure) ^ 0,
    ExpList = Exp * (sym(",") * Exp) ^ 0,
    ExpListLow = Exp * ((sym(",") + sym(";")) * Exp) ^ 0,
    InvokeArgs = -P("-") * (ExpList * (sym(",") * (TableBlock + SpaceBreak * Advance * ArgBlock * TableBlock ^ -1) + TableBlock) ^ -1 + TableBlock),
    ArgBlock = ArgLine * (sym(",") * SpaceBreak * ArgLine) ^ 0 * PopIndent,
    ArgLine = CheckIndent * ExpList
  })
  return g, state
end)
local g, state = build_grammar()
local file_parser
file_parser = function()
  local file_grammar = White * g * White * -1
  return {
    match = function(self, str)
      local tree
      local _, err = xpcall((function()
        tree = file_grammar:match(str)
      end), function(err)
        return debug.traceback(err, 2)
      end)
      if type(err) == "string" then
        return nil, err
      end
      if not (tree) then
        local msg
        local err_pos = state.last_pos
        if err then
          local node
          node, msg = unpack(err)
          if msg then
            msg = " " .. msg
          end
          err_pos = node[-1]
        end
        local line_no = pos_to_line(str, err_pos)
        local line_str = get_line(str, line_no) or ""
        return nil, err_msg:format(msg or "", line_no, trim(line_str))
      end
      return tree
    end
  }
end
return {
  extract_line = extract_line,
  build_grammar = build_grammar,
  string = function(str)
    return file_parser():match(str)
  end
}
end
preload["moonscript.parse.util"] = function(...)
local unpack
unpack = require("moonscript.util").unpack
local P, C, S, Cp, Cmt, V
do
  local _obj_0 = require("cc.lpeg")
  P, C, S, Cp, Cmt, V = _obj_0.P, _obj_0.C, _obj_0.S, _obj_0.Cp, _obj_0.Cmt, _obj_0.V
end
local ntype
ntype = require("moonscript.types").ntype
local Space
Space = require("moonscript.parse.literals").Space
local Indent = C(S("\t ") ^ 0) / function(str)
  do
    local sum = 0
    for v in str:gmatch("[\t ]") do
      local _exp_0 = v
      if " " == _exp_0 then
        sum = sum + 1
      elseif "\t" == _exp_0 then
        sum = sum + 4
      end
    end
    return sum
  end
end
local Cut = P(function()
  return false
end)
local ensure
ensure = function(patt, finally)
  return patt * finally + finally * Cut
end
local extract_line
extract_line = function(str, start_pos)
  str = str:sub(start_pos)
  do
    local m = str:match("^(.-)\n")
    if m then
      return m
    end
  end
  return str:match("^.-$")
end
local show_line_position
show_line_position = function(str, pos, context)
  if context == nil then
    context = true
  end
  local lines = {
    { }
  }
  for c in str:gmatch(".") do
    local _update_0 = #lines
    lines[_update_0] = lines[_update_0] or { }
    table.insert(lines[#lines], c)
    if c == "\n" then
      lines[#lines + 1] = { }
    end
  end
  for i, line in ipairs(lines) do
    lines[i] = table.concat(line)
  end
  local out
  local remaining = pos - 1
  for k, line in ipairs(lines) do
    if remaining < #line then
      local left = line:sub(1, remaining)
      local right = line:sub(remaining + 1)
      out = {
        tostring(left) .. "?" .. tostring(right)
      }
      if context then
        do
          local before = lines[k - 1]
          if before then
            table.insert(out, 1, before)
          end
        end
        do
          local after = lines[k + 1]
          if after then
            table.insert(out, after)
          end
        end
      end
      break
    else
      remaining = remaining - #line
    end
  end
  if not (out) then
    return "-"
  end
  out = table.concat(out)
  return (out:gsub("\n*$", ""))
end
local mark
mark = function(name)
  return function(...)
    return {
      name,
      ...
    }
  end
end
local pos
pos = function(patt)
  return (Cp() * patt) / function(pos, value)
    if type(value) == "table" then
      value[-1] = pos
    end
    return value
  end
end
local got
got = function(what, context)
  if context == nil then
    context = true
  end
  return Cmt("", function(str, pos)
    print("++ got " .. tostring(what), "[" .. tostring(show_line_position(str, pos, context)) .. "]")
    return true
  end)
end
local flatten_or_mark
flatten_or_mark = function(name)
  return function(tbl)
    if #tbl == 1 then
      return tbl[1]
    end
    table.insert(tbl, 1, name)
    return tbl
  end
end
local is_assignable
do
  local chain_assignable = {
    index = true,
    dot = true,
    slice = true
  }
  is_assignable = function(node)
    if node == "..." then
      return false
    end
    local _exp_0 = ntype(node)
    if "ref" == _exp_0 or "self" == _exp_0 or "value" == _exp_0 or "self_class" == _exp_0 or "table" == _exp_0 then
      return true
    elseif "chain" == _exp_0 then
      return chain_assignable[ntype(node[#node])]
    else
      return false
    end
  end
end
local check_assignable
check_assignable = function(str, pos, value)
  if is_assignable(value) then
    return true, value
  else
    return false
  end
end
local format_assign
do
  local flatten_explist = flatten_or_mark("explist")
  format_assign = function(lhs_exps, assign)
    if not (assign) then
      return flatten_explist(lhs_exps)
    end
    for _index_0 = 1, #lhs_exps do
      local assign_exp = lhs_exps[_index_0]
      if not (is_assignable(assign_exp)) then
        error({
          assign_exp,
          "left hand expression is not assignable"
        })
      end
    end
    local t = ntype(assign)
    local _exp_0 = t
    if "assign" == _exp_0 then
      return {
        "assign",
        lhs_exps,
        unpack(assign, 2)
      }
    elseif "update" == _exp_0 then
      return {
        "update",
        lhs_exps[1],
        unpack(assign, 2)
      }
    else
      return error("unknown assign expression: " .. tostring(t))
    end
  end
end
local format_single_assign
format_single_assign = function(lhs, assign)
  if assign then
    return format_assign({
      lhs
    }, assign)
  else
    return lhs
  end
end
local sym
sym = function(chars)
  return Space * chars
end
local symx
symx = function(chars)
  return chars
end
local simple_string
simple_string = function(delim, allow_interpolation)
  local inner = P("\\" .. tostring(delim)) + "\\\\" + (1 - P(delim))
  if allow_interpolation then
    local interp = symx('#{') * V("Exp") * sym('}')
    inner = (C((inner - interp) ^ 1) + interp / mark("interpolate")) ^ 0
  else
    inner = C(inner ^ 0)
  end
  return C(symx(delim)) * inner * sym(delim) / mark("string")
end
local wrap_func_arg
wrap_func_arg = function(value)
  return {
    "call",
    {
      value
    }
  }
end
local join_chain
join_chain = function(callee, args)
  if #args == 0 then
    return callee
  end
  args = {
    "call",
    args
  }
  if ntype(callee) == "chain" then
    table.insert(callee, args)
    return callee
  end
  return {
    "chain",
    callee,
    args
  }
end
local wrap_decorator
wrap_decorator = function(stm, dec)
  if not (dec) then
    return stm
  end
  return {
    "decorated",
    stm,
    dec
  }
end
local check_lua_string
check_lua_string = function(str, pos, right, left)
  return #left == #right
end
local self_assign
self_assign = function(name, pos)
  return {
    {
      "key_literal",
      name
    },
    {
      "ref",
      name,
      [-1] = pos
    }
  }
end
return {
  Indent = Indent,
  Cut = Cut,
  ensure = ensure,
  extract_line = extract_line,
  mark = mark,
  pos = pos,
  flatten_or_mark = flatten_or_mark,
  is_assignable = is_assignable,
  check_assignable = check_assignable,
  format_assign = format_assign,
  format_single_assign = format_single_assign,
  sym = sym,
  symx = symx,
  simple_string = simple_string,
  wrap_func_arg = wrap_func_arg,
  join_chain = join_chain,
  wrap_decorator = wrap_decorator,
  check_lua_string = check_lua_string,
  self_assign = self_assign,
  got = got,
  show_line_position = show_line_position
}
end
preload["moonscript.parse.literals"] = function(...)
local safe_module
safe_module = require("moonscript.util").safe_module
local S, P, R, C
do
  local _obj_0 = require("cc.lpeg")
  S, P, R, C = _obj_0.S, _obj_0.P, _obj_0.R, _obj_0.C
end
local lpeg = require("cc.lpeg")
local L = lpeg.luversion and lpeg.L or function(v)
  return #v
end
local White = S(" \t\r\n") ^ 0
local plain_space = S(" \t") ^ 0
local Break = P("\r") ^ -1 * P("\n")
local Stop = Break + -1
local Comment = P("--") * (1 - S("\r\n")) ^ 0 * L(Stop)
local Space = plain_space * Comment ^ -1
local SomeSpace = S(" \t") ^ 1 * Comment ^ -1
local SpaceBreak = Space * Break
local EmptyLine = SpaceBreak
local AlphaNum = R("az", "AZ", "09", "__")
local Name = C(R("az", "AZ", "__") * AlphaNum ^ 0)
local Num = P("0x") * R("09", "af", "AF") ^ 1 * (S("uU") ^ -1 * S("lL") ^ 2) ^ -1 + R("09") ^ 1 * (S("uU") ^ -1 * S("lL") ^ 2) + (R("09") ^ 1 * (P(".") * R("09") ^ 1) ^ -1 + P(".") * R("09") ^ 1) * (S("eE") * P("-") ^ -1 * R("09") ^ 1) ^ -1
local Shebang = P("#!") * P(1 - Stop) ^ 0
return safe_module("moonscript.parse.literals", {
  L = L,
  White = White,
  Break = Break,
  Stop = Stop,
  Comment = Comment,
  Space = Space,
  SomeSpace = SomeSpace,
  SpaceBreak = SpaceBreak,
  EmptyLine = EmptyLine,
  AlphaNum = AlphaNum,
  Name = Name,
  Num = Num,
  Shebang = Shebang
})
end
preload["moonscript.parse.env"] = function(...)
local getfenv, setfenv
do
  local _obj_0 = require("moonscript.util")
  getfenv, setfenv = _obj_0.getfenv, _obj_0.setfenv
end
local wrap_env
wrap_env = function(debug, fn)
  local V, Cmt
  do
    local _obj_0 = require("cc.lpeg")
    V, Cmt = _obj_0.V, _obj_0.Cmt
  end
  local env = getfenv(fn)
  local wrap_name = V
  if debug then
    local indent = 0
    local indent_char = "  "
    local iprint
    iprint = function(...)
      local args = table.concat((function(...)
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = {
          ...
        }
        for _index_0 = 1, #_list_0 do
          local a = _list_0[_index_0]
          _accum_0[_len_0] = tostring(a)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(...), ", ")
      return io.stderr:write(tostring(indent_char:rep(indent)) .. tostring(args) .. "\n")
    end
    wrap_name = function(name)
      local v = V(name)
      v = Cmt("", function(str, pos)
        local rest = str:sub(pos, -1):match("^([^\n]*)")
        iprint("* " .. tostring(name) .. " (" .. tostring(rest) .. ")")
        indent = indent + 1
        return true
      end) * Cmt(v, function(str, pos, ...)
        iprint(name, true)
        indent = indent - 1
        return true, ...
      end) + Cmt("", function()
        iprint(name, false)
        indent = indent - 1
        return false
      end)
      return v
    end
  end
  return setfenv(fn, setmetatable({ }, {
    __index = function(self, name)
      local value = env[name]
      if value ~= nil then
        return value
      end
      if name:match("^[A-Z][A-Za-z0-9]*$") then
        local v = wrap_name(name)
        return v
      end
      return error("unknown variable referenced: " .. tostring(name))
    end
  }))
end
return {
  wrap_env = wrap_env
}
end
preload["moonscript.line_tables"] = function(...)
return { }
end
preload["moonscript"] = function(...)
do
  local _with_0 = require("moonscript.base")
  _with_0.insert_loader()
  return _with_0
end
end
preload["moonscript.errors"] = function(...)
local util = require("moonscript.util")
local lpeg = require("cc.lpeg")
local concat, insert
do
  local _obj_0 = table
  concat, insert = _obj_0.concat, _obj_0.insert
end
local split, pos_to_line
split, pos_to_line = util.split, util.pos_to_line
local user_error
user_error = function(...)
  return error({
    "user-error",
    ...
  })
end
local lookup_line
lookup_line = function(fname, pos, cache)
  if not cache[fname] then
    do
      local _with_0 = assert(io.open(fname))
      cache[fname] = _with_0:read("*a")
      _with_0:close()
    end
  end
  return pos_to_line(cache[fname], pos)
end
local reverse_line_number
reverse_line_number = function(fname, line_table, line_num, cache)
  for i = line_num, 0, -1 do
    if line_table[i] then
      return lookup_line(fname, line_table[i], cache)
    end
  end
  return "unknown"
end
local truncate_traceback
truncate_traceback = function(traceback, chunk_func)
  if chunk_func == nil then
    chunk_func = "moonscript_chunk"
  end
  traceback = split(traceback, "\n")
  local stop = #traceback
  while stop > 1 do
    if traceback[stop]:match(chunk_func) then
      break
    end
    stop = stop - 1
  end
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _max_0 = stop
    for _index_0 = 1, _max_0 < 0 and #traceback + _max_0 or _max_0 do
      local t = traceback[_index_0]
      _accum_0[_len_0] = t
      _len_0 = _len_0 + 1
    end
    traceback = _accum_0
  end
  local rep = "function '" .. chunk_func .. "'"
  traceback[#traceback] = traceback[#traceback]:gsub(rep, "main chunk")
  return concat(traceback, "\n")
end
local rewrite_traceback
rewrite_traceback = function(text, err)
  local line_tables = require("moonscript.line_tables")
  local V, S, Ct, C
  V, S, Ct, C = lpeg.V, lpeg.S, lpeg.Ct, lpeg.C
  local header_text = "stack traceback:"
  local Header, Line = V("Header"), V("Line")
  local Break = lpeg.S("\n")
  local g = lpeg.P({
    Header,
    Header = header_text * Break * Ct(Line ^ 1),
    Line = "\t" * C((1 - Break) ^ 0) * (Break + -1)
  })
  local cache = { }
  local rewrite_single
  rewrite_single = function(trace)
    local fname, line, msg = trace:match('^(.-):(%d+): (.*)$')
    local tbl = line_tables["@" .. tostring(fname)]
    if fname and tbl then
      return concat({
        fname,
        ":",
        reverse_line_number(fname, tbl, line, cache),
        ": ",
        "(",
        line,
        ") ",
        msg
      })
    else
      return trace
    end
  end
  err = rewrite_single(err)
  local match = g:match(text)
  if not (match) then
    return nil
  end
  for i, trace in ipairs(match) do
    match[i] = rewrite_single(trace)
  end
  return concat({
    "moon: " .. err,
    header_text,
    "\t" .. concat(match, "\n\t")
  }, "\n")
end
return {
  rewrite_traceback = rewrite_traceback,
  truncate_traceback = truncate_traceback,
  user_error = user_error,
  reverse_line_number = reverse_line_number
}
end
preload["moonscript.dump"] = function(...)
local flat_value
flat_value = function(op, depth)
  if depth == nil then
    depth = 1
  end
  if type(op) == "string" then
    return '"' .. op .. '"'
  end
  if type(op) ~= "table" then
    return tostring(op)
  end
  local items
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #op do
      local item = op[_index_0]
      _accum_0[_len_0] = flat_value(item, depth + 1)
      _len_0 = _len_0 + 1
    end
    items = _accum_0
  end
  local pos = op[-1]
  return "{" .. (pos and "[" .. pos .. "] " or "") .. table.concat(items, ", ") .. "}"
end
local value
value = function(op)
  return flat_value(op)
end
local tree
tree = function(block)
  return table.concat((function()
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #block do
      local value = block[_index_0]
      _accum_0[_len_0] = flat_value(value)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)(), "\n")
end
return {
  value = value,
  tree = tree
}
end
preload["moonscript.data"] = function(...)
local concat, remove, insert
do
  local _obj_0 = table
  concat, remove, insert = _obj_0.concat, _obj_0.remove, _obj_0.insert
end
local Set
Set = function(items)
  local _tbl_0 = { }
  for _index_0 = 1, #items do
    local k = items[_index_0]
    _tbl_0[k] = true
  end
  return _tbl_0
end
local Stack
do
  local _class_0
  local _base_0 = {
    __tostring = function(self)
      return "<Stack {" .. concat(self, ", ") .. "}>"
    end,
    pop = function(self)
      return remove(self)
    end,
    push = function(self, value, ...)
      insert(self, value)
      if ... then
        return self:push(...)
      else
        return value
      end
    end,
    top = function(self)
      return self[#self]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, ...)
      self:push(...)
      return nil
    end,
    __base = _base_0,
    __name = "Stack"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Stack = _class_0
end
local lua_keywords = Set({
  'and',
  'break',
  'do',
  'else',
  'elseif',
  'end',
  'false',
  'for',
  'function',
  'if',
  'in',
  'local',
  'nil',
  'not',
  'or',
  'repeat',
  'return',
  'then',
  'true',
  'until',
  'while'
})
return {
  Set = Set,
  Stack = Stack,
  lua_keywords = lua_keywords
}
end
preload["moonscript.compile"] = function(...)
local util = require("moonscript.util")
local dump = require("moonscript.dump")
local transform = require("moonscript.transform")
local NameProxy, LocalName
do
  local _obj_0 = require("moonscript.transform.names")
  NameProxy, LocalName = _obj_0.NameProxy, _obj_0.LocalName
end
local Set
Set = require("moonscript.data").Set
local ntype, value_can_be_statement
do
  local _obj_0 = require("moonscript.types")
  ntype, value_can_be_statement = _obj_0.ntype, _obj_0.value_can_be_statement
end
local statement_compilers = require("moonscript.compile.statement")
local value_compilers = require("moonscript.compile.value")
local concat, insert
do
  local _obj_0 = table
  concat, insert = _obj_0.concat, _obj_0.insert
end
local pos_to_line, get_closest_line, trim, unpack
pos_to_line, get_closest_line, trim, unpack = util.pos_to_line, util.get_closest_line, util.trim, util.unpack
local mtype = util.moon.type
local indent_char = "  "
local Line, DelayedLine, Lines, Block, RootBlock
do
  local _class_0
  local _base_0 = {
    mark_pos = function(self, pos, line)
      if line == nil then
        line = #self
      end
      if not (self.posmap[line]) then
        self.posmap[line] = pos
      end
    end,
    add = function(self, item)
      local _exp_0 = mtype(item)
      if Line == _exp_0 then
        item:render(self)
      elseif Block == _exp_0 then
        item:render(self)
      else
        self[#self + 1] = item
      end
      return self
    end,
    flatten_posmap = function(self, line_no, out)
      if line_no == nil then
        line_no = 0
      end
      if out == nil then
        out = { }
      end
      local posmap = self.posmap
      for i, l in ipairs(self) do
        local _exp_0 = mtype(l)
        if "string" == _exp_0 or DelayedLine == _exp_0 then
          line_no = line_no + 1
          out[line_no] = posmap[i]
          for _ in l:gmatch("\n") do
            line_no = line_no + 1
          end
          out[line_no] = posmap[i]
        elseif Lines == _exp_0 then
          local _
          _, line_no = l:flatten_posmap(line_no, out)
        else
          error("Unknown item in Lines: " .. tostring(l))
        end
      end
      return out, line_no
    end,
    flatten = function(self, indent, buffer)
      if indent == nil then
        indent = nil
      end
      if buffer == nil then
        buffer = { }
      end
      for i = 1, #self do
        local l = self[i]
        local t = mtype(l)
        if t == DelayedLine then
          l = l:render()
          t = "string"
        end
        local _exp_0 = t
        if "string" == _exp_0 then
          if indent then
            insert(buffer, indent)
          end
          insert(buffer, l)
          if "string" == type(self[i + 1]) then
            if l:sub(-1) ~= ',' and l:sub(-3) ~= 'end' and self[i + 1]:sub(1, 1) == "(" then
              insert(buffer, ";")
            end
          end
          insert(buffer, "\n")
        elseif Lines == _exp_0 then
          l:flatten(indent and indent .. indent_char or indent_char, buffer)
        else
          error("Unknown item in Lines: " .. tostring(l))
        end
      end
      return buffer
    end,
    __tostring = function(self)
      local strip
      strip = function(t)
        if "table" == type(t) then
          local _accum_0 = { }
          local _len_0 = 1
          for _index_0 = 1, #t do
            local v = t[_index_0]
            _accum_0[_len_0] = strip(v)
            _len_0 = _len_0 + 1
          end
          return _accum_0
        else
          return t
        end
      end
      return "Lines<" .. tostring(util.dump(strip(self)):sub(1, -2)) .. ">"
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.posmap = { }
    end,
    __base = _base_0,
    __name = "Lines"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Lines = _class_0
end
do
  local _class_0
  local _base_0 = {
    pos = nil,
    append_list = function(self, items, delim)
      for i = 1, #items do
        self:append(items[i])
        if i < #items then
          insert(self, delim)
        end
      end
      return nil
    end,
    append = function(self, first, ...)
      if Line == mtype(first) then
        if not (self.pos) then
          self.pos = first.pos
        end
        for _index_0 = 1, #first do
          local value = first[_index_0]
          self:append(value)
        end
      else
        insert(self, first)
      end
      if ... then
        return self:append(...)
      end
    end,
    render = function(self, buffer)
      local current = { }
      local add_current
      add_current = function()
        buffer:add(concat(current))
        return buffer:mark_pos(self.pos)
      end
      for _index_0 = 1, #self do
        local chunk = self[_index_0]
        local _exp_0 = mtype(chunk)
        if Block == _exp_0 then
          local _list_0 = chunk:render(Lines())
          for _index_1 = 1, #_list_0 do
            local block_chunk = _list_0[_index_1]
            if "string" == type(block_chunk) then
              insert(current, block_chunk)
            else
              add_current()
              buffer:add(block_chunk)
              current = { }
            end
          end
        else
          insert(current, chunk)
        end
      end
      if current[1] then
        add_current()
      end
      return buffer
    end,
    __tostring = function(self)
      return "Line<" .. tostring(util.dump(self):sub(1, -2)) .. ">"
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Line"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Line = _class_0
end
do
  local _class_0
  local _base_0 = {
    prepare = function() end,
    render = function(self)
      self:prepare()
      return concat(self)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, fn)
      self.prepare = fn
    end,
    __base = _base_0,
    __name = "DelayedLine"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  DelayedLine = _class_0
end
do
  local _class_0
  local _base_0 = {
    header = "do",
    footer = "end",
    export_all = false,
    export_proper = false,
    value_compilers = value_compilers,
    statement_compilers = statement_compilers,
    __tostring = function(self)
      local h
      if "string" == type(self.header) then
        h = self.header
      else
        h = unpack(self.header:render({ }))
      end
      return "Block<" .. tostring(h) .. "> <- " .. tostring(self.parent)
    end,
    set = function(self, name, value)
      self._state[name] = value
    end,
    get = function(self, name)
      return self._state[name]
    end,
    get_current = function(self, name)
      return rawget(self._state, name)
    end,
    listen = function(self, name, fn)
      self._listeners[name] = fn
    end,
    unlisten = function(self, name)
      self._listeners[name] = nil
    end,
    send = function(self, name, ...)
      do
        local fn = self._listeners[name]
        if fn then
          return fn(self, ...)
        end
      end
    end,
    extract_assign_name = function(self, node)
      local is_local = false
      local real_name
      local _exp_0 = mtype(node)
      if LocalName == _exp_0 then
        is_local = true
        real_name = node:get_name(self)
      elseif NameProxy == _exp_0 then
        real_name = node:get_name(self)
      elseif "table" == _exp_0 then
        real_name = node[1] == "ref" and node[2]
      elseif "string" == _exp_0 then
        real_name = node
      end
      return real_name, is_local
    end,
    declare = function(self, names)
      local undeclared
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #names do
          local _continue_0 = false
          repeat
            local name = names[_index_0]
            local real_name, is_local = self:extract_assign_name(name)
            if not (is_local or real_name and not self:has_name(real_name, true)) then
              _continue_0 = true
              break
            end
            self:put_name(real_name)
            if self:name_exported(real_name) then
              _continue_0 = true
              break
            end
            local _value_0 = real_name
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        undeclared = _accum_0
      end
      return undeclared
    end,
    whitelist_names = function(self, names)
      self._name_whitelist = Set(names)
    end,
    name_exported = function(self, name)
      if self.export_all then
        return true
      end
      if self.export_proper and name:match("^%u") then
        return true
      end
    end,
    put_name = function(self, name, ...)
      local value = ...
      if select("#", ...) == 0 then
        value = true
      end
      if NameProxy == mtype(name) then
        name = name:get_name(self)
      end
      self._names[name] = value
    end,
    has_name = function(self, name, skip_exports)
      if not skip_exports and self:name_exported(name) then
        return true
      end
      local yes = self._names[name]
      if yes == nil and self.parent then
        if not self._name_whitelist or self._name_whitelist[name] then
          return self.parent:has_name(name, true)
        end
      else
        return yes
      end
    end,
    is_local = function(self, node)
      local t = mtype(node)
      if t == "string" then
        return self:has_name(node, false)
      end
      if t == NameProxy or t == LocalName then
        return true
      end
      if t == "table" then
        if node[1] == "ref" or (node[1] == "chain" and #node == 2) then
          return self:is_local(node[2])
        end
      end
      return false
    end,
    free_name = function(self, prefix, dont_put)
      prefix = prefix or "moon"
      local searching = true
      local name, i = nil, 0
      while searching do
        name = concat({
          "",
          prefix,
          i
        }, "_")
        i = i + 1
        searching = self:has_name(name, true)
      end
      if not dont_put then
        self:put_name(name)
      end
      return name
    end,
    init_free_var = function(self, prefix, value)
      local name = self:free_name(prefix, true)
      self:stm({
        "assign",
        {
          name
        },
        {
          value
        }
      })
      return name
    end,
    add = function(self, item, pos)
      do
        local _with_0 = self._lines
        _with_0:add(item)
        if pos then
          _with_0:mark_pos(pos)
        end
      end
      return item
    end,
    render = function(self, buffer)
      buffer:add(self.header)
      buffer:mark_pos(self.pos)
      if self.next then
        buffer:add(self._lines)
        self.next:render(buffer)
      else
        if #self._lines == 0 and "string" == type(buffer[#buffer]) then
          local _update_0 = #buffer
          buffer[_update_0] = buffer[_update_0] .. (" " .. (unpack(Lines():add(self.footer))))
        else
          buffer:add(self._lines)
          buffer:add(self.footer)
          buffer:mark_pos(self.pos)
        end
      end
      return buffer
    end,
    block = function(self, header, footer)
      return Block(self, header, footer)
    end,
    line = function(self, ...)
      do
        local _with_0 = Line()
        _with_0:append(...)
        return _with_0
      end
    end,
    is_stm = function(self, node)
      return self.statement_compilers[ntype(node)] ~= nil
    end,
    is_value = function(self, node)
      local t = ntype(node)
      return self.value_compilers[t] ~= nil or t == "value"
    end,
    name = function(self, node, ...)
      if type(node) == "string" then
        return node
      else
        return self:value(node, ...)
      end
    end,
    value = function(self, node, ...)
      node = self.transform.value(node)
      local action
      if type(node) ~= "table" then
        action = "raw_value"
      else
        action = node[1]
      end
      local fn = self.value_compilers[action]
      if not (fn) then
        error({
          "compile-error",
          "Failed to find value compiler for: " .. dump.value(node),
          node[-1]
        })
      end
      local out = fn(self, node, ...)
      if type(node) == "table" and node[-1] then
        if type(out) == "string" then
          do
            local _with_0 = Line()
            _with_0:append(out)
            out = _with_0
          end
        end
        out.pos = node[-1]
      end
      return out
    end,
    values = function(self, values, delim)
      delim = delim or ', '
      do
        local _with_0 = Line()
        _with_0:append_list((function()
          local _accum_0 = { }
          local _len_0 = 1
          for _index_0 = 1, #values do
            local v = values[_index_0]
            _accum_0[_len_0] = self:value(v)
            _len_0 = _len_0 + 1
          end
          return _accum_0
        end)(), delim)
        return _with_0
      end
    end,
    stm = function(self, node, ...)
      if not node then
        return 
      end
      node = self.transform.statement(node)
      local result
      do
        local fn = self.statement_compilers[ntype(node)]
        if fn then
          result = fn(self, node, ...)
        else
          if value_can_be_statement(node) then
            result = self:value(node)
          else
            result = self:stm({
              "assign",
              {
                "_"
              },
              {
                node
              }
            })
          end
        end
      end
      if result then
        if type(node) == "table" and type(result) == "table" and node[-1] then
          result.pos = node[-1]
        end
        self:add(result)
      end
      return nil
    end,
    stms = function(self, stms, ret)
      if ret then
        error("deprecated stms call, use transformer")
      end
      local current_stms, current_stm_i
      current_stms, current_stm_i = self.current_stms, self.current_stm_i
      self.current_stms = stms
      for i = 1, #stms do
        self.current_stm_i = i
        self:stm(stms[i])
      end
      self.current_stms = current_stms
      self.current_stm_i = current_stm_i
      return nil
    end,
    splice = function(self, fn)
      local lines = {
        "lines",
        self._lines
      }
      self._lines = Lines()
      return self:stms(fn(lines))
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, parent, header, footer)
      self.parent, self.header, self.footer = parent, header, footer
      self._lines = Lines()
      self._names = { }
      self._state = { }
      self._listeners = { }
      do
        self.transform = {
          value = transform.Value:bind(self),
          statement = transform.Statement:bind(self)
        }
      end
      if self.parent then
        self.root = self.parent.root
        self.indent = self.parent.indent + 1
        setmetatable(self._state, {
          __index = self.parent._state
        })
        return setmetatable(self._listeners, {
          __index = self.parent._listeners
        })
      else
        self.indent = 0
      end
    end,
    __base = _base_0,
    __name = "Block"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Block = _class_0
end
do
  local _class_0
  local _parent_0 = Block
  local _base_0 = {
    __tostring = function(self)
      return "RootBlock<>"
    end,
    root_stms = function(self, stms)
      if not (self.options.implicitly_return_root == false) then
        stms = transform.Statement.transformers.root_stms(self, stms)
      end
      return self:stms(stms)
    end,
    render = function(self)
      local buffer = self._lines:flatten()
      if buffer[#buffer] == "\n" then
        buffer[#buffer] = nil
      end
      return table.concat(buffer)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, options)
      self.options = options
      self.root = self
      return _class_0.__parent.__init(self)
    end,
    __base = _base_0,
    __name = "RootBlock",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  RootBlock = _class_0
end
local format_error
format_error = function(msg, pos, file_str)
  local line_message
  if pos then
    local line = pos_to_line(file_str, pos)
    local line_str
    line_str, line = get_closest_line(file_str, line)
    line_str = line_str or ""
    line_message = (" [%d] >>    %s"):format(line, trim(line_str))
  end
  return concat({
    "Compile error: " .. msg,
    line_message
  }, "\n")
end
local value
value = function(value)
  local out = nil
  do
    local _with_0 = RootBlock()
    _with_0:add(_with_0:value(value))
    out = _with_0:render()
  end
  return out
end
local tree
tree = function(tree, options)
  if options == nil then
    options = { }
  end
  assert(tree, "missing tree")
  local scope = (options.scope or RootBlock)(options)
  local runner = coroutine.create(function()
    return scope:root_stms(tree)
  end)
  local success, err = coroutine.resume(runner)
  if not (success) then
    local error_msg, error_pos
    if type(err) == "table" then
      local _exp_0 = err[1]
      if "user-error" == _exp_0 or "compile-error" == _exp_0 then
        error_msg, error_pos = unpack(err, 2)
      else
        error_msg, error_pos = error("Unknown error thrown", util.dump(error_msg))
      end
    else
      error_msg, error_pos = concat({
        err,
        debug.traceback(runner)
      }, "\n")
    end
    return nil, error_msg, error_pos or scope.last_pos
  end
  local lua_code = scope:render()
  local posmap = scope._lines:flatten_posmap()
  return lua_code, posmap
end
do
  local data = require("moonscript.data")
  for name, cls in pairs({
    Line = Line,
    Lines = Lines,
    DelayedLine = DelayedLine
  }) do
    data[name] = cls
  end
end
return {
  tree = tree,
  value = value,
  format_error = format_error,
  Block = Block,
  RootBlock = RootBlock
}
end
preload["moonscript.compile.value"] = function(...)
local util = require("moonscript.util")
local data = require("moonscript.data")
local ntype
ntype = require("moonscript.types").ntype
local user_error
user_error = require("moonscript.errors").user_error
local concat, insert
do
  local _obj_0 = table
  concat, insert = _obj_0.concat, _obj_0.insert
end
local unpack
unpack = util.unpack
local table_delim = ","
local string_chars = {
  ["\r"] = "\\r",
  ["\n"] = "\\n"
}
return {
  scoped = function(self, node)
    local _, before, value, after
    _, before, value, after = node[1], node[2], node[3], node[4]
    _ = before and before:call(self)
    do
      local _with_0 = self:value(value)
      _ = after and after:call(self)
      return _with_0
    end
  end,
  exp = function(self, node)
    local _comp
    _comp = function(i, value)
      if i % 2 == 1 and value == "!=" then
        value = "~="
      end
      return self:value(value)
    end
    do
      local _with_0 = self:line()
      _with_0:append_list((function()
        local _accum_0 = { }
        local _len_0 = 1
        for i, v in ipairs(node) do
          if i > 1 then
            _accum_0[_len_0] = _comp(i, v)
            _len_0 = _len_0 + 1
          end
        end
        return _accum_0
      end)(), " ")
      return _with_0
    end
  end,
  explist = function(self, node)
    do
      local _with_0 = self:line()
      _with_0:append_list((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 2, #node do
          local v = node[_index_0]
          _accum_0[_len_0] = self:value(v)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), ", ")
      return _with_0
    end
  end,
  parens = function(self, node)
    return self:line("(", self:value(node[2]), ")")
  end,
  string = function(self, node)
    local delim, inner = unpack(node, 2)
    local end_delim = delim:gsub("%[", "]")
    if delim == "'" or delim == '"' then
      inner = inner:gsub("[\r\n]", string_chars)
    end
    return delim .. inner .. end_delim
  end,
  chain = function(self, node)
    local callee = node[2]
    local callee_type = ntype(callee)
    local item_offset = 3
    if callee_type == "dot" or callee_type == "colon" or callee_type == "index" then
      callee = self:get("scope_var")
      if not (callee) then
        user_error("Short-dot syntax must be called within a with block")
      end
      item_offset = 2
    end
    if callee_type == "ref" and callee[2] == "super" or callee == "super" then
      do
        local sup = self:get("super")
        if sup then
          return self:value(sup(self, node))
        end
      end
    end
    local chain_item
    chain_item = function(node)
      local t, arg = unpack(node)
      if t == "call" then
        return "(", self:values(arg), ")"
      elseif t == "index" then
        return "[", self:value(arg), "]"
      elseif t == "dot" then
        return ".", tostring(arg)
      elseif t == "colon" then
        return ":", tostring(arg)
      elseif t == "colon_stub" then
        return user_error("Uncalled colon stub")
      else
        return error("Unknown chain action: " .. tostring(t))
      end
    end
    if (callee_type == "self" or callee_type == "self_class") and node[3] and ntype(node[3]) == "call" then
      callee[1] = callee_type .. "_colon"
    end
    local callee_value = self:value(callee)
    if ntype(callee) == "exp" then
      callee_value = self:line("(", callee_value, ")")
    end
    local actions
    do
      local _with_0 = self:line()
      for _index_0 = item_offset, #node do
        local action = node[_index_0]
        _with_0:append(chain_item(action))
      end
      actions = _with_0
    end
    return self:line(callee_value, actions)
  end,
  fndef = function(self, node)
    local args, whitelist, arrow, block = unpack(node, 2)
    local default_args = { }
    local self_args = { }
    local arg_names
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #args do
        local arg = args[_index_0]
        local name, default_value = unpack(arg)
        if type(name) == "string" then
          name = name
        else
          if name[1] == "self" or name[1] == "self_class" then
            insert(self_args, name)
          end
          name = name[2]
        end
        if default_value then
          insert(default_args, arg)
        end
        local _value_0 = name
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
      end
      arg_names = _accum_0
    end
    if arrow == "fat" then
      insert(arg_names, 1, "self")
    end
    do
      local _with_0 = self:block()
      if #whitelist > 0 then
        _with_0:whitelist_names(whitelist)
      end
      for _index_0 = 1, #arg_names do
        local name = arg_names[_index_0]
        _with_0:put_name(name)
      end
      for _index_0 = 1, #default_args do
        local default = default_args[_index_0]
        local name, value = unpack(default)
        if type(name) == "table" then
          name = name[2]
        end
        _with_0:stm({
          'if',
          {
            'exp',
            {
              "ref",
              name
            },
            '==',
            'nil'
          },
          {
            {
              'assign',
              {
                name
              },
              {
                value
              }
            }
          }
        })
      end
      local self_arg_values
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #self_args do
          local arg = self_args[_index_0]
          _accum_0[_len_0] = arg[2]
          _len_0 = _len_0 + 1
        end
        self_arg_values = _accum_0
      end
      if #self_args > 0 then
        _with_0:stm({
          "assign",
          self_args,
          self_arg_values
        })
      end
      _with_0:stms(block)
      if #args > #arg_names then
        do
          local _accum_0 = { }
          local _len_0 = 1
          for _index_0 = 1, #args do
            local arg = args[_index_0]
            _accum_0[_len_0] = arg[1]
            _len_0 = _len_0 + 1
          end
          arg_names = _accum_0
        end
      end
      _with_0.header = "function(" .. concat(arg_names, ", ") .. ")"
      return _with_0
    end
  end,
  table = function(self, node)
    local items = unpack(node, 2)
    do
      local _with_0 = self:block("{", "}")
      local format_line
      format_line = function(tuple)
        if #tuple == 2 then
          local key, value = unpack(tuple)
          if ntype(key) == "key_literal" and data.lua_keywords[key[2]] then
            key = {
              "string",
              '"',
              key[2]
            }
          end
          local assign
          if ntype(key) == "key_literal" then
            assign = key[2]
          else
            assign = self:line("[", _with_0:value(key), "]")
          end
          local out = self:line(assign, " = ", _with_0:value(value))
          return out
        else
          return self:line(_with_0:value(tuple[1]))
        end
      end
      if items then
        local count = #items
        for i, tuple in ipairs(items) do
          local line = format_line(tuple)
          if not (count == i) then
            line:append(table_delim)
          end
          _with_0:add(line)
        end
      end
      return _with_0
    end
  end,
  minus = function(self, node)
    return self:line("-", self:value(node[2]))
  end,
  temp_name = function(self, node, ...)
    return node:get_name(self, ...)
  end,
  number = function(self, node)
    return node[2]
  end,
  bitnot = function(self, node)
    return self:line("~", self:value(node[2]))
  end,
  length = function(self, node)
    return self:line("#", self:value(node[2]))
  end,
  ["not"] = function(self, node)
    return self:line("not ", self:value(node[2]))
  end,
  self = function(self, node)
    local field_name = self:name(node[2])
    if data.lua_keywords[field_name] then
      return self:value({
        "chain",
        "self",
        {
          "index",
          {
            "string",
            '"',
            field_name
          }
        }
      })
    else
      return "self." .. tostring(field_name)
    end
  end,
  self_class = function(self, node)
    local field_name = self:name(node[2])
    if data.lua_keywords[field_name] then
      return self:value({
        "chain",
        "self",
        {
          "dot",
          "__class"
        },
        {
          "index",
          {
            "string",
            '"',
            field_name
          }
        }
      })
    else
      return "self.__class." .. tostring(field_name)
    end
  end,
  self_colon = function(self, node)
    return "self:" .. tostring(self:name(node[2]))
  end,
  self_class_colon = function(self, node)
    return "self.__class:" .. tostring(self:name(node[2]))
  end,
  ref = function(self, value)
    do
      local sup = value[2] == "super" and self:get("super")
      if sup then
        return self:value(sup(self))
      end
    end
    return tostring(value[2])
  end,
  raw_value = function(self, value)
    if value == "..." then
      self:send("varargs")
    end
    return tostring(value)
  end
}
end
preload["moonscript.compile.statement"] = function(...)
local ntype
ntype = require("moonscript.types").ntype
local concat, insert
do
  local _obj_0 = table
  concat, insert = _obj_0.concat, _obj_0.insert
end
local unpack
unpack = require("moonscript.util").unpack
return {
  raw = function(self, node)
    return self:add(node[2])
  end,
  lines = function(self, node)
    local _list_0 = node[2]
    for _index_0 = 1, #_list_0 do
      local line = _list_0[_index_0]
      self:add(line)
    end
  end,
  declare = function(self, node)
    local names = node[2]
    local undeclared = self:declare(names)
    if #undeclared > 0 then
      do
        local _with_0 = self:line("local ")
        _with_0:append_list((function()
          local _accum_0 = { }
          local _len_0 = 1
          for _index_0 = 1, #undeclared do
            local name = undeclared[_index_0]
            _accum_0[_len_0] = self:name(name)
            _len_0 = _len_0 + 1
          end
          return _accum_0
        end)(), ", ")
        return _with_0
      end
    end
  end,
  declare_with_shadows = function(self, node)
    local names = node[2]
    self:declare(names)
    do
      local _with_0 = self:line("local ")
      _with_0:append_list((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #names do
          local name = names[_index_0]
          _accum_0[_len_0] = self:name(name)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), ", ")
      return _with_0
    end
  end,
  assign = function(self, node)
    local names, values = unpack(node, 2)
    local undeclared = self:declare(names)
    local declare = "local " .. concat(undeclared, ", ")
    local has_fndef = false
    local i = 1
    while i <= #values do
      if ntype(values[i]) == "fndef" then
        has_fndef = true
      end
      i = i + 1
    end
    do
      local _with_0 = self:line()
      if #undeclared == #names and not has_fndef then
        _with_0:append(declare)
      else
        if #undeclared > 0 then
          self:add(declare, node[-1])
        end
        _with_0:append_list((function()
          local _accum_0 = { }
          local _len_0 = 1
          for _index_0 = 1, #names do
            local name = names[_index_0]
            _accum_0[_len_0] = self:value(name)
            _len_0 = _len_0 + 1
          end
          return _accum_0
        end)(), ", ")
      end
      _with_0:append(" = ")
      _with_0:append_list((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #values do
          local v = values[_index_0]
          _accum_0[_len_0] = self:value(v)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), ", ")
      return _with_0
    end
  end,
  ["return"] = function(self, node)
    return self:line("return ", (function()
      if node[2] ~= "" then
        return self:value(node[2])
      end
    end)())
  end,
  ["break"] = function(self, node)
    return "break"
  end,
  ["if"] = function(self, node)
    local cond, block = node[2], node[3]
    local root
    do
      local _with_0 = self:block(self:line("if ", self:value(cond), " then"))
      _with_0:stms(block)
      root = _with_0
    end
    local current = root
    local add_clause
    add_clause = function(clause)
      local type = clause[1]
      local i = 2
      local next
      if type == "else" then
        next = self:block("else")
      else
        i = i + 1
        next = self:block(self:line("elseif ", self:value(clause[2]), " then"))
      end
      next:stms(clause[i])
      current.next = next
      current = next
    end
    for _index_0 = 4, #node do
      local cond = node[_index_0]
      add_clause(cond)
    end
    return root
  end,
  ["repeat"] = function(self, node)
    local cond, block = unpack(node, 2)
    do
      local _with_0 = self:block("repeat", self:line("until ", self:value(cond)))
      _with_0:stms(block)
      return _with_0
    end
  end,
  ["while"] = function(self, node)
    local cond, block = unpack(node, 2)
    do
      local _with_0 = self:block(self:line("while ", self:value(cond), " do"))
      _with_0:stms(block)
      return _with_0
    end
  end,
  ["for"] = function(self, node)
    local name, bounds, block = unpack(node, 2)
    local loop = self:line("for ", self:name(name), " = ", self:value({
      "explist",
      unpack(bounds)
    }), " do")
    do
      local _with_0 = self:block(loop)
      _with_0:declare({
        name
      })
      _with_0:stms(block)
      return _with_0
    end
  end,
  foreach = function(self, node)
    local names, exps, block = unpack(node, 2)
    local loop
    do
      local _with_0 = self:line()
      _with_0:append("for ")
      loop = _with_0
    end
    do
      local _with_0 = self:block(loop)
      loop:append_list((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #names do
          local name = names[_index_0]
          _accum_0[_len_0] = _with_0:name(name, false)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), ", ")
      loop:append(" in ")
      loop:append_list((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #exps do
          local exp = exps[_index_0]
          _accum_0[_len_0] = self:value(exp)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), ",")
      loop:append(" do")
      _with_0:declare(names)
      _with_0:stms(block)
      return _with_0
    end
  end,
  export = function(self, node)
    local names = unpack(node, 2)
    if type(names) == "string" then
      if names == "*" then
        self.export_all = true
      elseif names == "^" then
        self.export_proper = true
      end
    else
      self:declare(names)
    end
    return nil
  end,
  run = function(self, code)
    code:call(self)
    return nil
  end,
  group = function(self, node)
    return self:stms(node[2])
  end,
  ["do"] = function(self, node)
    do
      local _with_0 = self:block()
      _with_0:stms(node[2])
      return _with_0
    end
  end,
  noop = function(self) end
}
end
preload["moonscript.cmd.watchers"] = function(...)
local remove_dupes
remove_dupes = function(list, key_fn)
  local seen = { }
  return (function()
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #list do
      local _continue_0 = false
      repeat
        local item = list[_index_0]
        local key
        if key_fn then
          key = key_fn(item)
        else
          key = item
        end
        if seen[key] then
          _continue_0 = true
          break
        end
        seen[key] = true
        local _value_0 = item
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    return _accum_0
  end)()
end
local plural
plural = function(count, word)
  return tostring(count) .. " " .. tostring(word) .. tostring(count == 1 and "" or "s")
end
local Watcher
do
  local _class_0
  local _base_0 = {
    start_msg = "Starting watch loop (Ctrl-C to exit)",
    print_start = function(self, mode, misc)
      return io.stderr:write(tostring(self.start_msg) .. " with " .. tostring(mode) .. " [" .. tostring(misc) .. "]\n")
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, file_list)
      self.file_list = file_list
    end,
    __base = _base_0,
    __name = "Watcher"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Watcher = _class_0
end
local InotifyWacher
do
  local _class_0
  local _parent_0 = Watcher
  local _base_0 = {
    get_dirs = function(self)
      local parse_dir
      parse_dir = require("moonscript.cmd.moonc").parse_dir
      local dirs
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = self.file_list
        for _index_0 = 1, #_list_0 do
          local _des_0 = _list_0[_index_0]
          local file_path
          file_path = _des_0[1]
          local dir = parse_dir(file_path)
          if dir == "" then
            dir = "./"
          end
          local _value_0 = dir
          _accum_0[_len_0] = _value_0
          _len_0 = _len_0 + 1
        end
        dirs = _accum_0
      end
      return remove_dupes(dirs)
    end,
    each_update = function(self)
      return coroutine.wrap(function()
        local dirs = self:get_dirs()
        self:print_start("inotify", plural(#dirs, "dir"))
        local wd_table = { }
        local inotify = require("inotify")
        local handle = inotify.init()
        for _index_0 = 1, #dirs do
          local dir = dirs[_index_0]
          local wd = handle:addwatch(dir, inotify.IN_CLOSE_WRITE, inotify.IN_MOVED_TO)
          wd_table[wd] = dir
        end
        while true do
          local events = handle:read()
          if not (events) then
            break
          end
          for _index_0 = 1, #events do
            local _continue_0 = false
            repeat
              local ev = events[_index_0]
              local fname = ev.name
              if not (fname:match("%.moon$")) then
                _continue_0 = true
                break
              end
              local dir = wd_table[ev.wd]
              if dir ~= "./" then
                fname = dir .. fname
              end
              coroutine.yield(fname)
              _continue_0 = true
            until true
            if not _continue_0 then
              break
            end
          end
        end
      end)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "InotifyWacher",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.available = function(self)
    return pcall(function()
      return require("inotify")
    end)
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  InotifyWacher = _class_0
end
local SleepWatcher
do
  local _class_0
  local _parent_0 = Watcher
  local _base_0 = {
    polling_rate = 1.0,
    get_sleep_func = function(self)
      local sleep
      pcall(function()
        sleep = require("socket").sleep
      end)
      sleep = sleep or require("moonscript")._sleep
      if not (sleep) then
        error("Missing sleep function; install LuaSocket")
      end
      return sleep
    end,
    each_update = function(self)
      return coroutine.wrap(function()
        local lfs = require("cc.lfs")
        local sleep = self:get_sleep_func()
        self:print_start("polling", plural(#self.file_list, "files"))
        local mod_time = { }
        while true do
          local _list_0 = self.file_list
          for _index_0 = 1, #_list_0 do
            local _continue_0 = false
            repeat
              local _des_0 = _list_0[_index_0]
              local file
              file = _des_0[1]
              local time = lfs.attributes(file, "modification")
              if not (time) then
                mod_time[file] = nil
                _continue_0 = true
                break
              end
              if not (mod_time[file]) then
                mod_time[file] = time
                _continue_0 = true
                break
              end
              if time > mod_time[file] then
                mod_time[file] = time
                coroutine.yield(file)
              end
              _continue_0 = true
            until true
            if not _continue_0 then
              break
            end
          end
          sleep(self.polling_rate)
        end
      end)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "SleepWatcher",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  SleepWatcher = _class_0
end
return {
  Watcher = Watcher,
  SleepWatcher = SleepWatcher,
  InotifyWacher = InotifyWacher
}
end
preload["moonscript.cmd.moonc"] = function(...)
local lfs = require("cc.lfs")
local split
split = require("moonscript.util").split
local dirsep, dirsep_chars, mkdir, normalize_dir, parse_dir, parse_file, convert_path, format_time, gettime, compile_file_text, write_file, compile_and_write, is_abs_path, path_to_target
dirsep = package.config:sub(1, 1)
if dirsep == "\\" then
  dirsep_chars = "\\/"
else
  dirsep_chars = dirsep
end
mkdir = function(path)
  local chunks = split(path, dirsep)
  local accum
  for _index_0 = 1, #chunks do
    local dir = chunks[_index_0]
    accum = accum and tostring(accum) .. tostring(dirsep) .. tostring(dir) or dir
    lfs.mkdir(accum)
  end
  return lfs.attributes(path, "mode")
end
normalize_dir = function(path)
  return path:match("^(.-)[" .. tostring(dirsep_chars) .. "]*$") .. dirsep
end
parse_dir = function(path)
  return (path:match("^(.-)[^" .. tostring(dirsep_chars) .. "]*$"))
end
parse_file = function(path)
  return (path:match("^.-([^" .. tostring(dirsep_chars) .. "]*)$"))
end
convert_path = function(path)
  local new_path = path:gsub("%.moon$", ".lua")
  if new_path == path then
    new_path = path .. ".lua"
  end
  return new_path
end
format_time = function(time)
  return ("%.3fms"):format(time * 1000)
end
do
  local socket
  gettime = function()
    if socket == nil then
      pcall(function()
        socket = require("socket")
      end)
      if not (socket) then
        socket = false
      end
    end
    if socket then
      return socket.gettime()
    else
      return nil, "LuaSocket needed for benchmark"
    end
  end
end
compile_file_text = function(text, opts)
  if opts == nil then
    opts = { }
  end
  local parse = require("moonscript.parse")
  local compile = require("moonscript.compile")
  local parse_time
  if opts.benchmark then
    parse_time = assert(gettime())
  end
  local tree, err = parse.string(text)
  if not (tree) then
    return nil, err
  end
  if parse_time then
    parse_time = gettime() - parse_time
  end
  if opts.show_parse_tree then
    local dump = require("moonscript.dump")
    print(dump.tree(tree))
    return true
  end
  local compile_time
  if opts.benchmark then
    compile_time = gettime()
  end
  do
    local mod = opts.transform_module
    if mod then
      local file = assert(loadfile(mod))
      local fn = assert(file())
      tree = assert(fn(tree))
    end
  end
  local code, posmap_or_err, err_pos = compile.tree(tree)
  if not (code) then
    return nil, compile.format_error(posmap_or_err, err_pos, text)
  end
  if compile_time then
    compile_time = gettime() - compile_time
  end
  if opts.show_posmap then
    local debug_posmap
    debug_posmap = require("moonscript.util").debug_posmap
    print("Pos", "Lua", ">>", "Moon")
    print(debug_posmap(posmap_or_err, text, code))
    return true
  end
  if opts.benchmark then
    print(table.concat({
      opts.fname or "stdin",
      "Parse time  \t" .. format_time(parse_time),
      "Compile time\t" .. format_time(compile_time),
      ""
    }, "\n"))
    return true
  end
  return code
end
write_file = function(fname, code)
  mkdir(parse_dir(fname))
  local f, err = io.open(fname, "wb")
  if not (f) then
    return nil, err
  end
  assert(f:write(code))
  assert(f:write("\n"))
  f:close()
  return "build"
end
compile_and_write = function(src, dest, opts)
  if opts == nil then
    opts = { }
  end
  local f = io.open(src)
  if not (f) then
    return nil, "Can't find file"
  end
  local text = assert(f:read("*a"))
  f:close()
  local code, err = compile_file_text(text, opts)
  if not code then
    return nil, err
  end
  if code == true then
    return true
  end
  if opts.print then
    print(code)
    return true
  end
  return write_file(dest, code)
end
is_abs_path = function(path)
  local first = path:sub(1, 1)
  if dirsep == "\\" then
    return first == "/" or first == "\\" or path:sub(2, 1) == ":"
  else
    return first == dirsep
  end
end
path_to_target = function(path, target_dir, base_dir)
  if target_dir == nil then
    target_dir = nil
  end
  if base_dir == nil then
    base_dir = nil
  end
  local target = convert_path(path)
  if target_dir then
    target_dir = normalize_dir(target_dir)
  end
  if base_dir and target_dir then
    local head = base_dir:match("^(.-)[^" .. tostring(dirsep_chars) .. "]*[" .. tostring(dirsep_chars) .. "]?$")
    if head then
      local start, stop = target:find(head, 1, true)
      if start == 1 then
        target = target:sub(stop + 1)
      end
    end
  end
  if target_dir then
    if is_abs_path(target) then
      target = parse_file(target)
    end
    target = target_dir .. target
  end
  return target
end
return {
  dirsep = dirsep,
  mkdir = mkdir,
  normalize_dir = normalize_dir,
  parse_dir = parse_dir,
  parse_file = parse_file,
  convert_path = convert_path,
  gettime = gettime,
  format_time = format_time,
  path_to_target = path_to_target,
  compile_file_text = compile_file_text,
  compile_and_write = compile_and_write
}
end
preload["moonscript.cmd.lint"] = function(...)
local insert
insert = table.insert
local Set
Set = require("moonscript.data").Set
local Block
Block = require("moonscript.compile").Block
local mtype
mtype = require("moonscript.util").moon.type
local default_whitelist = Set({
  '_G',
  '_VERSION',
  'assert',
  'bit32',
  'collectgarbage',
  'coroutine',
  'debug',
  'dofile',
  'error',
  'getfenv',
  'getmetatable',
  'io',
  'ipairs',
  'load',
  'loadfile',
  'loadstring',
  'math',
  'module',
  'next',
  'os',
  'package',
  'pairs',
  'pcall',
  'print',
  'rawequal',
  'rawget',
  'rawlen',
  'rawset',
  'require',
  'select',
  'setfenv',
  'setmetatable',
  'string',
  'table',
  'tonumber',
  'tostring',
  'type',
  'unpack',
  'xpcall',
  "nil",
  "true",
  "false"
})
local LinterBlock
do
  local _class_0
  local _parent_0 = Block
  local _base_0 = {
    lint_mark_used = function(self, name)
      if self.lint_unused_names and self.lint_unused_names[name] then
        self.lint_unused_names[name] = false
        return 
      end
      if self.parent then
        return self.parent:lint_mark_used(name)
      end
    end,
    lint_check_unused = function(self)
      if not (self.lint_unused_names and next(self.lint_unused_names)) then
        return 
      end
      local names_by_position = { }
      for name, pos in pairs(self.lint_unused_names) do
        local _continue_0 = false
        repeat
          if not (pos) then
            _continue_0 = true
            break
          end
          local _update_0 = pos
          names_by_position[_update_0] = names_by_position[_update_0] or { }
          insert(names_by_position[pos], name)
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      local tuples
      do
        local _accum_0 = { }
        local _len_0 = 1
        for pos, names in pairs(names_by_position) do
          _accum_0[_len_0] = {
            pos,
            names
          }
          _len_0 = _len_0 + 1
        end
        tuples = _accum_0
      end
      table.sort(tuples, function(a, b)
        return a[1] < b[1]
      end)
      for _index_0 = 1, #tuples do
        local _des_0 = tuples[_index_0]
        local pos, names
        pos, names = _des_0[1], _des_0[2]
        insert(self:get_root_block().lint_errors, {
          "assigned but unused " .. tostring(table.concat((function()
            local _accum_0 = { }
            local _len_0 = 1
            for _index_1 = 1, #names do
              local n = names[_index_1]
              _accum_0[_len_0] = "`" .. tostring(n) .. "`"
              _len_0 = _len_0 + 1
            end
            return _accum_0
          end)(), ", ")),
          pos
        })
      end
    end,
    render = function(self, ...)
      self:lint_check_unused()
      return _class_0.__parent.__base.render(self, ...)
    end,
    block = function(self, ...)
      do
        local _with_0 = _class_0.__parent.__base.block(self, ...)
        _with_0.block = self.block
        _with_0.render = self.render
        _with_0.get_root_block = self.get_root_block
        _with_0.lint_check_unused = self.lint_check_unused
        _with_0.lint_mark_used = self.lint_mark_used
        _with_0.value_compilers = self.value_compilers
        _with_0.statement_compilers = self.statement_compilers
        return _with_0
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, whitelist_globals, ...)
      if whitelist_globals == nil then
        whitelist_globals = default_whitelist
      end
      _class_0.__parent.__init(self, ...)
      self.get_root_block = function()
        return self
      end
      self.lint_errors = { }
      local vc = self.value_compilers
      self.value_compilers = setmetatable({
        ref = function(block, val)
          local name = val[2]
          if not (block:has_name(name) or whitelist_globals[name] or name:match("%.")) then
            insert(self.lint_errors, {
              "accessing global `" .. tostring(name) .. "`",
              val[-1]
            })
          end
          block:lint_mark_used(name)
          return vc.ref(block, val)
        end
      }, {
        __index = vc
      })
      local sc = self.statement_compilers
      self.statement_compilers = setmetatable({
        assign = function(block, node)
          local names = node[2]
          for _index_0 = 1, #names do
            local _continue_0 = false
            repeat
              local name = names[_index_0]
              if type(name) == "table" and name[1] == "temp_name" then
                _continue_0 = true
                break
              end
              local real_name, is_local = block:extract_assign_name(name)
              if not (is_local or real_name and not block:has_name(real_name, true)) then
                _continue_0 = true
                break
              end
              if real_name == "_" then
                _continue_0 = true
                break
              end
              block.lint_unused_names = block.lint_unused_names or { }
              block.lint_unused_names[real_name] = node[-1] or 0
              _continue_0 = true
            until true
            if not _continue_0 then
              break
            end
          end
          return sc.assign(block, node)
        end
      }, {
        __index = sc
      })
    end,
    __base = _base_0,
    __name = "LinterBlock",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  LinterBlock = _class_0
end
local format_lint
format_lint = function(errors, code, header)
  if not (next(errors)) then
    return 
  end
  local pos_to_line, get_line
  do
    local _obj_0 = require("moonscript.util")
    pos_to_line, get_line = _obj_0.pos_to_line, _obj_0.get_line
  end
  local formatted
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #errors do
      local _des_0 = errors[_index_0]
      local msg, pos
      msg, pos = _des_0[1], _des_0[2]
      if pos then
        local line = pos_to_line(code, pos)
        msg = "line " .. tostring(line) .. ": " .. tostring(msg)
        local line_text = "> " .. get_line(code, line)
        local sep_len = math.max(#msg, #line_text)
        _accum_0[_len_0] = table.concat({
          msg,
          ("="):rep(sep_len),
          line_text
        }, "\n")
      else
        _accum_0[_len_0] = msg
      end
      _len_0 = _len_0 + 1
    end
    formatted = _accum_0
  end
  if header then
    table.insert(formatted, 1, header)
  end
  return table.concat(formatted, "\n\n")
end
local whitelist_for_file
do
  local lint_config
  whitelist_for_file = function(fname)
    if not (lint_config) then
      lint_config = { }
      pcall(function()
        lint_config = require("lint_config")
      end)
    end
    if not (lint_config.whitelist_globals) then
      return default_whitelist
    end
    local final_list = { }
    for pattern, list in pairs(lint_config.whitelist_globals) do
      if fname:match(pattern) then
        for _index_0 = 1, #list do
          local item = list[_index_0]
          insert(final_list, item)
        end
      end
    end
    return setmetatable(Set(final_list), {
      __index = default_whitelist
    })
  end
end
local lint_code
lint_code = function(code, name, whitelist_globals)
  if name == nil then
    name = "string input"
  end
  local parse = require("moonscript.parse")
  local tree, err = parse.string(code)
  if not (tree) then
    return nil, err
  end
  local scope = LinterBlock(whitelist_globals)
  scope:stms(tree)
  scope:lint_check_unused()
  return format_lint(scope.lint_errors, code, name)
end
local lint_file
lint_file = function(fname)
  local f, err = io.open(fname)
  if not (f) then
    return nil, err
  end
  return lint_code(f:read("*a"), fname, whitelist_for_file(fname))
end
return {
  lint_code = lint_code,
  lint_file = lint_file
}
end
preload["moonscript.cmd.coverage"] = function(...)
local log
log = function(str)
  if str == nil then
    str = ""
  end
  return io.stderr:write(str .. "\n")
end
local create_counter
create_counter = function()
  return setmetatable({ }, {
    __index = function(self, name)
      do
        local tbl = setmetatable({ }, {
          __index = function(self)
            return 0
          end
        })
        self[name] = tbl
        return tbl
      end
    end
  })
end
local position_to_lines
position_to_lines = function(file_content, positions)
  local lines = { }
  local current_pos = 0
  local line_no = 1
  for char in file_content:gmatch(".") do
    do
      local count = rawget(positions, current_pos)
      if count then
        lines[line_no] = count
      end
    end
    if char == "\n" then
      line_no = line_no + 1
    end
    current_pos = current_pos + 1
  end
  return lines
end
local format_file
format_file = function(fname, positions)
  fname = fname:gsub("^@", "")
  local file = assert(io.open(fname))
  local content = file:read("*a")
  file:close()
  local lines = position_to_lines(content, positions)
  log("------| @" .. tostring(fname))
  local line_no = 1
  for line in (content .. "\n"):gmatch("(.-)\n") do
    local foramtted_no = ("% 5d"):format(line_no)
    local sym = lines[line_no] and "*" or " "
    log(tostring(sym) .. tostring(foramtted_no) .. "| " .. tostring(line))
    line_no = line_no + 1
  end
  return log()
end
local CodeCoverage
do
  local _class_0
  local _base_0 = {
    reset = function(self)
      self.line_counts = create_counter()
    end,
    start = function(self)
      return debug.sethook((function()
        local _base_1 = self
        local _fn_0 = _base_1.process_line
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)(), "l")
    end,
    stop = function(self)
      return debug.sethook()
    end,
    print_results = function(self)
      return self:format_results()
    end,
    process_line = function(self, _, line_no)
      local debug_data = debug.getinfo(2, "S")
      local source = debug_data.source
      local _update_0, _update_1 = source, line_no
      self.line_counts[_update_0][_update_1] = self.line_counts[_update_0][_update_1] + 1
    end,
    format_results = function(self)
      local line_table = require("moonscript.line_tables")
      local positions = create_counter()
      for file, lines in pairs(self.line_counts) do
        local _continue_0 = false
        repeat
          local file_table = line_table[file]
          if not (file_table) then
            _continue_0 = true
            break
          end
          for line, count in pairs(lines) do
            local _continue_1 = false
            repeat
              local position = file_table[line]
              if not (position) then
                _continue_1 = true
                break
              end
              local _update_0, _update_1 = file, position
              positions[_update_0][_update_1] = positions[_update_0][_update_1] + count
              _continue_1 = true
            until true
            if not _continue_1 then
              break
            end
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      for file, ps in pairs(positions) do
        format_file(file, ps)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      return self:reset()
    end,
    __base = _base_0,
    __name = "CodeCoverage"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CodeCoverage = _class_0
end
return {
  CodeCoverage = CodeCoverage
}
end
preload["moonscript.cmd.args"] = function(...)
local unpack
unpack = require("moonscript.util").unpack
local parse_spec
parse_spec = function(spec)
  local flags, words
  if type(spec) == "table" then
    flags, words = unpack(spec), spec
  else
    flags, words = spec, { }
  end
  assert("no flags for arguments")
  local out = { }
  for part in flags:gmatch("%w:?") do
    if part:match(":$") then
      out[part:sub(1, 1)] = {
        value = true
      }
    else
      out[part] = { }
    end
  end
  return out
end
local parse_arguments
parse_arguments = function(spec, args)
  spec = parse_spec(spec)
  local out = { }
  local remaining = { }
  local last_flag = nil
  for _index_0 = 1, #args do
    local _continue_0 = false
    repeat
      local arg = args[_index_0]
      local group = { }
      if last_flag then
        out[last_flag] = arg
        _continue_0 = true
        break
      end
      do
        local flag = arg:match("-(%w+)")
        if flag then
          do
            local short_name = spec[flag]
            if short_name then
              out[short_name] = true
            else
              for char in flag:gmatch(".") do
                out[char] = true
              end
            end
          end
          _continue_0 = true
          break
        end
      end
      table.insert(remaining, arg)
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return out, remaining
end
return {
  parse_arguments = parse_arguments,
  parse_spec = parse_spec
}
end
preload["moonscript.base"] = function(...)
local compile = require("moonscript.compile")
local parse = require("moonscript.parse")
local concat, insert, remove
do
  local _obj_0 = table
  concat, insert, remove = _obj_0.concat, _obj_0.insert, _obj_0.remove
end
local split, dump, get_options, unpack
do
  local _obj_0 = require("moonscript.util")
  split, dump, get_options, unpack = _obj_0.split, _obj_0.dump, _obj_0.get_options, _obj_0.unpack
end
local lua = {
  loadstring = loadstring,
  load = load
}
local dirsep, line_tables, create_moonpath, to_lua, moon_loader, loadstring, loadfile, dofile, insert_loader, remove_loader
dirsep = "/"
line_tables = require("moonscript.line_tables")
create_moonpath = function(package_path)
  local moonpaths
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = split(package_path, ";")
    for _index_0 = 1, #_list_0 do
      local _continue_0 = false
      repeat
        local path = _list_0[_index_0]
        local prefix = path:match("^(.-)%.lua$")
        if not (prefix) then
          _continue_0 = true
          break
        end
        local _value_0 = prefix .. ".moon"
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    moonpaths = _accum_0
  end
  return concat(moonpaths, ";")
end
to_lua = function(text, options)
  if options == nil then
    options = { }
  end
  if "string" ~= type(text) then
    local t = type(text)
    return nil, "expecting string (got " .. t .. ")"
  end
  local tree, err = parse.string(text)
  if not tree then
    return nil, err
  end
  local code, ltable, pos = compile.tree(tree, options)
  if not code then
    return nil, compile.format_error(ltable, pos, text)
  end
  return code, ltable
end
moon_loader = function(name)
  local name_path = name:gsub("%.", dirsep)
  local file, file_path
  for path in package.moonpath:gmatch("[^;]+") do
    file_path = path:gsub("?", name_path)
    file = io.open(file_path)
    if file then
      break
    end
  end
  if file then
    local text = file:read("*a")
    file:close()
    local res, err = loadstring(text, "@" .. tostring(file_path))
    if not res then
      error(file_path .. ": " .. err)
    end
    return res
  end
  return nil, "Could not find moon file"
end
loadstring = function(...)
  local options, str, chunk_name, mode, env = get_options(...)
  chunk_name = chunk_name or "=(moonscript.loadstring)"
  local code, ltable_or_err = to_lua(str, options)
  if not (code) then
    return nil, ltable_or_err
  end
  if chunk_name then
    line_tables[chunk_name] = ltable_or_err
  end
  return (lua.load or lua.loadstring)(code, chunk_name, unpack({
    mode,
    env
  }))
end
loadfile = function(fname, ...)
  local file, err = io.open(fname)
  if not (file) then
    return nil, err
  end
  local text = assert(file:read("*a"))
  file:close()
  return loadstring(text, "@" .. tostring(fname), ...)
end
dofile = function(...)
  local f = assert(loadfile(...))
  return f()
end
insert_loader = function(pos)
  if pos == nil then
    pos = 2
  end
  if not package.moonpath then
    package.moonpath = create_moonpath(package.path)
  end
  local loaders = package.loaders or package.searchers
  for _index_0 = 1, #loaders do
    local loader = loaders[_index_0]
    if loader == moon_loader then
      return false
    end
  end
  insert(loaders, pos, moon_loader)
  return true
end
remove_loader = function()
  local loaders = package.loaders or package.searchers
  for i, loader in ipairs(loaders) do
    if loader == moon_loader then
      remove(loaders, i)
      return true
    end
  end
  return false
end
return {
  _NAME = "moonscript",
  insert_loader = insert_loader,
  remove_loader = remove_loader,
  to_lua = to_lua,
  moon_loader = moon_loader,
  dirsep = dirsep,
  dofile = dofile,
  loadfile = loadfile,
  loadstring = loadstring,
  create_moonpath = create_moonpath
}
end
preload["cc.lpeg"] = function(...)
-- LuLPeg, a pure Lua port of LPeg, Roberto Ierusalimschy's
-- Parsing Expression Grammars library.
-- 
-- Copyright (C) Pierre-Yves Gerardy.
-- Released under the Romantic WTF Public License (cf. the LICENSE
-- file or the end of this file, whichever is present).
-- 
-- See http://www.inf.puc-rio.br/~roberto/lpeg/ for the original.
-- 
-- The re.lua module and the test suite (tests/lpeg.*.*.tests.lua)
-- are part of the original LPeg distribution.
local _ENV,       loaded, packages, release, require_
    = _ENV or _G, {},     {},       true,    require

local function require(...)
    local lib = ...

    -- is it a private file?
    if loaded[lib] then
        return loaded[lib]
    elseif packages[lib] then
        loaded[lib] = packages[lib](lib)
        return loaded[lib]
    else
        return require_(lib)
    end
end

--=============================================================================
do local _ENV = _ENV
packages['API'] = function (...)

local assert, error, ipairs, pairs, pcall, print
    , require, select, tonumber, tostring, type
    = assert, error, ipairs, pairs, pcall, print
    , require, select, tonumber, tostring, type
local t, u = require"table", require"util"
local _ENV = u.noglobals() ---------------------------------------------------
local t_concat = t.concat
local   checkstring,   copy,   fold,   load,   map_fold,   map_foldr,   setify, t_pack, t_unpack
    = u.checkstring, u.copy, u.fold, u.load, u.map_fold, u.map_foldr, u.setify, u.pack, u.unpack
local
function charset_error(index, charset)
    error("Character at position ".. index + 1
            .." is not a valid "..charset.." one.",
        2)
end
return function(Builder, LL) -- module wrapper -------------------------------
local cs = Builder.charset
local constructors, LL_ispattern
    = Builder.constructors, LL.ispattern
local truept, falsept, Cppt
    = constructors.constant.truept
    , constructors.constant.falsept
    , constructors.constant.Cppt
local    split_int,    validate
    = cs.split_int, cs.validate
local Range, Set, S_union, S_tostring
    = Builder.Range, Builder.set.new
    , Builder.set.union, Builder.set.tostring
local factorize_choice, factorize_lookahead, factorize_sequence, factorize_unm
local
function makechar(c)
    return constructors.aux("char", c)
end
local
function LL_P (...)
    local v, n = (...), select('#', ...)
    if n == 0 then error"bad argument #1 to 'P' (value expected)" end
    local typ = type(v)
    if LL_ispattern(v) then
        return v
    elseif typ == "function" then
        return
            LL.Cmt("", v)
    elseif typ == "string" then
        local success, index = validate(v)
        if not success then
            charset_error(index, cs.name)
        end
        if v == "" then return truept end
        return
            map_foldr(split_int(v), makechar, Builder.sequence)
    elseif typ == "table" then
        local g = copy(v)
        if g[1] == nil then error("grammar has no initial rule") end
        if not LL_ispattern(g[1]) then g[1] = LL.V(g[1]) end
        return
            constructors.none("grammar", g)
    elseif typ == "boolean" then
        return v and truept or falsept
    elseif typ == "number" then
        if v == 0 then
            return truept
        elseif v > 0 then
            return
                constructors.aux("any", v)
        else
            return
                - constructors.aux("any", -v)
        end
    else
        error("bad argument #1 to 'P' (lpeg-pattern expected, got "..typ..")")
    end
end
LL.P = LL_P
local
function LL_S (set)
    if set == "" then
        return
            falsept
    else
        local success
        set = checkstring(set, "S")
        return
            constructors.aux("set", Set(split_int(set)), set)
    end
end
LL.S = LL_S
local
function LL_R (...)
    if select('#', ...) == 0 then
        return LL_P(false)
    else
        local range = Range(1,0)--Set("")
        for _, r in ipairs{...} do
            r = checkstring(r, "R")
            assert(#r == 2, "bad argument #1 to 'R' (range must have two characters)")
            range = S_union ( range, Range(t_unpack(split_int(r))) )
        end
        return
            constructors.aux("set", range)
    end
end
LL.R = LL_R
local
function LL_V (name)
    assert(name ~= nil)
    return
        constructors.aux("ref",  name)
end
LL.V = LL_V
do
    local one = setify{"set", "range", "one", "char"}
    local zero = setify{"true", "false", "lookahead", "unm"}
    local forbidden = setify{
        "Carg", "Cb", "C", "Cf",
        "Cg", "Cs", "Ct", "/zero",
        "Clb", "Cmt", "Cc", "Cp",
        "div_string", "div_number", "div_table", "div_function",
        "at least", "at most", "behind"
    }
    local function fixedlen(pt, gram, cycle)
        local typ = pt.pkind
        if forbidden[typ] then return false
        elseif one[typ]  then return 1
        elseif zero[typ] then return 0
        elseif typ == "string" then return #pt.as_is
        elseif typ == "any" then return pt.aux
        elseif typ == "choice" then
            local l1, l2 = fixedlen(pt[1], gram, cycle), fixedlen(pt[2], gram, cycle)
            return (l1 == l2) and l1
        elseif typ == "sequence" then
            local l1, l2 = fixedlen(pt[1], gram, cycle), fixedlen(pt[2], gram, cycle)
            return l1 and l2 and l1 + l2
        elseif typ == "grammar" then
            if pt.aux[1].pkind == "ref" then
                return fixedlen(pt.aux[pt.aux[1].aux], pt.aux, {})
            else
                return fixedlen(pt.aux[1], pt.aux, {})
            end
        elseif typ == "ref" then
            if cycle[pt] then return false end
            cycle[pt] = true
            return fixedlen(gram[pt.aux], gram, cycle)
        else
            print(typ,"is not handled by fixedlen()")
        end
    end
    function LL.B (pt)
        pt = LL_P(pt)
        local len = fixedlen(pt)
        assert(len, "A 'behind' pattern takes a fixed length pattern as argument.")
        if len >= 260 then error("Subpattern too long in 'behind' pattern constructor.") end
        return
            constructors.both("behind", pt, len)
    end
end
local function nameify(a, b)
    return ('%s:%s'):format(a.id, b.id)
end
local
function choice (a, b)
    local name = nameify(a, b)
    local ch = Builder.ptcache.choice[name]
    if not ch then
        ch = factorize_choice(a, b) or constructors.binary("choice", a, b)
        Builder.ptcache.choice[name] = ch
    end
    return ch
end
function LL.__add (a, b)
    return
        choice(LL_P(a), LL_P(b))
end
local
function sequence (a, b)
    local name = nameify(a, b)
    local seq = Builder.ptcache.sequence[name]
    if not seq then
        seq = factorize_sequence(a, b) or constructors.binary("sequence", a, b)
        Builder.ptcache.sequence[name] = seq
    end
    return seq
end
Builder.sequence = sequence
function LL.__mul (a, b)
    return
        sequence(LL_P(a), LL_P(b))
end
local
function LL_lookahead (pt)
    if pt == truept
    or pt == falsept
    or pt.pkind == "unm"
    or pt.pkind == "lookahead"
    then
        return pt
    end
    return
        constructors.subpt("lookahead", pt)
end
LL.__len = LL_lookahead
LL.L = LL_lookahead
local
function LL_unm(pt)
    return
        factorize_unm(pt)
        or constructors.subpt("unm", pt)
end
LL.__unm = LL_unm
local
function LL_sub (a, b)
    a, b = LL_P(a), LL_P(b)
    return LL_unm(b) * a
end
LL.__sub = LL_sub
local
function LL_repeat (pt, n)
    local success
    success, n = pcall(tonumber, n)
    assert(success and type(n) == "number",
        "Invalid type encountered at right side of '^'.")
    return constructors.both(( n < 0 and "at most" or "at least" ), pt, n)
end
LL.__pow = LL_repeat
for _, cap in pairs{"C", "Cs", "Ct"} do
    LL[cap] = function(pt)
        pt = LL_P(pt)
        return
            constructors.subpt(cap, pt)
    end
end
LL["Cb"] = function(aux)
    return
        constructors.aux("Cb", aux)
end
LL["Carg"] = function(aux)
    assert(type(aux)=="number", "Number expected as parameter to Carg capture.")
    assert( 0 < aux and aux <= 200, "Argument out of bounds in Carg capture.")
    return
        constructors.aux("Carg", aux)
end
local
function LL_Cp ()
    return Cppt
end
LL.Cp = LL_Cp
local
function LL_Cc (...)
    return
        constructors.none("Cc", t_pack(...))
end
LL.Cc = LL_Cc
for _, cap in pairs{"Cf", "Cmt"} do
    local msg = "Function expected in "..cap.." capture"
    LL[cap] = function(pt, aux)
    assert(type(aux) == "function", msg)
    pt = LL_P(pt)
    return
        constructors.both(cap, pt, aux)
    end
end
local
function LL_Cg (pt, tag)
    pt = LL_P(pt)
    if tag ~= nil then
        return
            constructors.both("Clb", pt, tag)
    else
        return
            constructors.subpt("Cg", pt)
    end
end
LL.Cg = LL_Cg
local valid_slash_type = setify{"string", "number", "table", "function"}
local
function LL_slash (pt, aux)
    if LL_ispattern(aux) then
        error"The right side of a '/' capture cannot be a pattern."
    elseif not valid_slash_type[type(aux)] then
        error("The right side of a '/' capture must be of type "
            .."string, number, table or function.")
    end
    local name
    if aux == 0 then
        name = "/zero"
    else
        name = "div_"..type(aux)
    end
    return
        constructors.both(name, pt, aux)
end
LL.__div = LL_slash
if Builder.proxymt then
    for k, v in pairs(LL) do
        if k:match"^__" then
            Builder.proxymt[k] = v
        end
    end
else
    LL.__index = LL
end
local factorizer
    = Builder.factorizer(Builder, LL)
factorize_choice,  factorize_lookahead,  factorize_sequence,  factorize_unm =
factorizer.choice, factorizer.lookahead, factorizer.sequence, factorizer.unm
end -- module wrapper --------------------------------------------------------

end
end
--=============================================================================
do local _ENV = _ENV
packages['analyzer'] = function (...)

local u = require"util"
local nop, weakkey = u.nop, u.weakkey
local hasVcache, hasCmtcache , lengthcache
    = weakkey{}, weakkey{},    weakkey{}
return {
    hasV = nop,
    hasCmt = nop,
    length = nop,
    hasCapture = nop
}

end
end
--=============================================================================
do local _ENV = _ENV
packages['charsets'] = function (...)

local s, t, u = require"string", require"table", require"util"
local _ENV = u.noglobals() ----------------------------------------------------
local copy = u.copy
local s_char, s_sub, s_byte, t_concat, t_insert
    = s.char, s.sub, s.byte, t.concat, t.insert
local
function utf8_offset (byte)
    if byte < 128 then return 0, byte
    elseif byte < 192 then
        error("Byte values between 0x80 to 0xBF cannot start a multibyte sequence")
    elseif byte < 224 then return 1, byte - 192
    elseif byte < 240 then return 2, byte - 224
    elseif byte < 248 then return 3, byte - 240
    elseif byte < 252 then return 4, byte - 248
    elseif byte < 254 then return 5, byte - 252
    else
        error("Byte values between 0xFE and OxFF cannot start a multibyte sequence")
    end
end
local
function utf8_validate (subject, start, finish)
    start = start or 1
    finish = finish or #subject
    local offset, char
        = 0
    for i = start,finish do
        local b = s_byte(subject,i)
        if offset == 0 then
            char = i
            success, offset = pcall(utf8_offset, b)
            if not success then return false, char - 1 end
        else
            if not (127 < b and b < 192) then
                return false, char - 1
            end
            offset = offset -1
        end
    end
    if offset ~= 0 then return nil, char - 1 end -- Incomplete input.
    return true, finish
end
local
function utf8_next_int (subject, i)
    i = i and i+1 or 1
    if i > #subject then return end
    local c = s_byte(subject, i)
    local offset, val = utf8_offset(c)
    for i = i+1, i+offset do
        c = s_byte(subject, i)
        val = val * 64 + (c-128)
    end
  return i + offset, i, val
end
local
function utf8_next_char (subject, i)
    i = i and i+1 or 1
    if i > #subject then return end
    local offset = utf8_offset(s_byte(subject,i))
    return i + offset, i, s_sub(subject, i, i + offset)
end
local
function utf8_split_int (subject)
    local chars = {}
    for _, _, c in utf8_next_int, subject do
        t_insert(chars,c)
    end
    return chars
end
local
function utf8_split_char (subject)
    local chars = {}
    for _, _, c in utf8_next_char, subject do
        t_insert(chars,c)
    end
    return chars
end
local
function utf8_get_int(subject, i)
    if i > #subject then return end
    local c = s_byte(subject, i)
    local offset, val = utf8_offset(c)
    for i = i+1, i+offset do
        c = s_byte(subject, i)
        val = val * 64 + ( c - 128 )
    end
    return val, i + offset + 1
end
local
function split_generator (get)
    if not get then return end
    return function(subject)
        local res = {}
        local o, i = true
        while o do
            o,i = get(subject, i)
            res[#res] = o
        end
        return res
    end
end
local
function merge_generator (char)
    if not char then return end
    return function(ary)
        local res = {}
        for i = 1, #ary do
            t_insert(res,char(ary[i]))
        end
        return t_concat(res)
    end
end
local
function utf8_get_int2 (subject, i)
    local byte, b5, b4, b3, b2, b1 = s_byte(subject, i)
    if byte < 128 then return byte, i + 1
    elseif byte < 192 then
        error("Byte values between 0x80 to 0xBF cannot start a multibyte sequence")
    elseif byte < 224 then
        return (byte - 192)*64 + s_byte(subject, i+1), i+2
    elseif byte < 240 then
            b2, b1 = s_byte(subject, i+1, i+2)
        return (byte-224)*4096 + b2%64*64 + b1%64, i+3
    elseif byte < 248 then
        b3, b2, b1 = s_byte(subject, i+1, i+2, 1+3)
        return (byte-240)*262144 + b3%64*4096 + b2%64*64 + b1%64, i+4
    elseif byte < 252 then
        b4, b3, b2, b1 = s_byte(subject, i+1, i+2, 1+3, i+4)
        return (byte-248)*16777216 + b4%64*262144 + b3%64*4096 + b2%64*64 + b1%64, i+5
    elseif byte < 254 then
        b5, b4, b3, b2, b1 = s_byte(subject, i+1, i+2, 1+3, i+4, i+5)
        return (byte-252)*1073741824 + b5%64*16777216 + b4%64*262144 + b3%64*4096 + b2%64*64 + b1%64, i+6
    else
        error("Byte values between 0xFE and OxFF cannot start a multibyte sequence")
    end
end
local
function utf8_get_char(subject, i)
    if i > #subject then return end
    local offset = utf8_offset(s_byte(subject,i))
    return s_sub(subject, i, i + offset), i + offset + 1
end
local
function utf8_char(c)
    if     c < 128 then
        return                                                                               s_char(c)
    elseif c < 2048 then
        return                                                          s_char(192 + c/64, 128 + c%64)
    elseif c < 55296 or 57343 < c and c < 65536 then
        return                                         s_char(224 + c/4096, 128 + c/64%64, 128 + c%64)
    elseif c < 2097152 then
        return                      s_char(240 + c/262144, 128 + c/4096%64, 128 + c/64%64, 128 + c%64)
    elseif c < 67108864 then
        return s_char(248 + c/16777216, 128 + c/262144%64, 128 + c/4096%64, 128 + c/64%64, 128 + c%64)
    elseif c < 2147483648 then
        return s_char( 252 + c/1073741824,
                   128 + c/16777216%64, 128 + c/262144%64, 128 + c/4096%64, 128 + c/64%64, 128 + c%64)
    end
    error("Bad Unicode code point: "..c..".")
end
local
function binary_validate (subject, start, finish)
    start = start or 1
    finish = finish or #subject
    return true, finish
end
local
function binary_next_int (subject, i)
    i = i and i+1 or 1
    if i >= #subject then return end
    return i, i, s_sub(subject, i, i)
end
local
function binary_next_char (subject, i)
    i = i and i+1 or 1
    if i > #subject then return end
    return i, i, s_byte(subject,i)
end
local
function binary_split_int (subject)
    local chars = {}
    for i = 1, #subject do
        t_insert(chars, s_byte(subject,i))
    end
    return chars
end
local
function binary_split_char (subject)
    local chars = {}
    for i = 1, #subject do
        t_insert(chars, s_sub(subject,i,i))
    end
    return chars
end
local
function binary_get_int(subject, i)
    return s_byte(subject, i), i + 1
end
local
function binary_get_char(subject, i)
    return s_sub(subject, i, i), i + 1
end
local charsets = {
    binary = {
        name = "binary",
        binary = true,
        validate   = binary_validate,
        split_char = binary_split_char,
        split_int  = binary_split_int,
        next_char  = binary_next_char,
        next_int   = binary_next_int,
        get_char   = binary_get_char,
        get_int    = binary_get_int,
        tochar    = s_char
    },
    ["UTF-8"] = {
        name = "UTF-8",
        validate   = utf8_validate,
        split_char = utf8_split_char,
        split_int  = utf8_split_int,
        next_char  = utf8_next_char,
        next_int   = utf8_next_int,
        get_char   = utf8_get_char,
        get_int    = utf8_get_int
    }
}
return function (Builder)
    local cs = Builder.options.charset or "binary"
    if charsets[cs] then
        Builder.charset = copy(charsets[cs])
        Builder.binary_split_int = binary_split_int
    else
        error("NYI: custom charsets")
    end
end

end
end
--=============================================================================
do local _ENV = _ENV
packages['compat'] = function (...)

local _, debug, jit
_, debug = pcall(require, "debug")
_, jit = pcall(require, "jit")
jit = _ and jit
local compat = {
    debug = debug,
    lua51 = (_VERSION == "Lua 5.1") and not jit,
    lua52 = _VERSION == "Lua 5.2",
    luajit = jit and true or false,
    jit = jit and jit.status(),
    lua52_len = not #setmetatable({},{__len = function()end}),
    proxies = pcall(function()
        local prox = newproxy(true)
        local prox2 = newproxy(prox)
        assert (type(getmetatable(prox)) == "table"
                and (getmetatable(prox)) == (getmetatable(prox2)))
    end),
    _goto = not not(loadstring or load)"::R::"
}
return compat

end
end
--=============================================================================
do local _ENV = _ENV
packages['compiler'] = function (...)
local assert, error, pairs, print, rawset, select, setmetatable, tostring, type
    = assert, error, pairs, print, rawset, select, setmetatable, tostring, type
local s, t, u = require"string", require"table", require"util"
local _ENV = u.noglobals() ----------------------------------------------------
local s_byte, s_sub, t_concat, t_insert, t_remove, t_unpack
    = s.byte, s.sub, t.concat, t.insert, t.remove, u.unpack
local   load,   map,   map_all, t_pack
    = u.load, u.map, u.map_all, u.pack
local expose = u.expose
return function(Builder, LL)
local evaluate, LL_ispattern =  LL.evaluate, LL.ispattern
local charset = Builder.charset
local compilers = {}
local
function compile(pt, ccache)
    if not LL_ispattern(pt) then
        error("pattern expected")
    end
    local typ = pt.pkind
    if typ == "grammar" then
        ccache = {}
    elseif typ == "ref" or typ == "choice" or typ == "sequence" then
        if not ccache[pt] then
            ccache[pt] = compilers[typ](pt, ccache)
        end
        return ccache[pt]
    end
    if not pt.compiled then
        pt.compiled = compilers[pt.pkind](pt, ccache)
    end
    return pt.compiled
end
LL.compile = compile
local
function clear_captures(ary, ci)
    for i = ci, #ary do ary[i] = nil end
end
local LL_compile, LL_evaluate, LL_P
    = LL.compile, LL.evaluate, LL.P
local function computeidex(i, len)
    if i == 0 or i == 1 or i == nil then return 1
    elseif type(i) ~= "number" then error"number or nil expected for the stating index"
    elseif i > 0 then return i > len and len + 1 or i
    else return len + i < 0 and 1 or len + i + 1
    end
end
local function newcaps()
    return {
        kind = {},
        bounds = {},
        openclose = {},
        aux = -- [[DBG]] dbgcaps
            {}
    }
end
local
function _match(dbg, pt, sbj, si, ...)
        if dbg then -------------
            print("@!!! Match !!!@", pt)
        end ---------------------
    pt = LL_P(pt)
    assert(type(sbj) == "string", "string expected for the match subject")
    si = computeidex(si, #sbj)
        if dbg then -------------
            print(("-"):rep(30))
            print(pt.pkind)
            LL.pprint(pt)
        end ---------------------
    local matcher = compile(pt, {})
    local caps = newcaps()
    local matcher_state = {grammars = {}, args = {n = select('#',...),...}, tags = {}}
    local  success, final_si, ci = matcher(sbj, si, caps, 1, matcher_state)
        if dbg then -------------
            print("!!! Done Matching !!! success: ", success,
                "final position", final_si, "final cap index", ci,
                "#caps", #caps.openclose)
        end----------------------
    if success then
        clear_captures(caps.kind, ci)
        clear_captures(caps.aux, ci)
            if dbg then -------------
            print("trimmed cap index = ", #caps + 1)
            LL.cprint(caps, sbj, 1)
            end ---------------------
        local values, _, vi = LL_evaluate(caps, sbj, 1, 1)
            if dbg then -------------
                print("#values", vi)
                expose(values)
            end ---------------------
        if vi == 0
        then return final_si
        else return t_unpack(values, 1, vi) end
    else
        if dbg then print("Failed") end
        return nil
    end
end
function LL.match(...)
    return _match(false, ...)
end
function LL.dmatch(...)
    return _match(true, ...)
end
for _, v in pairs{
    "C", "Cf", "Cg", "Cs", "Ct", "Clb",
    "div_string", "div_table", "div_number", "div_function"
} do
    compilers[v] = load(([=[
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
    end]=]):gsub("XXXX", v), v.." compiler")(compile, expose, type, LL)
end
compilers["Carg"] = function (pt, ccache)
    local n = pt.aux
    return function (sbj, si, caps, ci, state)
        if state.args.n < n then error("reference to absent argument #"..n) end
        caps.kind      [ci] = "value"
        caps.bounds    [ci] = si
        if state.args[n] == nil then
            caps.openclose [ci] = 1/0
            caps.aux       [ci] = 1/0
        else
            caps.openclose [ci] = si
            caps.aux       [ci] = state.args[n]
        end
        return true, si, ci + 1
    end
end
for _, v in pairs{
    "Cb", "Cc", "Cp"
} do
    compilers[v] = load(([=[
    return function (pt, ccache)
        local this_aux = pt.aux
        return function (sbj, si, caps, ci, state)
            caps.kind      [ci] = "XXXX"
            caps.bounds    [ci] = si
            caps.openclose [ci] = si
            caps.aux       [ci] = this_aux or false
            return true, si, ci + 1
        end
    end]=]):gsub("XXXX", v), v.." compiler")(expose)
end
compilers["/zero"] = function (pt, ccache)
    local matcher = compile(pt.pattern, ccache)
    return function (sbj, si, caps, ci, state)
        local success, nsi = matcher(sbj, si, caps, ci, state)
        clear_captures(caps.aux, ci)
        return success, nsi, ci
    end
end
local function pack_Cmt_caps(i,...) return i, t_pack(...) end
compilers["Cmt"] = function (pt, ccache)
    local matcher, func = compile(pt.pattern, ccache), pt.aux
    return function (sbj, si, caps, ci, state)
        local success, Cmt_si, Cmt_ci = matcher(sbj, si, caps, ci, state)
        if not success then
            clear_captures(caps.aux, ci)
            return false, si, ci
        end
        local final_si, values
        if Cmt_ci == ci then
            final_si, values = pack_Cmt_caps(
                func(sbj, Cmt_si, s_sub(sbj, si, Cmt_si - 1))
            )
        else
            clear_captures(caps.aux, Cmt_ci)
            clear_captures(caps.kind, Cmt_ci)
            local cps, _, nn = evaluate(caps, sbj, ci)
                        final_si, values = pack_Cmt_caps(
                func(sbj, Cmt_si, t_unpack(cps, 1, nn))
            )
        end
        if not final_si then
            return false, si, ci
        end
        if final_si == true then final_si = Cmt_si end
        if type(final_si) == "number"
        and si <= final_si
        and final_si <= #sbj + 1
        then
            local kind, bounds, openclose, aux
                = caps.kind, caps.bounds, caps.openclose, caps.aux
            for i = 1, values.n do
                kind      [ci] = "value"
                bounds    [ci] = si
                if values[i] == nil then
                    caps.openclose [ci] = 1/0
                    caps.aux       [ci] = 1/0
                else
                    caps.openclose [ci] = final_si
                    caps.aux       [ci] = values[i]
                end
                ci = ci + 1
            end
        elseif type(final_si) == "number" then
            error"Index out of bounds returned by match-time capture."
        else
            error("Match time capture must return a number, a boolean or nil"
                .." as first argument, or nothing at all.")
        end
        return true, final_si, ci
    end
end
compilers["string"] = function (pt, ccache)
    local S = pt.aux
    local N = #S
    return function(sbj, si, caps, ci, state)
        local in_1 = si - 1
        for i = 1, N do
            local c
            c = s_byte(sbj,in_1 + i)
            if c ~= S[i] then
                return false, si, ci
            end
        end
        return true, si + N, ci
    end
end
compilers["char"] = function (pt, ccache)
    return load(([=[
        local s_byte, s_char = ...
        return function(sbj, si, caps, ci, state)
            local c, nsi = s_byte(sbj, si), si + 1
            if c ~= __C0__ then
                return false, si, ci
            end
            return true, nsi, ci
        end]=]):gsub("__C0__", tostring(pt.aux)))(s_byte, ("").char)
end
local
function truecompiled (sbj, si, caps, ci, state)
    return true, si, ci
end
compilers["true"] = function (pt)
    return truecompiled
end
local
function falsecompiled (sbj, si, caps, ci, state)
    return false, si, ci
end
compilers["false"] = function (pt)
    return falsecompiled
end
local
function eoscompiled (sbj, si, caps, ci, state)
    return si > #sbj, si, ci
end
compilers["eos"] = function (pt)
    return eoscompiled
end
local
function onecompiled (sbj, si, caps, ci, state)
    local char, _ = s_byte(sbj, si), si + 1
    if char
    then return true, si + 1, ci
    else return false, si, ci end
end
compilers["one"] = function (pt)
    return onecompiled
end
compilers["any"] = function (pt)
    local N = pt.aux
    if N == 1 then
        return onecompiled
    else
        N = pt.aux - 1
        return function (sbj, si, caps, ci, state)
            local n = si + N
            if n <= #sbj then
                return true, n + 1, ci
            else
                return false, si, ci
            end
        end
    end
end
do
    local function checkpatterns(g)
        for k,v in pairs(g.aux) do
            if not LL_ispattern(v) then
                error(("rule 'A' is not a pattern"):gsub("A", tostring(k)))
            end
        end
    end
    compilers["grammar"] = function (pt, ccache)
        checkpatterns(pt)
        local gram = map_all(pt.aux, compile, ccache)
        local start = gram[1]
        return function (sbj, si, caps, ci, state)
            t_insert(state.grammars, gram)
            local success, nsi, ci = start(sbj, si, caps, ci, state)
            t_remove(state.grammars)
            return success, nsi, ci
        end
    end
end
local dummy_acc = {kind={}, bounds={}, openclose={}, aux={}}
compilers["behind"] = function (pt, ccache)
    local matcher, N = compile(pt.pattern, ccache), pt.aux
    return function (sbj, si, caps, ci, state)
        if si <= N then return false, si, ci end
        local success = matcher(sbj, si - N, dummy_acc, ci, state)
        dummy_acc.aux = {}
        return success, si, ci
    end
end
compilers["range"] = function (pt)
    local ranges = pt.aux
    return function (sbj, si, caps, ci, state)
        local char, nsi = s_byte(sbj, si), si + 1
        for i = 1, #ranges do
            local r = ranges[i]
            if char and r[char]
            then return true, nsi, ci end
        end
        return false, si, ci
    end
end
compilers["set"] = function (pt)
    local s = pt.aux
    return function (sbj, si, caps, ci, state)
        local char, nsi = s_byte(sbj, si), si + 1
        if s[char]
        then return true, nsi, ci
        else return false, si, ci end
    end
end
compilers["range"] = compilers.set
compilers["ref"] = function (pt, ccache)
    local name = pt.aux
    local ref
    return function (sbj, si, caps, ci, state)
        if not ref then
            if #state.grammars == 0 then
                error(("rule 'XXXX' used outside a grammar"):gsub("XXXX", tostring(name)))
            elseif not state.grammars[#state.grammars][name] then
                error(("rule 'XXXX' undefined in given grammar"):gsub("XXXX", tostring(name)))
            end
            ref = state.grammars[#state.grammars][name]
        end
            local success, nsi, nci = ref(sbj, si, caps, ci, state)
        return success, nsi, nci
    end
end
local choice_tpl = [=[
            success, si, ci = XXXX(sbj, si, caps, ci, state)
            if success then
                return true, si, ci
            else
            end]=]
local function flatten(kind, pt, ccache)
    if pt[2].pkind == kind then
        return compile(pt[1], ccache), flatten(kind, pt[2], ccache)
    else
        return compile(pt[1], ccache), compile(pt[2], ccache)
    end
end
compilers["choice"] = function (pt, ccache)
    local choices = {flatten("choice", pt, ccache)}
    local names, chunks = {}, {}
    for i = 1, #choices do
        local m = "ch"..i
        names[#names + 1] = m
        chunks[ #names  ] = choice_tpl:gsub("XXXX", m)
    end
    names[#names + 1] = "clear_captures"
    choices[ #names ] = clear_captures
    local compiled = t_concat{
        "local ", t_concat(names, ", "), [=[ = ...
        return function (sbj, si, caps, ci, state)
            local aux, success = caps.aux, false
            ]=],
            t_concat(chunks,"\n"),[=[--
            return false, si, ci
        end]=]
    }
    return load(compiled, "Choice")(t_unpack(choices))
end
local sequence_tpl = [=[
            success, si, ci = XXXX(sbj, si, caps, ci, state)
            if not success then
                return false, ref_si, ref_ci
            end]=]
compilers["sequence"] = function (pt, ccache)
    local sequence = {flatten("sequence", pt, ccache)}
    local names, chunks = {}, {}
    for i = 1, #sequence do
        local m = "seq"..i
        names[#names + 1] = m
        chunks[ #names  ] = sequence_tpl:gsub("XXXX", m)
    end
    names[#names + 1] = "clear_captures"
    sequence[ #names ] = clear_captures
    local compiled = t_concat{
        "local ", t_concat(names, ", "), [=[ = ...
        return function (sbj, si, caps, ci, state)
            local ref_si, ref_ci, success = si, ci
            ]=],
            t_concat(chunks,"\n"),[=[
            return true, si, ci
        end]=]
    }
   return load(compiled, "Sequence")(t_unpack(sequence))
end
compilers["at most"] = function (pt, ccache)
    local matcher, n = compile(pt.pattern, ccache), pt.aux
    n = -n
    return function (sbj, si, caps, ci, state)
        local success = true
        for i = 1, n do
            success, si, ci = matcher(sbj, si, caps, ci, state)
            if not success then
                break
            end
        end
        return true, si, ci
    end
end
compilers["at least"] = function (pt, ccache)
    local matcher, n = compile(pt.pattern, ccache), pt.aux
    if n == 0 then
        return function (sbj, si, caps, ci, state)
            local last_si, last_ci
            while true do
                local success
                last_si, last_ci = si, ci
                success, si, ci = matcher(sbj, si, caps, ci, state)
                if not success then
                    si, ci = last_si, last_ci
                    break
                end
            end
            return true, si, ci
        end
    elseif n == 1 then
        return function (sbj, si, caps, ci, state)
            local last_si, last_ci
            local success = true
            success, si, ci = matcher(sbj, si, caps, ci, state)
            if not success then
                return false, si, ci
            end
            while true do
                local success
                last_si, last_ci = si, ci
                success, si, ci = matcher(sbj, si, caps, ci, state)
                if not success then
                    si, ci = last_si, last_ci
                    break
                end
            end
            return true, si, ci
        end
    else
        return function (sbj, si, caps, ci, state)
            local last_si, last_ci
            local success = true
            for _ = 1, n do
                success, si, ci = matcher(sbj, si, caps, ci, state)
                if not success then
                    return false, si, ci
                end
            end
            while true do
                local success
                last_si, last_ci = si, ci
                success, si, ci = matcher(sbj, si, caps, ci, state)
                if not success then
                    si, ci = last_si, last_ci
                    break
                end
            end
            return true, si, ci
        end
    end
end
compilers["unm"] = function (pt, ccache)
    if pt.pkind == "any" and pt.aux == 1 then
        return eoscompiled
    end
    local matcher = compile(pt.pattern, ccache)
    return function (sbj, si, caps, ci, state)
        local success, _, _ = matcher(sbj, si, caps, ci, state)
        return not success, si, ci
    end
end
compilers["lookahead"] = function (pt, ccache)
    local matcher = compile(pt.pattern, ccache)
    return function (sbj, si, caps, ci, state)
        local success, _, _ = matcher(sbj, si, caps, ci, state)
        return success, si, ci
    end
end
end

end
end
--=============================================================================
do local _ENV = _ENV
packages['constructors'] = function (...)

local getmetatable, ipairs, newproxy, print, setmetatable
    = getmetatable, ipairs, newproxy, print, setmetatable
local t, u, compat
    = require"table", require"util", require"compat"
local t_concat = t.concat
local   copy,   getuniqueid,   id,   map
    ,   weakkey,   weakval
    = u.copy, u.getuniqueid, u.id, u.map
    , u.weakkey, u.weakval
local _ENV = u.noglobals() ----------------------------------------------------
local patternwith = {
    constant = {
        "Cp", "true", "false"
    },
    aux = {
        "string", "any",
        "char", "range", "set",
        "ref", "sequence", "choice",
        "Carg", "Cb"
    },
    subpt = {
        "unm", "lookahead", "C", "Cf",
        "Cg", "Cs", "Ct", "/zero"
    },
    both = {
        "behind", "at least", "at most", "Clb", "Cmt",
        "div_string", "div_number", "div_table", "div_function"
    },
    none = "grammar", "Cc"
}
return function(Builder, LL) --- module wrapper.
local S_tostring = Builder.set.tostring
local newpattern, pattmt
local next_pattern_id = 1
if compat.proxies and not compat.lua52_len then
    local proxycache = weakkey{}
    local __index_LL = {__index = LL}
    local baseproxy = newproxy(true)
    pattmt = getmetatable(baseproxy)
    Builder.proxymt = pattmt
    function pattmt:__index(k)
        return proxycache[self][k]
    end
    function pattmt:__newindex(k, v)
        proxycache[self][k] = v
    end
    function LL.getdirect(p) return proxycache[p] end
    function newpattern(cons)
        local pt = newproxy(baseproxy)
        setmetatable(cons, __index_LL)
        proxycache[pt]=cons
        pt.id = "__ptid" .. next_pattern_id
        next_pattern_id = next_pattern_id + 1
        return pt
    end
else
    if LL.warnings and not compat.lua52_len then
        print("Warning: The `__len` metamethod won't work with patterns, "
            .."use `LL.L(pattern)` for lookaheads.")
    end
    pattmt = LL
    function LL.getdirect (p) return p end
    function newpattern(pt)
        pt.id = "__ptid" .. next_pattern_id
        next_pattern_id = next_pattern_id + 1
        return setmetatable(pt,LL)
    end
end
Builder.newpattern = newpattern
local
function LL_ispattern(pt) return getmetatable(pt) == pattmt end
LL.ispattern = LL_ispattern
function LL.type(pt)
    if LL_ispattern(pt) then
        return "pattern"
    else
        return nil
    end
end
local ptcache, meta
local
function resetcache()
    ptcache, meta = {}, weakkey{}
    Builder.ptcache = ptcache
    for _, p in ipairs(patternwith.aux) do
        ptcache[p] = weakval{}
    end
    for _, p in ipairs(patternwith.subpt) do
        ptcache[p] = weakval{}
    end
    for _, p in ipairs(patternwith.both) do
        ptcache[p] = {}
    end
    return ptcache
end
LL.resetptcache = resetcache
resetcache()
local constructors = {}
Builder.constructors = constructors
constructors["constant"] = {
    truept  = newpattern{ pkind = "true" },
    falsept = newpattern{ pkind = "false" },
    Cppt    = newpattern{ pkind = "Cp" }
}
local getauxkey = {
    string = function(aux, as_is) return as_is end,
    table = copy,
    set = function(aux, as_is)
        return S_tostring(aux)
    end,
    range = function(aux, as_is)
        return t_concat(as_is, "|")
    end,
    sequence = function(aux, as_is)
        return t_concat(map(getuniqueid, aux),"|")
    end
}
getauxkey.choice = getauxkey.sequence
constructors["aux"] = function(typ, aux, as_is)
    local cache = ptcache[typ]
    local key = (getauxkey[typ] or id)(aux, as_is)
    local res_pt = cache[key]
    if not res_pt then
        res_pt = newpattern{
            pkind = typ,
            aux = aux,
            as_is = as_is
        }
        cache[key] = res_pt
    end
    return res_pt
end
constructors["none"] = function(typ, aux)
    return newpattern{
        pkind = typ,
        aux = aux
    }
end
constructors["subpt"] = function(typ, pt)
    local cache = ptcache[typ]
    local res_pt = cache[pt.id]
    if not res_pt then
        res_pt = newpattern{
            pkind = typ,
            pattern = pt
        }
        cache[pt.id] = res_pt
    end
    return res_pt
end
constructors["both"] = function(typ, pt, aux)
    local cache = ptcache[typ][aux]
    if not cache then
        ptcache[typ][aux] = weakval{}
        cache = ptcache[typ][aux]
    end
    local res_pt = cache[pt.id]
    if not res_pt then
        res_pt = newpattern{
            pkind = typ,
            pattern = pt,
            aux = aux,
            cache = cache -- needed to keep the cache as long as the pattern exists.
        }
        cache[pt.id] = res_pt
    end
    return res_pt
end
constructors["binary"] = function(typ, a, b)
    return newpattern{
        a, b;
        pkind = typ,
    }
end
end -- module wrapper

end
end
--=============================================================================
do local _ENV = _ENV
packages['datastructures'] = function (...)
local getmetatable, pairs, setmetatable, type
    = getmetatable, pairs, setmetatable, type
local m, t , u = require"math", require"table", require"util"
local compat = require"compat"
local ffi if compat.luajit then
    ffi = require"ffi"
end
local _ENV = u.noglobals() ----------------------------------------------------
local   extend,   load, u_max
    = u.extend, u.load, u.max
local m_max, t_concat, t_insert, t_sort
    = m.max, t.concat, t.insert, t.sort
local structfor = {}
local byteset_new, isboolset, isbyteset
local byteset_mt = {}
local
function byteset_constructor (upper)
    local set = setmetatable(load(t_concat{
        "return{ [0]=false",
        (", false"):rep(upper),
        " }"
    })(),
    byteset_mt)
    return set
end
if compat.jit then
    local struct, boolset_constructor = {v={}}
    function byteset_mt.__index(s,i)
        if i == nil or i > s.upper then return nil end
        return s.v[i]
    end
    function byteset_mt.__len(s)
        return s.upper
    end
    function byteset_mt.__newindex(s,i,v)
        s.v[i] = v
    end
    boolset_constructor = ffi.metatype('struct { int upper; bool v[?]; }', byteset_mt)
    function byteset_new (t)
        if type(t) == "number" then
            local res = boolset_constructor(t+1)
            res.upper = t
            return res
        end
        local upper = u_max(t)
        struct.upper = upper
        if upper > 255 then error"bool_set overflow" end
        local set = boolset_constructor(upper+1)
        set.upper = upper
        for i = 1, #t do set[t[i]] = true end
        return set
    end
    function isboolset(s) return type(s)=="cdata" and ffi.istype(s, boolset_constructor) end
    isbyteset = isboolset
else
    function byteset_new (t)
        if type(t) == "number" then return byteset_constructor(t) end
        local set = byteset_constructor(u_max(t))
        for i = 1, #t do set[t[i]] = true end
        return set
    end
    function isboolset(s) return false end
    function isbyteset (s)
        return getmetatable(s) == byteset_mt
    end
end
local
function byterange_new (low, high)
    high = ( low <= high ) and high or -1
    local set = byteset_new(high)
    for i = low, high do
        set[i] = true
    end
    return set
end
local tmpa, tmpb ={}, {}
local
function set_if_not_yet (s, dest)
    if type(s) == "number" then
        dest[s] = true
        return dest
    else
        return s
    end
end
local
function clean_ab (a,b)
    tmpa[a] = nil
    tmpb[b] = nil
end
local
function byteset_union (a ,b)
    local upper = m_max(
        type(a) == "number" and a or #a,
        type(b) == "number" and b or #b
    )
    local A, B
        = set_if_not_yet(a, tmpa)
        , set_if_not_yet(b, tmpb)
    local res = byteset_new(upper)
    for i = 0, upper do
        res[i] = A[i] or B[i] or false
    end
    clean_ab(a,b)
    return res
end
local
function byteset_difference (a, b)
    local res = {}
    for i = 0, 255 do
        res[i] = a[i] and not b[i]
    end
    return res
end
local
function byteset_tostring (s)
    local list = {}
    for i = 0, 255 do
        list[#list+1] = (s[i] == true) and i or nil
    end
    return t_concat(list,", ")
end
structfor.binary = {
    set ={
        new = byteset_new,
        union = byteset_union,
        difference = byteset_difference,
        tostring = byteset_tostring
    },
    Range = byterange_new,
    isboolset = isboolset,
    isbyteset = isbyteset,
    isset = isbyteset
}
local set_mt = {}
local
function set_new (t)
    local set = setmetatable({}, set_mt)
    for i = 1, #t do set[t[i]] = true end
    return set
end
local -- helper for the union code.
function add_elements(a, res)
    for k in pairs(a) do res[k] = true end
    return res
end
local
function set_union (a, b)
    a, b = (type(a) == "number") and set_new{a} or a
         , (type(b) == "number") and set_new{b} or b
    local res = set_new{}
    add_elements(a, res)
    add_elements(b, res)
    return res
end
local
function set_difference(a, b)
    local list = {}
    a, b = (type(a) == "number") and set_new{a} or a
         , (type(b) == "number") and set_new{b} or b
    for el in pairs(a) do
        if a[el] and not b[el] then
            list[#list+1] = el
        end
    end
    return set_new(list)
end
local
function set_tostring (s)
    local list = {}
    for el in pairs(s) do
        t_insert(list,el)
    end
    t_sort(list)
    return t_concat(list, ",")
end
local
function isset (s)
    return (getmetatable(s) == set_mt)
end
local
function range_new (start, finish)
    local list = {}
    for i = start, finish do
        list[#list + 1] = i
    end
    return set_new(list)
end
structfor.other = {
    set = {
        new = set_new,
        union = set_union,
        tostring = set_tostring,
        difference = set_difference,
    },
    Range = range_new,
    isboolset = isboolset,
    isbyteset = isbyteset,
    isset = isset,
    isrange = function(a) return false end
}
return function(Builder, LL)
    local cs = (Builder.options or {}).charset or "binary"
    if type(cs) == "string" then
        cs = (cs == "binary") and "binary" or "other"
    else
        cs = cs.binary and "binary" or "other"
    end
    return extend(Builder, structfor[cs])
end

end
end
--=============================================================================
do local _ENV = _ENV
packages['evaluator'] = function (...)

local select, tonumber, tostring, type
    = select, tonumber, tostring, type
local s, t, u = require"string", require"table", require"util"
local s_sub, t_concat
    = s.sub, t.concat
local t_unpack
    = u.unpack
local _ENV = u.noglobals() ----------------------------------------------------
return function(Builder, LL) -- Decorator wrapper
local eval = {}
local
function insert (caps, sbj, vals, ci, vi)
    local openclose, kind = caps.openclose, caps.kind
    while kind[ci] and openclose[ci] >= 0 do
        ci, vi = eval[kind[ci]](caps, sbj, vals, ci, vi)
    end
    return ci, vi
end
function eval.C (caps, sbj, vals, ci, vi)
    if caps.openclose[ci] > 0 then
        vals[vi] = s_sub(sbj, caps.bounds[ci], caps.openclose[ci] - 1)
        return ci + 1, vi + 1
    end
    vals[vi] = false -- pad it for now
    local cj, vj = insert(caps, sbj, vals, ci + 1, vi + 1)
    vals[vi] = s_sub(sbj, caps.bounds[ci], caps.bounds[cj] - 1)
    return cj + 1, vj
end
local
function lookback (caps, label, ci)
    local aux, openclose, kind= caps.aux, caps.openclose, caps.kind
    repeat
        ci = ci - 1
        local auxv, oc = aux[ci], openclose[ci]
        if oc < 0 then ci = ci + oc end
        if oc ~= 0 and kind[ci] == "Clb" and label == auxv then
            return ci
        end
    until ci == 1
    label = type(label) == "string" and "'"..label.."'" or tostring(label)
    error("back reference "..label.." not found")
end
function eval.Cb (caps, sbj, vals, ci, vi)
    local Cb_ci = lookback(caps, caps.aux[ci], ci)
    Cb_ci, vi = eval.Cg(caps, sbj, vals, Cb_ci, vi)
    return ci + 1, vi
end
function eval.Cc (caps, sbj, vals, ci, vi)
    local these_values = caps.aux[ci]
    for i = 1, these_values.n do
        vi, vals[vi] = vi + 1, these_values[i]
    end
    return ci + 1, vi
end
eval["Cf"] = function() error("NYI: Cf") end
function eval.Cf (caps, sbj, vals, ci, vi)
    if caps.openclose[ci] > 0 then
        error"No First Value"
    end
    local func, Cf_vals, Cf_vi = caps.aux[ci], {}
    ci = ci + 1
    ci, Cf_vi = eval[caps.kind[ci]](caps, sbj, Cf_vals, ci, 1)
    if Cf_vi == 1 then
        error"No first value"
    end
    local result = Cf_vals[1]
    while caps.kind[ci] and caps.openclose[ci] >= 0 do
        ci, Cf_vi = eval[caps.kind[ci]](caps, sbj, Cf_vals, ci, 1)
        result = func(result, t_unpack(Cf_vals, 1, Cf_vi - 1))
    end
    vals[vi] = result
    return ci +1, vi + 1
end
function eval.Cg (caps, sbj, vals, ci, vi)
    if caps.openclose[ci] > 0 then
        vals[vi] = s_sub(sbj, caps.bounds[ci], caps.openclose[ci] - 1)
        return ci + 1, vi + 1
    end
    local cj, vj = insert(caps, sbj, vals, ci + 1, vi)
    if vj == vi then
        vals[vj] = s_sub(sbj, caps.bounds[ci], caps.bounds[cj] - 1)
        vj = vj + 1
    end
    return cj + 1, vj
end
function eval.Clb (caps, sbj, vals, ci, vi)
    local oc = caps.openclose
    if oc[ci] > 0 then
        return ci + 1, vi
    end
    local depth = 0
    repeat
        if oc[ci] == 0 then depth = depth + 1
        elseif oc[ci] < 0 then depth = depth - 1
        end
        ci = ci + 1
    until depth == 0
    return ci, vi
end
function eval.Cp (caps, sbj, vals, ci, vi)
    vals[vi] = caps.bounds[ci]
    return ci + 1, vi + 1
end
function eval.Ct (caps, sbj, vals, ci, vi)
    local aux, openclose, kind = caps. aux, caps.openclose, caps.kind
    local tbl_vals = {}
    vals[vi] = tbl_vals
    if openclose[ci] > 0 then
        return ci + 1, vi + 1
    end
    local tbl_vi, Clb_vals = 1, {}
    ci = ci + 1
    while kind[ci] and openclose[ci] >= 0 do
        if kind[ci] == "Clb" then
            local label, Clb_vi = aux[ci], 1
            ci, Clb_vi = eval.Cg(caps, sbj, Clb_vals, ci, 1)
            if Clb_vi ~= 1 then tbl_vals[label] = Clb_vals[1] end
        else
            ci, tbl_vi =  eval[kind[ci]](caps, sbj, tbl_vals, ci, tbl_vi)
        end
    end
    return ci + 1, vi + 1
end
local inf = 1/0
function eval.value (caps, sbj, vals, ci, vi)
    local val
    if caps.aux[ci] ~= inf or caps.openclose[ci] ~= inf
        then val = caps.aux[ci]
    end
    vals[vi] = val
    return ci + 1, vi + 1
end
function eval.Cs (caps, sbj, vals, ci, vi)
    if caps.openclose[ci] > 0 then
        vals[vi] = s_sub(sbj, caps.bounds[ci], caps.openclose[ci] - 1)
    else
        local bounds, kind, openclose = caps.bounds, caps.kind, caps.openclose
        local start, buffer, Cs_vals, bi, Cs_vi = bounds[ci], {}, {}, 1, 1
        local last
        ci = ci + 1
        while openclose[ci] >= 0 do
            last = bounds[ci]
            buffer[bi] = s_sub(sbj, start, last - 1)
            bi = bi + 1
            ci, Cs_vi = eval[kind[ci]](caps, sbj, Cs_vals, ci, 1)
            if Cs_vi > 1 then
                buffer[bi] = Cs_vals[1]
                bi = bi + 1
                start = openclose[ci-1] > 0 and openclose[ci-1] or bounds[ci-1]
            else
                start = last
            end
        end
        buffer[bi] = s_sub(sbj, start, bounds[ci] - 1)
        vals[vi] = t_concat(buffer)
    end
    return ci + 1, vi + 1
end
local
function insert_divfunc_results(acc, val_i, ...)
    local n = select('#', ...)
    for i = 1, n do
        val_i, acc[val_i] = val_i + 1, select(i, ...)
    end
    return val_i
end
function eval.div_function (caps, sbj, vals, ci, vi)
    local func = caps.aux[ci]
    local params, divF_vi
    if caps.openclose[ci] > 0 then
        params, divF_vi = {s_sub(sbj, caps.bounds[ci], caps.openclose[ci] - 1)}, 2
    else
        params = {}
        ci, divF_vi = insert(caps, sbj, params, ci + 1, 1)
    end
    ci = ci + 1 -- skip the closed or closing node.
    vi = insert_divfunc_results(vals, vi, func(t_unpack(params, 1, divF_vi - 1)))
    return ci, vi
end
function eval.div_number (caps, sbj, vals, ci, vi)
    local this_aux = caps.aux[ci]
    local divN_vals, divN_vi
    if caps.openclose[ci] > 0 then
        divN_vals, divN_vi = {s_sub(sbj, caps.bounds[ci], caps.openclose[ci] - 1)}, 2
    else
        divN_vals = {}
        ci, divN_vi = insert(caps, sbj, divN_vals, ci + 1, 1)
    end
    ci = ci + 1 -- skip the closed or closing node.
    if this_aux >= divN_vi then error("no capture '"..this_aux.."' in /number capture.") end
    vals[vi] = divN_vals[this_aux]
    return ci, vi + 1
end
local function div_str_cap_refs (caps, ci)
    local opcl = caps.openclose
    local refs = {open=caps.bounds[ci]}
    if opcl[ci] > 0 then
        refs.close = opcl[ci]
        return ci + 1, refs, 0
    end
    local first_ci = ci
    local depth = 1
    ci = ci + 1
    repeat
        local oc = opcl[ci]
        if depth == 1  and oc >= 0 then refs[#refs+1] = ci end
        if oc == 0 then
            depth = depth + 1
        elseif oc < 0 then
            depth = depth - 1
        end
        ci = ci + 1
    until depth == 0
    refs.close = caps.bounds[ci - 1]
    return ci, refs, #refs
end
function eval.div_string (caps, sbj, vals, ci, vi)
    local n, refs
    local cached
    local cached, divS_vals = {}, {}
    local the_string = caps.aux[ci]
    ci, refs, n = div_str_cap_refs(caps, ci)
    vals[vi] = the_string:gsub("%%([%d%%])", function (d)
        if d == "%" then return "%" end
        d = tonumber(d)
        if not cached[d] then
            if d > n then
                error("no capture at index "..d.." in /string capture.")
            end
            if d == 0 then
                cached[d] = s_sub(sbj, refs.open, refs.close - 1)
            else
                local _, vi = eval[caps.kind[refs[d]]](caps, sbj, divS_vals, refs[d], 1)
                if vi == 1 then error("no values in capture at index"..d.." in /string capture.") end
                cached[d] = divS_vals[1]
            end
        end
        return cached[d]
    end)
    return ci, vi + 1
end
function eval.div_table (caps, sbj, vals, ci, vi)
    local this_aux = caps.aux[ci]
    local key
    if caps.openclose[ci] > 0 then
        key =  s_sub(sbj, caps.bounds[ci], caps.openclose[ci] - 1)
    else
        local divT_vals, _ = {}
        ci, _ = insert(caps, sbj, divT_vals, ci + 1, 1)
        key = divT_vals[1]
    end
    ci = ci + 1
    if this_aux[key] then
        vals[vi] = this_aux[key]
        return ci, vi + 1
    else
        return ci, vi
    end
end
function LL.evaluate (caps, sbj, ci)
    local vals = {}
    local _,  vi = insert(caps, sbj, vals, ci, 1)
    return vals, 1, vi - 1
end
end  -- Decorator wrapper

end
end
--=============================================================================
do local _ENV = _ENV
packages['factorizer'] = function (...)
local ipairs, pairs, print, setmetatable
    = ipairs, pairs, print, setmetatable
local u = require"util"
local   id,   nop,   setify,   weakkey
    = u.id, u.nop, u.setify, u.weakkey
local _ENV = u.noglobals() ----------------------------------------------------
local
function process_booleans(a, b, opts)
    local id, brk = opts.id, opts.brk
    if a == id then return true, b
    elseif b == id then return true, a
    elseif a == brk then return true, brk
    else return false end
end
local unary = setify{
    "unm", "lookahead", "C", "Cf",
    "Cg", "Cs", "Ct", "/zero"
}
local unary_aux = setify{
    "behind", "at least", "at most", "Clb", "Cmt",
    "div_string", "div_number", "div_table", "div_function"
}
local unifiable = setify{"char", "set", "range"}
local hasCmt; hasCmt = setmetatable({}, {__mode = "k", __index = function(self, pt)
    local kind, res = pt.pkind, false
    if kind == "Cmt"
    or kind == "ref"
    then
        res = true
    elseif unary[kind] or unary_aux[kind] then
        res = hasCmt[pt.pattern]
    elseif kind == "choice" or kind == "sequence" then
        res = hasCmt[pt[1]] or hasCmt[pt[2]]
    end
    hasCmt[pt] = res
    return res
end})
return function (Builder, LL) --------------------------------------------------
if Builder.options.factorize == false then
    return {
        choice = nop,
        sequence = nop,
        lookahead = nop,
        unm = nop
    }
end
local constructors, LL_P =  Builder.constructors, LL.P
local truept, falsept
    = constructors.constant.truept
    , constructors.constant.falsept
local --Range, Set,
    S_union
    = --Builder.Range, Builder.set.new,
    Builder.set.union
local mergeable = setify{"char", "set"}
local type2cons = {
    ["/zero"] = "__div",
    ["div_number"] = "__div",
    ["div_string"] = "__div",
    ["div_table"] = "__div",
    ["div_function"] = "__div",
    ["at least"] = "__pow",
    ["at most"] = "__pow",
    ["Clb"] = "Cg",
}
local
function choice (a, b)
    do  -- handle the identity/break properties of true and false.
        local hasbool, res = process_booleans(a, b, { id = falsept, brk = truept })
        if hasbool then return res end
    end
    local ka, kb = a.pkind, b.pkind
    if a == b and not hasCmt[a] then
        return a
    elseif ka == "choice" then -- correct associativity without blowing up the stack
        local acc, i = {}, 1
        while a.pkind == "choice" do
            acc[i], a, i = a[1], a[2], i + 1
        end
        acc[i] = a
        for j = i, 1, -1 do
            b = acc[j] + b
        end
        return b
    elseif mergeable[ka] and mergeable[kb] then
        return constructors.aux("set", S_union(a.aux, b.aux))
    elseif mergeable[ka] and kb == "any" and b.aux == 1
    or     mergeable[kb] and ka == "any" and a.aux == 1 then
        return ka == "any" and a or b
    elseif ka == kb then
        if (unary[ka] or unary_aux[ka]) and ( a.aux == b.aux ) then
            return LL[type2cons[ka] or ka](a.pattern + b.pattern, a.aux)
        elseif ( ka == kb ) and ka == "sequence" then
            if a[1] == b[1]  and not hasCmt[a[1]] then
                return a[1] * (a[2] + b[2])
            end
        end
    end
    return false
end
local
function lookahead (pt)
    return pt
end
local
function sequence(a, b)
    do
        local hasbool, res = process_booleans(a, b, { id = truept, brk = falsept })
        if hasbool then return res end
    end
    local ka, kb = a.pkind, b.pkind
    if ka == "sequence" then -- correct associativity without blowing up the stack
        local acc, i = {}, 1
        while a.pkind == "sequence" do
            acc[i], a, i = a[1], a[2], i + 1
        end
        acc[i] = a
        for j = i, 1, -1 do
            b = acc[j] * b
        end
        return b
    elseif (ka == "one" or ka == "any") and (kb == "one" or kb == "any") then
        return LL_P(a.aux + b.aux)
    end
    return false
end
local
function unm (pt)
    if     pt == truept            then return falsept
    elseif pt == falsept           then return truept
    elseif pt.pkind == "unm"       then return #pt.pattern
    elseif pt.pkind == "lookahead" then return -pt.pattern
    end
end
return {
    choice = choice,
    lookahead = lookahead,
    sequence = sequence,
    unm = unm
}
end

end
end
--=============================================================================
do local _ENV = _ENV
packages['init'] = function (...)

local getmetatable, setmetatable, pcall
    = getmetatable, setmetatable, pcall
local u = require"util"
local   copy,   map,   nop, t_unpack
    = u.copy, u.map, u.nop, u.unpack
local API, charsets, compiler, constructors
    , datastructures, evaluator, factorizer
    , locale, printers, re
    = t_unpack(map(require,
    { "API", "charsets", "compiler", "constructors"
    , "datastructures", "evaluator", "factorizer"
    , "locale", "printers", "re" }))
local _, package = pcall(require, "package")
local _ENV = u.noglobals() ----------------------------------------------------
local VERSION = "0.12"
local LuVERSION = "0.1.0"
local function global(self, env) setmetatable(env,{__index = self}) end
local function register(self, env)
    pcall(function()
        package.loaded.lpeg = self
        package.loaded.re = self.re
    end)
    if env then
        env.lpeg, env.re = self, self.re
    end
    return self
end
local
function LuLPeg(options)
    options = options and copy(options) or {}
    local Builder, LL
        = { options = options, factorizer = factorizer }
        , { new = LuLPeg
          , version = function () return VERSION end
          , luversion = function () return LuVERSION end
          , setmaxstack = nop --Just a stub, for compatibility.
          }
    LL.util = u
    LL.global = global
    LL.register = register
    ;-- Decorate the LuLPeg object.
    charsets(Builder, LL)
    datastructures(Builder, LL)
    printers(Builder, LL)
    constructors(Builder, LL)
    API(Builder, LL)
    evaluator(Builder, LL)
    ;(options.compiler or compiler)(Builder, LL)
    locale(Builder, LL)
    LL.re = re(Builder, LL)
    return LL
end -- LuLPeg
local LL = LuLPeg()
return LL

end
end
--=============================================================================
do local _ENV = _ENV
packages['locale'] = function (...)

local extend = require"util".extend
local _ENV = require"util".noglobals() ----------------------------------------
return function(Builder, LL) -- Module wrapper {-------------------------------
local R, S = LL.R, LL.S
local locale = {}
locale["cntrl"] = R"\0\31" + "\127"
locale["digit"] = R"09"
locale["lower"] = R"az"
locale["print"] = R" ~" -- 0x20 to 0xee
locale["space"] = S" \f\n\r\t\v" -- \f == form feed (for a printer), \v == vtab
locale["upper"] = R"AZ"
locale["alpha"]  = locale["lower"] + locale["upper"]
locale["alnum"]  = locale["alpha"] + locale["digit"]
locale["graph"]  = locale["print"] - locale["space"]
locale["punct"]  = locale["graph"] - locale["alnum"]
locale["xdigit"] = locale["digit"] + R"af" + R"AF"
function LL.locale (t)
    return extend(t or {}, locale)
end
end -- Module wrapper --------------------------------------------------------}

end
end
--=============================================================================
do local _ENV = _ENV
packages['match'] = function (...)

end
end
--=============================================================================
do local _ENV = _ENV
packages['optimizer'] = function (...)
-- Nothing for now.
end
end
--=============================================================================
do local _ENV = _ENV
packages['printers'] = function (...)
return function(Builder, LL)
local ipairs, pairs, print, tostring, type
    = ipairs, pairs, print, tostring, type
local s, t, u = require"string", require"table", require"util"
local S_tostring = Builder.set.tostring
local _ENV = u.noglobals() ----------------------------------------------------
local s_char, s_sub, t_concat
    = s.char, s.sub, t.concat
local   expose,   load,   map
    = u.expose, u.load, u.map
local escape_index = {
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
    ["\v"] = "\\v",
    ["\127"] = "\\ESC"
}
local function flatten(kind, list)
    if list[2].pkind == kind then
        return list[1], flatten(kind, list[2])
    else
        return list[1], list[2]
    end
end
for i = 0, 8 do escape_index[s_char(i)] = "\\"..i end
for i = 14, 31 do escape_index[s_char(i)] = "\\"..i end
local
function escape( str )
    return str:gsub("%c", escape_index)
end
local
function set_repr (set)
    return s_char(load("return "..S_tostring(set))())
end
local printers = {}
local
function LL_pprint (pt, offset, prefix)
    return printers[pt.pkind](pt, offset, prefix)
end
function LL.pprint (pt0)
    local pt = LL.P(pt0)
    print"\nPrint pattern"
    LL_pprint(pt, "", "")
    print"--- /pprint\n"
    return pt0
end
for k, v in pairs{
    string       = [[ "P( \""..escape(pt.as_is).."\" )"       ]],
    char         = [[ "P( \""..escape(to_char(pt.aux)).."\" )"]],
    ["true"]     = [[ "P( true )"                     ]],
    ["false"]    = [[ "P( false )"                    ]],
    eos          = [[ "~EOS~"                         ]],
    one          = [[ "P( one )"                      ]],
    any          = [[ "P( "..pt.aux.." )"             ]],
    set          = [[ "S( "..'"'..escape(set_repr(pt.aux))..'"'.." )" ]],
    ["function"] = [[ "P( "..pt.aux.." )"             ]],
    ref = [[
        "V( ",
            (type(pt.aux) == "string" and "\""..pt.aux.."\"")
                          or tostring(pt.aux)
        , " )"
        ]],
    range = [[
        "R( ",
            escape(t_concat(map(
                pt.as_is,
                function(e) return '"'..e..'"' end)
            , ", "))
        ," )"
        ]]
} do
    printers[k] = load(([==[
        local k, map, t_concat, to_char, escape, set_repr = ...
        return function (pt, offset, prefix)
            print(t_concat{offset,prefix,XXXX})
        end
    ]==]):gsub("XXXX", v), k.." printer")(k, map, t_concat, s_char, escape, set_repr)
end
for k, v in pairs{
    ["behind"] = [[ LL_pprint(pt.pattern, offset, "B ") ]],
    ["at least"] = [[ LL_pprint(pt.pattern, offset, pt.aux.." ^ ") ]],
    ["at most"] = [[ LL_pprint(pt.pattern, offset, pt.aux.." ^ ") ]],
    unm        = [[LL_pprint(pt.pattern, offset, "- ")]],
    lookahead  = [[LL_pprint(pt.pattern, offset, "# ")]],
    choice = [[
        print(offset..prefix.."+")
        local ch, i = {}, 1
        while pt.pkind == "choice" do
            ch[i], pt, i = pt[1], pt[2], i + 1
        end
        ch[i] = pt
        map(ch, LL_pprint, offset.." :", "")
        ]],
    sequence = [=[
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
        ]=],
    grammar   = [[
        print(offset..prefix.."Grammar")
        for k, pt in pairs(pt.aux) do
            local prefix = ( type(k)~="string"
                             and tostring(k)
                             or "\""..k.."\"" )
            LL_pprint(pt, offset.."  ", prefix .. " = ")
        end
    ]]
} do
    printers[k] = load(([[
        local map, LL_pprint, pkind, s, u, flatten = ...
        return function (pt, offset, prefix)
            XXXX
        end
    ]]):gsub("XXXX", v), k.." printer")(map, LL_pprint, type, s, u, flatten)
end
for _, cap in pairs{"C", "Cs", "Ct"} do
    printers[cap] = function (pt, offset, prefix)
        print(offset..prefix..cap)
        LL_pprint(pt.pattern, offset.."  ", "")
    end
end
for _, cap in pairs{"Cg", "Clb", "Cf", "Cmt", "div_number", "/zero", "div_function", "div_table"} do
    printers[cap] = function (pt, offset, prefix)
        print(offset..prefix..cap.." "..tostring(pt.aux or ""))
        LL_pprint(pt.pattern, offset.."  ", "")
    end
end
printers["div_string"] = function (pt, offset, prefix)
    print(offset..prefix..'/string "'..tostring(pt.aux or "")..'"')
    LL_pprint(pt.pattern, offset.."  ", "")
end
for _, cap in pairs{"Carg", "Cp"} do
    printers[cap] = function (pt, offset, prefix)
        print(offset..prefix..cap.."( "..tostring(pt.aux).." )")
    end
end
printers["Cb"] = function (pt, offset, prefix)
    print(offset..prefix.."Cb( \""..pt.aux.."\" )")
end
printers["Cc"] = function (pt, offset, prefix)
    print(offset..prefix.."Cc(" ..t_concat(map(pt.aux, tostring),", ").." )")
end
local cprinters = {}
local padding = "   "
local function padnum(n)
    n = tostring(n)
    n = n .."."..((" "):rep(4 - #n))
    return n
end
local function _cprint(caps, ci, indent, sbj, n)
    local openclose, kind = caps.openclose, caps.kind
    indent = indent or 0
    while kind[ci] and openclose[ci] >= 0 do
        if caps.openclose[ci] > 0 then
            print(t_concat({
                            padnum(n),
                            padding:rep(indent),
                            caps.kind[ci],
                            ": start = ", tostring(caps.bounds[ci]),
                            " finish = ", tostring(caps.openclose[ci]),
                            caps.aux[ci] and " aux = " or "",
                            caps.aux[ci] and (
                                type(caps.aux[ci]) == "string"
                                    and '"'..tostring(caps.aux[ci])..'"'
                                or tostring(caps.aux[ci])
                            ) or "",
                            " \t", s_sub(sbj, caps.bounds[ci], caps.openclose[ci] - 1)
                        }))
            if type(caps.aux[ci]) == "table" then expose(caps.aux[ci]) end
        else
            local kind = caps.kind[ci]
            local start = caps.bounds[ci]
            print(t_concat({
                            padnum(n),
                            padding:rep(indent), kind,
                            ": start = ", start,
                            caps.aux[ci] and " aux = " or "",
                            caps.aux[ci] and (
                                type(caps.aux[ci]) == "string"
                                    and '"'..tostring(caps.aux[ci])..'"'
                                or tostring(caps.aux[ci])
                            ) or ""
                        }))
            ci, n = _cprint(caps, ci + 1, indent + 1, sbj, n + 1)
            print(t_concat({
                            padnum(n),
                            padding:rep(indent),
                            "/", kind,
                            " finish = ", tostring(caps.bounds[ci]),
                            " \t", s_sub(sbj, start, (caps.bounds[ci] or 1) - 1)
                        }))
        end
        n = n + 1
        ci = ci + 1
    end
    return ci, n
end
function LL.cprint (caps, ci, sbj)
    ci = ci or 1
    print"\nCapture Printer:\n================"
    _cprint(caps, ci, 0, sbj, 1)
    print"================\n/Cprinter\n"
end
return { pprint = LL.pprint,cprint = LL.cprint }
end -- module wrapper ---------------------------------------------------------

end
end
--=============================================================================
do local _ENV = _ENV
packages['re'] = function (...)

return function(Builder, LL)
local tonumber, type, print, error = tonumber, type, print, error
local setmetatable = setmetatable
local m = LL
local mm = m
local mt = getmetatable(mm.P(0))
local version = _VERSION
if version == "Lua 5.2" then _ENV = nil end
local any = m.P(1)
local Predef = { nl = m.P"\n" }
local mem
local fmem
local gmem
local function updatelocale ()
  mm.locale(Predef)
  Predef.a = Predef.alpha
  Predef.c = Predef.cntrl
  Predef.d = Predef.digit
  Predef.g = Predef.graph
  Predef.l = Predef.lower
  Predef.p = Predef.punct
  Predef.s = Predef.space
  Predef.u = Predef.upper
  Predef.w = Predef.alnum
  Predef.x = Predef.xdigit
  Predef.A = any - Predef.a
  Predef.C = any - Predef.c
  Predef.D = any - Predef.d
  Predef.G = any - Predef.g
  Predef.L = any - Predef.l
  Predef.P = any - Predef.p
  Predef.S = any - Predef.s
  Predef.U = any - Predef.u
  Predef.W = any - Predef.w
  Predef.X = any - Predef.x
  mem = {}    -- restart memoization
  fmem = {}
  gmem = {}
  local mt = {__mode = "v"}
  setmetatable(mem, mt)
  setmetatable(fmem, mt)
  setmetatable(gmem, mt)
end
updatelocale()
local function getdef (id, defs)
  local c = defs and defs[id]
  if not c then error("undefined name: " .. id) end
  return c
end
local function patt_error (s, i)
  local msg = (#s < i + 20) and s:sub(i)
                             or s:sub(i,i+20) .. "..."
  msg = ("pattern error near '%s'"):format(msg)
  error(msg, 2)
end
local function mult (p, n)
  local np = mm.P(true)
  while n >= 1 do
    if n%2 >= 1 then np = np * p end
    p = p * p
    n = n/2
  end
  return np
end
local function equalcap (s, i, c)
  if type(c) ~= "string" then return nil end
  local e = #c + i
  if s:sub(i, e - 1) == c then return e else return nil end
end
local S = (Predef.space + "--" * (any - Predef.nl)^0)^0
local name = m.R("AZ", "az", "__") * m.R("AZ", "az", "__", "09")^0
local arrow = S * "<-"
local seq_follow = m.P"/" + ")" + "}" + ":}" + "~}" + "|}" + (name * arrow) + -1
name = m.C(name)
local Def = name * m.Carg(1)
local num = m.C(m.R"09"^1) * S / tonumber
local String = "'" * m.C((any - "'")^0) * "'" +
               '"' * m.C((any - '"')^0) * '"'
local defined = "%" * Def / function (c,Defs)
  local cat =  Defs and Defs[c] or Predef[c]
  if not cat then error ("name '" .. c .. "' undefined") end
  return cat
end
local Range = m.Cs(any * (m.P"-"/"") * (any - "]")) / mm.R
local item = defined + Range + m.C(any)
local Class =
    "["
  * (m.C(m.P"^"^-1))    -- optional complement symbol
  * m.Cf(item * (item - "]")^0, mt.__add) /
                          function (c, p) return c == "^" and any - p or p end
  * "]"
local function adddef (t, k, exp)
  if t[k] then
    error("'"..k.."' already defined as a rule")
  else
    t[k] = exp
  end
  return t
end
local function firstdef (n, r) return adddef({n}, n, r) end
local function NT (n, b)
  if not b then
    error("rule '"..n.."' used outside a grammar")
  else return mm.V(n)
  end
end
local exp = m.P{ "Exp",
  Exp = S * ( m.V"Grammar"
            + m.Cf(m.V"Seq" * ("/" * S * m.V"Seq")^0, mt.__add) );
  Seq = m.Cf(m.Cc(m.P"") * m.V"Prefix"^0 , mt.__mul)
        * (m.L(seq_follow) + patt_error);
  Prefix = "&" * S * m.V"Prefix" / mt.__len
         + "!" * S * m.V"Prefix" / mt.__unm
         + m.V"Suffix";
  Suffix = m.Cf(m.V"Primary" * S *
          ( ( m.P"+" * m.Cc(1, mt.__pow)
            + m.P"*" * m.Cc(0, mt.__pow)
            + m.P"?" * m.Cc(-1, mt.__pow)
            + "^" * ( m.Cg(num * m.Cc(mult))
                    + m.Cg(m.C(m.S"+-" * m.R"09"^1) * m.Cc(mt.__pow))
                    )
            + "->" * S * ( m.Cg((String + num) * m.Cc(mt.__div))
                         + m.P"{}" * m.Cc(nil, m.Ct)
                         + m.Cg(Def / getdef * m.Cc(mt.__div))
                         )
            + "=>" * S * m.Cg(Def / getdef * m.Cc(m.Cmt))
            ) * S
          )^0, function (a,b,f) return f(a,b) end );
  Primary = "(" * m.V"Exp" * ")"
            + String / mm.P
            + Class
            + defined
            + "{:" * (name * ":" + m.Cc(nil)) * m.V"Exp" * ":}" /
                     function (n, p) return mm.Cg(p, n) end
            + "=" * name / function (n) return mm.Cmt(mm.Cb(n), equalcap) end
            + m.P"{}" / mm.Cp
            + "{~" * m.V"Exp" * "~}" / mm.Cs
            + "{|" * m.V"Exp" * "|}" / mm.Ct
            + "{" * m.V"Exp" * "}" / mm.C
            + m.P"." * m.Cc(any)
            + (name * -arrow + "<" * name * ">") * m.Cb("G") / NT;
  Definition = name * arrow * m.V"Exp";
  Grammar = m.Cg(m.Cc(true), "G") *
            m.Cf(m.V"Definition" / firstdef * m.Cg(m.V"Definition")^0,
              adddef) / mm.P
}
local pattern = S * m.Cg(m.Cc(false), "G") * exp / mm.P * (-any + patt_error)
local function compile (p, defs)
  if mm.type(p) == "pattern" then return p end   -- already compiled
  local cp = pattern:match(p, 1, defs)
  if not cp then error("incorrect pattern", 3) end
  return cp
end
local function match (s, p, i)
  local cp = mem[p]
  if not cp then
    cp = compile(p)
    mem[p] = cp
  end
  return cp:match(s, i or 1)
end
local function find (s, p, i)
  local cp = fmem[p]
  if not cp then
    cp = compile(p) / 0
    cp = mm.P{ mm.Cp() * cp * mm.Cp() + 1 * mm.V(1) }
    fmem[p] = cp
  end
  local i, e = cp:match(s, i or 1)
  if i then return i, e - 1
  else return i
  end
end
local function gsub (s, p, rep)
  local g = gmem[p] or {}   -- ensure gmem[p] is not collected while here
  gmem[p] = g
  local cp = g[rep]
  if not cp then
    cp = compile(p)
    cp = mm.Cs((cp / rep + 1)^0)
    g[rep] = cp
  end
  return cp:match(s)
end
local re = {
  compile = compile,
  match = match,
  find = find,
  gsub = gsub,
  updatelocale = updatelocale,
}
return re
end
end
end
--=============================================================================
do local _ENV = _ENV
packages['util'] = function (...)

local getmetatable, setmetatable, load, loadstring, next
    , pairs, pcall, print, rawget, rawset, select, tostring
    , type, unpack
    = getmetatable, setmetatable, load, loadstring, next
    , pairs, pcall, print, rawget, rawset, select, tostring
    , type, unpack
local m, s, t = require"math", require"string", require"table"
local m_max, s_match, s_gsub, t_concat, t_insert
    = m.max, s.match, s.gsub, t.concat, t.insert
local compat = require"compat"
local
function nop () end
local noglobals, getglobal, setglobal if pcall and not compat.lua52 and not release then
    local function errR (_,i)
        error("illegal global read: " .. tostring(i), 2)
    end
    local function errW (_,i, v)
        error("illegal global write: " .. tostring(i)..": "..tostring(v), 2)
    end
    local env = setmetatable({}, { __index=errR, __newindex=errW })
    noglobals = function()
        pcall(setfenv, 3, env)
    end
    function getglobal(k) return rawget(env, k) end
    function setglobal(k, v) rawset(env, k, v) end
else
    noglobals = nop
end
local _ENV = noglobals() ------------------------------------------------------
local util = {
    nop = nop,
    noglobals = noglobals,
    getglobal = getglobal,
    setglobal = setglobal
}
util.unpack = t.unpack or unpack
util.pack = t.pack or function(...) return { n = select('#', ...), ... } end
if compat.lua51 then
    local old_load = load
   function util.load (ld, source, mode, env)
     local fun
     if type (ld) == 'string' then
       fun = loadstring (ld)
     else
       fun = old_load (ld, source)
     end
     if env then
       setfenv (fun, env)
     end
     return fun
   end
else
    util.load = load
end
if compat.luajit and compat.jit then
    function util.max (ary)
        local max = 0
        for i = 1, #ary do
            max = m_max(max,ary[i])
        end
        return max
    end
elseif compat.luajit then
    local t_unpack = util.unpack
    function util.max (ary)
     local len = #ary
        if len <=30 or len > 10240 then
            local max = 0
            for i = 1, #ary do
                local j = ary[i]
                if j > max then max = j end
            end
            return max
        else
            return m_max(t_unpack(ary))
        end
    end
else
    local t_unpack = util.unpack
    local safe_len = 1000
    function util.max(array)
        local len = #array
        if len == 0 then return -1 end -- FIXME: shouldn't this be `return -1`?
        local off = 1
        local off_end = safe_len
        local max = array[1] -- seed max.
        repeat
            if off_end > len then off_end = len end
            local seg_max = m_max(t_unpack(array, off, off_end))
            if seg_max > max then
                max = seg_max
            end
            off = off + safe_len
            off_end = off_end + safe_len
        until off >= len
        return max
    end
end
local
function setmode(t,mode)
    local mt = getmetatable(t) or {}
    if mt.__mode then
        error("The mode has already been set on table "..tostring(t)..".")
    end
    mt.__mode = mode
    return setmetatable(t, mt)
end
util.setmode = setmode
function util.weakboth (t)
    return setmode(t,"kv")
end
function util.weakkey (t)
    return setmode(t,"k")
end
function util.weakval (t)
    return setmode(t,"v")
end
function util.strip_mt (t)
    return setmetatable(t, nil)
end
local getuniqueid
do
    local N, index = 0, {}
    function getuniqueid(v)
        if not index[v] then
            N = N + 1
            index[v] = N
        end
        return index[v]
    end
end
util.getuniqueid = getuniqueid
do
    local counter = 0
    function util.gensym ()
        counter = counter + 1
        return "___SYM_"..counter
    end
end
function util.passprint (...) print(...) return ... end
local val_to_str_, key_to_str, table_tostring, cdata_to_str, t_cache
local multiplier = 2
local
function val_to_string (v, indent)
    indent = indent or 0
    t_cache = {} -- upvalue.
    local acc = {}
    val_to_str_(v, acc, indent, indent)
    local res = t_concat(acc, "")
    return res
end
util.val_to_str = val_to_string
function val_to_str_ ( v, acc, indent, str_indent )
    str_indent = str_indent or 1
    if "string" == type( v ) then
        v = s_gsub( v, "\n",  "\n" .. (" "):rep( indent * multiplier + str_indent ) )
        if s_match( s_gsub( v,"[^'\"]",""), '^"+$' ) then
            acc[#acc+1] = t_concat{ "'", "", v, "'" }
        else
            acc[#acc+1] = t_concat{'"', s_gsub(v,'"', '\\"' ), '"' }
        end
    elseif "cdata" == type( v ) then
            cdata_to_str( v, acc, indent )
    elseif "table" == type(v) then
        if t_cache[v] then
            acc[#acc+1] = t_cache[v]
        else
            t_cache[v] = tostring( v )
            table_tostring( v, acc, indent )
        end
    else
        acc[#acc+1] = tostring( v )
    end
end
function key_to_str ( k, acc, indent )
    if "string" == type( k ) and s_match( k, "^[_%a][_%a%d]*$" ) then
        acc[#acc+1] = s_gsub( k, "\n", (" "):rep( indent * multiplier + 1 ) .. "\n" )
    else
        acc[#acc+1] = "[ "
        val_to_str_( k, acc, indent )
        acc[#acc+1] = " ]"
    end
end
function cdata_to_str(v, acc, indent)
    acc[#acc+1] = ( " " ):rep( indent * multiplier )
    acc[#acc+1] = "["
    print(#acc)
    for i = 0, #v do
        if i % 16 == 0 and i ~= 0 then
            acc[#acc+1] = "\n"
            acc[#acc+1] = (" "):rep(indent * multiplier + 2)
        end
        acc[#acc+1] = v[i] and 1 or 0
        acc[#acc+1] = i ~= #v and  ", " or ""
    end
    print(#acc, acc[1], acc[2])
    acc[#acc+1] = "]"
end
function table_tostring ( tbl, acc, indent )
    acc[#acc+1] = t_cache[tbl]
    acc[#acc+1] = "{\n"
    for k, v in pairs( tbl ) do
        local str_indent = 1
        acc[#acc+1] = (" "):rep((indent + 1) * multiplier)
        key_to_str( k, acc, indent + 1)
        if acc[#acc] == " ]"
        and acc[#acc - 2] == "[ "
        then str_indent = 8 + #acc[#acc - 1]
        end
        acc[#acc+1] = " = "
        val_to_str_( v, acc, indent + 1, str_indent)
        acc[#acc+1] = "\n"
    end
    acc[#acc+1] = ( " " ):rep( indent * multiplier )
    acc[#acc+1] = "}"
end
function util.expose(v) print(val_to_string(v)) return v end
function util.map (ary, func, ...)
    if type(ary) == "function" then ary, func = func, ary end
    local res = {}
    for i = 1,#ary do
        res[i] = func(ary[i], ...)
    end
    return res
end
function util.selfmap (ary, func, ...)
    if type(ary) == "function" then ary, func = func, ary end
    for i = 1,#ary do
        ary[i] = func(ary[i], ...)
    end
    return ary
end
local
function map_all (tbl, func, ...)
    if type(tbl) == "function" then tbl, func = func, tbl end
    local res = {}
    for k, v in next, tbl do
        res[k]=func(v, ...)
    end
    return res
end
util.map_all = map_all
local
function fold (ary, func, acc)
    local i0 = 1
    if not acc then
        acc = ary[1]
        i0 = 2
    end
    for i = i0, #ary do
        acc = func(acc,ary[i])
    end
    return acc
end
util.fold = fold
local
function foldr (ary, func, acc)
    local offset = 0
    if not acc then
        acc = ary[#ary]
        offset = 1
    end
    for i = #ary - offset, 1 , -1 do
        acc = func(ary[i], acc)
    end
    return acc
end
util.foldr = foldr
local
function map_fold(ary, mfunc, ffunc, acc)
    local i0 = 1
    if not acc then
        acc = mfunc(ary[1])
        i0 = 2
    end
    for i = i0, #ary do
        acc = ffunc(acc,mfunc(ary[i]))
    end
    return acc
end
util.map_fold = map_fold
local
function map_foldr(ary, mfunc, ffunc, acc)
    local offset = 0
    if not acc then
        acc = mfunc(ary[#acc])
        offset = 1
    end
    for i = #ary - offset, 1 , -1 do
        acc = ffunc(mfunc(ary[i], acc))
    end
    return acc
end
util.map_foldr = map_fold
function util.zip(a1, a2)
    local res, len = {}, m_max(#a1,#a2)
    for i = 1,len do
        res[i] = {a1[i], a2[i]}
    end
    return res
end
function util.zip_all(t1, t2)
    local res = {}
    for k,v in pairs(t1) do
        res[k] = {v, t2[k]}
    end
    for k,v in pairs(t2) do
        if res[k] == nil then
            res[k] = {t1[k], v}
        end
    end
    return res
end
function util.filter(ary,func)
    local res = {}
    for i = 1,#ary do
        if func(ary[i]) then
            t_insert(res, ary[i])
        end
    end
end
local
function id (...) return ... end
util.id = id
local function AND (a,b) return a and b end
local function OR  (a,b) return a or b  end
function util.copy (tbl) return map_all(tbl, id) end
function util.all (ary, mfunc)
    if mfunc then
        return map_fold(ary, mfunc, AND)
    else
        return fold(ary, AND)
    end
end
function util.any (ary, mfunc)
    if mfunc then
        return map_fold(ary, mfunc, OR)
    else
        return fold(ary, OR)
    end
end
function util.get(field)
    return function(tbl) return tbl[field] end
end
function util.lt(ref)
    return function(val) return val < ref end
end
function util.compose(f,g)
    return function(...) return f(g(...)) end
end
function util.extend (destination, ...)
    for i = 1, select('#', ...) do
        for k,v in pairs((select(i, ...))) do
            destination[k] = v
        end
    end
    return destination
end
function util.setify (t)
    local set = {}
    for i = 1, #t do
        set[t[i]]=true
    end
    return set
end
function util.arrayify (...) return {...} end
local
function _checkstrhelper(s)
    return s..""
end
function util.checkstring(s, func)
    local success, str = pcall(_checkstrhelper, s)
    if not success then
        if func == nil then func = "?" end
        error("bad argument to '"
            ..tostring(func)
            .."' (string expected, got "
            ..type(s)
            ..")",
        2)
    end
    return str
end
return util

end
end
return require"init"



--                   The Romantic WTF public license.
--                   --------------------------------
--                   a.k.a. version "<3" or simply v3
-- 
-- 
--            Dear user,
-- 
--            The LuLPeg library
-- 
--                                             \
--                                              '.,__
--                                           \  /
--                                            '/,__
--                                            /
--                                           /
--                                          /
--                       has been          / released
--                  ~ ~ ~ ~ ~ ~ ~ ~       ~ ~ ~ ~ ~ ~ ~ ~
--                under  the  Romantic   WTF Public License.
--               ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~`,´ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
--               I hereby grant you an irrevocable license to
--                ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
--                  do what the gentle caress you want to
--                       ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
--                           with   this   lovely
--                              ~ ~ ~ ~ ~ ~ ~ ~
--                               / library...
--                              /  ~ ~ ~ ~
--                             /    Love,
--                        #   /      ','
--                        #######    ·
--                        #####
--                        ###
--                        #
-- 
--               -- Pierre-Yves
-- 
-- 
-- 
--            P.S.: Even though I poured my heart into this work,
--                  I _cannot_ provide any warranty regarding
--                  its fitness for _any_ purpose. You
--                  acknowledge that I will not be held liable
--                  for any damage its use could incur.
-- 
-- -----------------------------------------------------------------------------
-- 
-- LuLPeg, Copyright (C) 2013 Pierre-Yves Gérardy.
-- 
-- The `re` module and lpeg.*.*.test.lua,
-- Copyright (C) 2013 Lua.org, PUC-Rio.
-- 
-- Permission is hereby granted, free of charge,
-- to any person obtaining a copy of this software and
-- associated documentation files (the "Software"),
-- to deal in the Software without restriction,
-- including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software,
-- and to permit persons to whom the Software is
-- furnished to do so,
-- subject to the following conditions:
-- 
-- The above copyright notice and this permission notice
-- shall be included in all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
-- DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
end
preload["cc.lfs"] = function(...)
-- Simple implementation of LuaFileSystem for ComputerCraft
-- Only supports the functions needed for Moonscript

local lfs = {}

function lfs.attributes(path, requestName)
    if not fs.exists(path) then
        printError(debug.traceback())
        error("File '" .. path .. "' does not exist", 2)
    end
    local results = fs.attributes(path)
    local adapted = {
        mode = results.isDir and "directory" or "file",
        size = results.size,
        modification = results.modified,
    }

    if requestName then
        return adapted[requestName]
    else
        return adapted
    end
end

function lfs.currentdir()
    return shell.dir()
end

function lfs.dir(path)
    if not fs.isDir(path) then
        error("Directory does not exist", 2)
    end
    local dir = fs.list(path)
    local i = 0
    return function()
        i = i + 1
        return dir[i]
    end
end

function lfs.mkdir(path)
    fs.makeDir(path)
end

function lfs.rmdir(path)
    fs.delete(path)
end

return lfs
end
preload["cc.argparse"] = function(...)
-- The MIT License (MIT)

-- Copyright (c) 2013 - 2018 Peter Melnichenko
--                      2019 Paul Ouellette

-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
-- the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
-- FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
-- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
-- IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local function deep_update(t1, t2)
    for k, v in pairs(t2) do
       if type(v) == "table" then
          v = deep_update({}, v)
       end
 
       t1[k] = v
    end
 
    return t1
 end
 
 -- A property is a tuple {name, callback}.
 -- properties.args is number of properties that can be set as arguments
 -- when calling an object.
 local function class(prototype, properties, parent)
    -- Class is the metatable of its instances.
    local cl = {}
    cl.__index = cl
 
    if parent then
       cl.__prototype = deep_update(deep_update({}, parent.__prototype), prototype)
    else
       cl.__prototype = prototype
    end
 
    if properties then
       local names = {}
 
       -- Create setter methods and fill set of property names.
       for _, property in ipairs(properties) do
          local name, callback = property[1], property[2]
 
          cl[name] = function(self, value)
             if not callback(self, value) then
                self["_" .. name] = value
             end
 
             return self
          end
 
          names[name] = true
       end
 
       function cl.__call(self, ...)
          -- When calling an object, if the first argument is a table,
          -- interpret keys as property names, else delegate arguments
          -- to corresponding setters in order.
          if type((...)) == "table" then
             for name, value in pairs((...)) do
                if names[name] then
                   self[name](self, value)
                end
             end
          else
             local nargs = select("#", ...)
 
             for i, property in ipairs(properties) do
                if i > nargs or i > properties.args then
                   break
                end
 
                local arg = select(i, ...)
 
                if arg ~= nil then
                   self[property[1]](self, arg)
                end
             end
          end
 
          return self
       end
    end
 
    -- If indexing class fails, fallback to its parent.
    local class_metatable = {}
    class_metatable.__index = parent
 
    function class_metatable.__call(self, ...)
       -- Calling a class returns its instance.
       -- Arguments are delegated to the instance.
       local object = deep_update({}, self.__prototype)
       setmetatable(object, self)
       return object(...)
    end
 
    return setmetatable(cl, class_metatable)
 end
 
 local function typecheck(name, types, value)
    for _, type_ in ipairs(types) do
       if type(value) == type_ then
          return true
       end
    end
 
    error(("bad property '%s' (%s expected, got %s)"):format(name, table.concat(types, " or "), type(value)))
 end
 
 local function typechecked(name, ...)
    local types = {...}
    return {name, function(_, value) typecheck(name, types, value) end}
 end
 
 local multiname = {"name", function(self, value)
    typecheck("name", {"string"}, value)
 
    for alias in value:gmatch("%S+") do
       self._name = self._name or alias
       table.insert(self._aliases, alias)
       table.insert(self._public_aliases, alias)
       -- If alias contains '_', accept '-' also.
       if alias:find("_", 1, true) then
          table.insert(self._aliases, (alias:gsub("_", "-")))
       end
    end
 
    -- Do not set _name as with other properties.
    return true
 end}
 
 local multiname_hidden = {"hidden_name", function(self, value)
    typecheck("hidden_name", {"string"}, value)
 
    for alias in value:gmatch("%S+") do
       table.insert(self._aliases, alias)
       if alias:find("_", 1, true) then
          table.insert(self._aliases, (alias:gsub("_", "-")))
       end
    end
 
    return true
 end}
 
 local function parse_boundaries(str)
    if tonumber(str) then
       return tonumber(str), tonumber(str)
    end
 
    if str == "*" then
       return 0, math.huge
    end
 
    if str == "+" then
       return 1, math.huge
    end
 
    if str == "?" then
       return 0, 1
    end
 
    if str:match "^%d+%-%d+$" then
       local min, max = str:match "^(%d+)%-(%d+)$"
       return tonumber(min), tonumber(max)
    end
 
    if str:match "^%d+%+$" then
       local min = str:match "^(%d+)%+$"
       return tonumber(min), math.huge
    end
 end
 
 local function boundaries(name)
    return {name, function(self, value)
       typecheck(name, {"number", "string"}, value)
 
       local min, max = parse_boundaries(value)
 
       if not min then
          error(("bad property '%s'"):format(name))
       end
 
       self["_min" .. name], self["_max" .. name] = min, max
    end}
 end
 
 local actions = {}
 
 local option_action = {"action", function(_, value)
    typecheck("action", {"function", "string"}, value)
 
    if type(value) == "string" and not actions[value] then
       error(("unknown action '%s'"):format(value))
    end
 end}
 
 local option_init = {"init", function(self)
    self._has_init = true
 end}
 
 local option_default = {"default", function(self, value)
    if type(value) ~= "string" then
       self._init = value
       self._has_init = true
       return true
    end
 end}
 
 local add_help = {"add_help", function(self, value)
    typecheck("add_help", {"boolean", "string", "table"}, value)
 
    if self._help_option_idx then
       table.remove(self._options, self._help_option_idx)
       self._help_option_idx = nil
    end
 
    if value then
       local help = self:flag()
          :description "Show this help message and exit."
          :action(function()
             print(self:get_help())
             error(nil, 0)
          end)
 
       if value ~= true then
          help = help(value)
       end
 
       if not help._name then
          help "-h" "--help"
       end
 
       self._help_option_idx = #self._options
    end
 end}
 
 local Parser = class({
    _arguments = {},
    _options = {},
    _commands = {},
    _mutexes = {},
    _groups = {},
    _require_command = true,
    _handle_options = true
 }, {
    args = 3,
    typechecked("name", "string"),
    typechecked("description", "string"),
    typechecked("epilog", "string"),
    typechecked("usage", "string"),
    typechecked("help", "string"),
    typechecked("require_command", "boolean"),
    typechecked("handle_options", "boolean"),
    typechecked("action", "function"),
    typechecked("command_target", "string"),
    typechecked("help_vertical_space", "number"),
    typechecked("usage_margin", "number"),
    typechecked("usage_max_width", "number"),
    typechecked("help_usage_margin", "number"),
    typechecked("help_description_margin", "number"),
    typechecked("help_max_width", "number"),
    add_help
 })
 
 local Command = class({
    _aliases = {},
    _public_aliases = {}
 }, {
    args = 3,
    multiname,
    typechecked("description", "string"),
    typechecked("epilog", "string"),
    multiname_hidden,
    typechecked("summary", "string"),
    typechecked("target", "string"),
    typechecked("usage", "string"),
    typechecked("help", "string"),
    typechecked("require_command", "boolean"),
    typechecked("handle_options", "boolean"),
    typechecked("action", "function"),
    typechecked("command_target", "string"),
    typechecked("help_vertical_space", "number"),
    typechecked("usage_margin", "number"),
    typechecked("usage_max_width", "number"),
    typechecked("help_usage_margin", "number"),
    typechecked("help_description_margin", "number"),
    typechecked("help_max_width", "number"),
    typechecked("hidden", "boolean"),
    add_help
 }, Parser)
 
 local Argument = class({
    _minargs = 1,
    _maxargs = 1,
    _mincount = 1,
    _maxcount = 1,
    _defmode = "unused",
    _show_default = true
 }, {
    args = 5,
    typechecked("name", "string"),
    typechecked("description", "string"),
    option_default,
    typechecked("convert", "function", "table"),
    boundaries("args"),
    typechecked("target", "string"),
    typechecked("defmode", "string"),
    typechecked("show_default", "boolean"),
    typechecked("argname", "string", "table"),
    typechecked("choices", "table"),
    typechecked("hidden", "boolean"),
    option_action,
    option_init
 })
 
 local Option = class({
    _aliases = {},
    _public_aliases = {},
    _mincount = 0,
    _overwrite = true
 }, {
    args = 6,
    multiname,
    typechecked("description", "string"),
    option_default,
    typechecked("convert", "function", "table"),
    boundaries("args"),
    boundaries("count"),
    multiname_hidden,
    typechecked("target", "string"),
    typechecked("defmode", "string"),
    typechecked("show_default", "boolean"),
    typechecked("overwrite", "boolean"),
    typechecked("argname", "string", "table"),
    typechecked("choices", "table"),
    typechecked("hidden", "boolean"),
    option_action,
    option_init
 }, Argument)
 
 function Parser:_inherit_property(name, default)
    local element = self
 
    while true do
       local value = element["_" .. name]
 
       if value ~= nil then
          return value
       end
 
       if not element._parent then
          return default
       end
 
       element = element._parent
    end
 end
 
 function Argument:_get_argument_list()
    local buf = {}
    local i = 1
 
    while i <= math.min(self._minargs, 3) do
       local argname = self:_get_argname(i)
 
       if self._default and self._defmode:find "a" then
          argname = "[" .. argname .. "]"
       end
 
       table.insert(buf, argname)
       i = i+1
    end
 
    while i <= math.min(self._maxargs, 3) do
       table.insert(buf, "[" .. self:_get_argname(i) .. "]")
       i = i+1
 
       if self._maxargs == math.huge then
          break
       end
    end
 
    if i < self._maxargs then
       table.insert(buf, "...")
    end
 
    return buf
 end
 
 function Argument:_get_usage()
    local usage = table.concat(self:_get_argument_list(), " ")
 
    if self._default and self._defmode:find "u" then
       if self._maxargs > 1 or (self._minargs == 1 and not self._defmode:find "a") then
          usage = "[" .. usage .. "]"
       end
    end
 
    return usage
 end
 
 function actions.store_true(result, target)
    result[target] = true
 end
 
 function actions.store_false(result, target)
    result[target] = false
 end
 
 function actions.store(result, target, argument)
    result[target] = argument
 end
 
 function actions.count(result, target, _, overwrite)
    if not overwrite then
       result[target] = result[target] + 1
    end
 end
 
 function actions.append(result, target, argument, overwrite)
    result[target] = result[target] or {}
    table.insert(result[target], argument)
 
    if overwrite then
       table.remove(result[target], 1)
    end
 end
 
 function actions.concat(result, target, arguments, overwrite)
    if overwrite then
       error("'concat' action can't handle too many invocations")
    end
 
    result[target] = result[target] or {}
 
    for _, argument in ipairs(arguments) do
       table.insert(result[target], argument)
    end
 end
 
 function Argument:_get_action()
    local action, init
 
    if self._maxcount == 1 then
       if self._maxargs == 0 then
          action, init = "store_true", nil
       else
          action, init = "store", nil
       end
    else
       if self._maxargs == 0 then
          action, init = "count", 0
       else
          action, init = "append", {}
       end
    end
 
    if self._action then
       action = self._action
    end
 
    if self._has_init then
       init = self._init
    end
 
    if type(action) == "string" then
       action = actions[action]
    end
 
    return action, init
 end
 
 -- Returns placeholder for `narg`-th argument.
 function Argument:_get_argname(narg)
    local argname = self._argname or self:_get_default_argname()
 
    if type(argname) == "table" then
       return argname[narg]
    else
       return argname
    end
 end
 
 function Argument:_get_choices_list()
    return "{" .. table.concat(self._choices, ",") .. "}"
 end
 
 function Argument:_get_default_argname()
    if self._choices then
       return self:_get_choices_list()
    else
       return "<" .. self._name .. ">"
    end
 end
 
 function Option:_get_default_argname()
    if self._choices then
       return self:_get_choices_list()
    else
       return "<" .. self:_get_default_target() .. ">"
    end
 end
 
 -- Returns labels to be shown in the help message.
 function Argument:_get_label_lines()
    if self._choices then
       return {self:_get_choices_list()}
    else
       return {self._name}
    end
 end
 
 function Option:_get_label_lines()
    local argument_list = self:_get_argument_list()
 
    if #argument_list == 0 then
       -- Don't put aliases for simple flags like `-h` on different lines.
       return {table.concat(self._public_aliases, ", ")}
    end
 
    local longest_alias_length = -1
 
    for _, alias in ipairs(self._public_aliases) do
       longest_alias_length = math.max(longest_alias_length, #alias)
    end
 
    local argument_list_repr = table.concat(argument_list, " ")
    local lines = {}
 
    for i, alias in ipairs(self._public_aliases) do
       local line = (" "):rep(longest_alias_length - #alias) .. alias .. " " .. argument_list_repr
 
       if i ~= #self._public_aliases then
          line = line .. ","
       end
 
       table.insert(lines, line)
    end
 
    return lines
 end
 
 function Command:_get_label_lines()
    return {table.concat(self._public_aliases, ", ")}
 end
 
 function Argument:_get_description()
    if self._default and self._show_default then
       if self._description then
          return ("%s (default: %s)"):format(self._description, self._default)
       else
          return ("default: %s"):format(self._default)
       end
    else
       return self._description or ""
    end
 end
 
 function Command:_get_description()
    return self._summary or self._description or ""
 end
 
 function Option:_get_usage()
    local usage = self:_get_argument_list()
    table.insert(usage, 1, self._name)
    usage = table.concat(usage, " ")
 
    if self._mincount == 0 or self._default then
       usage = "[" .. usage .. "]"
    end
 
    return usage
 end
 
 function Argument:_get_default_target()
    return self._name
 end
 
 function Option:_get_default_target()
    local res
 
    for _, alias in ipairs(self._public_aliases) do
       if alias:sub(1, 1) == alias:sub(2, 2) then
          res = alias:sub(3)
          break
       end
    end
 
    res = res or self._name:sub(2)
    return (res:gsub("-", "_"))
 end
 
 function Option:_is_vararg()
    return self._maxargs ~= self._minargs
 end
 
 function Parser:_get_fullname(exclude_root)
    local parent = self._parent
    if exclude_root and not parent then
       return ""
    end
    local buf = {self._name}
 
    while parent do
       if not exclude_root or parent._parent then
          table.insert(buf, 1, parent._name)
       end
       parent = parent._parent
    end
 
    return table.concat(buf, " ")
 end
 
 function Parser:_update_charset(charset)
    charset = charset or {}
 
    for _, command in ipairs(self._commands) do
       command:_update_charset(charset)
    end
 
    for _, option in ipairs(self._options) do
       for _, alias in ipairs(option._aliases) do
          charset[alias:sub(1, 1)] = true
       end
    end
 
    return charset
 end
 
 function Parser:argument(...)
    local argument = Argument(...)
    table.insert(self._arguments, argument)
    return argument
 end
 
 function Parser:option(...)
    local option = Option(...)
    table.insert(self._options, option)
    return option
 end
 
 function Parser:flag(...)
    return self:option():args(0)(...)
 end
 
 function Parser:command(...)
    local command = Command():add_help(true)(...)
    command._parent = self
    table.insert(self._commands, command)
    return command
 end
 
 function Parser:mutex(...)
    local elements = {...}
 
    for i, element in ipairs(elements) do
       local mt = getmetatable(element)
       assert(mt == Option or mt == Argument, ("bad argument #%d to 'mutex' (Option or Argument expected)"):format(i))
    end
 
    table.insert(self._mutexes, elements)
    return self
 end
 
 function Parser:group(name, ...)
    assert(type(name) == "string", ("bad argument #1 to 'group' (string expected, got %s)"):format(type(name)))
 
    local group = {name = name, ...}
 
    for i, element in ipairs(group) do
       local mt = getmetatable(element)
       assert(mt == Option or mt == Argument or mt == Command,
          ("bad argument #%d to 'group' (Option or Argument or Command expected)"):format(i + 1))
    end
 
    table.insert(self._groups, group)
    return self
 end
 
 local usage_welcome = "Usage: "
 
 function Parser:get_usage()
    if self._usage then
       return self._usage
    end
 
    local usage_margin = self:_inherit_property("usage_margin", #usage_welcome)
    local max_usage_width = self:_inherit_property("usage_max_width", 70)
    local lines = {usage_welcome .. self:_get_fullname()}
 
    local function add(s)
       if #lines[#lines]+1+#s <= max_usage_width then
          lines[#lines] = lines[#lines] .. " " .. s
       else
          lines[#lines+1] = (" "):rep(usage_margin) .. s
       end
    end
 
    -- Normally options are before positional arguments in usage messages.
    -- However, vararg options should be after, because they can't be reliable used
    -- before a positional argument.
    -- Mutexes come into play, too, and are shown as soon as possible.
    -- Overall, output usages in the following order:
    -- 1. Mutexes that don't have positional arguments or vararg options.
    -- 2. Options that are not in any mutexes and are not vararg.
    -- 3. Positional arguments - on their own or as a part of a mutex.
    -- 4. Remaining mutexes.
    -- 5. Remaining options.
 
    local elements_in_mutexes = {}
    local added_elements = {}
    local added_mutexes = {}
    local argument_to_mutexes = {}
 
    local function add_mutex(mutex, main_argument)
       if added_mutexes[mutex] then
          return
       end
 
       added_mutexes[mutex] = true
       local buf = {}
 
       for _, element in ipairs(mutex) do
          if not element._hidden and not added_elements[element] then
             if getmetatable(element) == Option or element == main_argument then
                table.insert(buf, element:_get_usage())
                added_elements[element] = true
             end
          end
       end
 
       if #buf == 1 then
          add(buf[1])
       elseif #buf > 1 then
          add("(" .. table.concat(buf, " | ") .. ")")
       end
    end
 
    local function add_element(element)
       if not element._hidden and not added_elements[element] then
          add(element:_get_usage())
          added_elements[element] = true
       end
    end
 
    for _, mutex in ipairs(self._mutexes) do
       local is_vararg = false
       local has_argument = false
 
       for _, element in ipairs(mutex) do
          if getmetatable(element) == Option then
             if element:_is_vararg() then
                is_vararg = true
             end
          else
             has_argument = true
             argument_to_mutexes[element] = argument_to_mutexes[element] or {}
             table.insert(argument_to_mutexes[element], mutex)
          end
 
          elements_in_mutexes[element] = true
       end
 
       if not is_vararg and not has_argument then
          add_mutex(mutex)
       end
    end
 
    for _, option in ipairs(self._options) do
       if not elements_in_mutexes[option] and not option:_is_vararg() then
          add_element(option)
       end
    end
 
    -- Add usages for positional arguments, together with one mutex containing them, if they are in a mutex.
    for _, argument in ipairs(self._arguments) do
       -- Pick a mutex as a part of which to show this argument, take the first one that's still available.
       local mutex
 
       if elements_in_mutexes[argument] then
          for _, argument_mutex in ipairs(argument_to_mutexes[argument]) do
             if not added_mutexes[argument_mutex] then
                mutex = argument_mutex
             end
          end
       end
 
       if mutex then
          add_mutex(mutex, argument)
       else
          add_element(argument)
       end
    end
 
    for _, mutex in ipairs(self._mutexes) do
       add_mutex(mutex)
    end
 
    for _, option in ipairs(self._options) do
       add_element(option)
    end
 
    if #self._commands > 0 then
       if self._require_command then
          add("<command>")
       else
          add("[<command>]")
       end
 
       add("...")
    end
 
    return table.concat(lines, "\n")
 end
 
 local function split_lines(s)
    if s == "" then
       return {}
    end
 
    local lines = {}
 
    if s:sub(-1) ~= "\n" then
       s = s .. "\n"
    end
 
    for line in s:gmatch("([^\n]*)\n") do
       table.insert(lines, line)
    end
 
    return lines
 end
 
 local function autowrap_line(line, max_length)
    -- Algorithm for splitting lines is simple and greedy.
    local result_lines = {}
 
    -- Preserve original indentation of the line, put this at the beginning of each result line.
    -- If the first word looks like a list marker ('*', '+', or '-'), add spaces so that starts
    -- of the second and the following lines vertically align with the start of the second word.
    local indentation = line:match("^ *")
 
    if line:find("^ *[%*%+%-]") then
       indentation = indentation .. " " .. line:match("^ *[%*%+%-]( *)")
    end
 
    -- Parts of the last line being assembled.
    local line_parts = {}
 
    -- Length of the current line.
    local line_length = 0
 
    -- Index of the next character to consider.
    local index = 1
 
    while true do
       local word_start, word_finish, word = line:find("([^ ]+)", index)
 
       if not word_start then
          -- Ignore trailing spaces, if any.
          break
       end
 
       local preceding_spaces = line:sub(index, word_start - 1)
       index = word_finish + 1
 
       if (#line_parts == 0) or (line_length + #preceding_spaces + #word <= max_length) then
          -- Either this is the very first word or it fits as an addition to the current line, add it.
          table.insert(line_parts, preceding_spaces) -- For the very first word this adds the indentation.
          table.insert(line_parts, word)
          line_length = line_length + #preceding_spaces + #word
       else
          -- Does not fit, finish current line and put the word into a new one.
          table.insert(result_lines, table.concat(line_parts))
          line_parts = {indentation, word}
          line_length = #indentation + #word
       end
    end
 
    if #line_parts > 0 then
       table.insert(result_lines, table.concat(line_parts))
    end
 
    if #result_lines == 0 then
       -- Preserve empty lines.
       result_lines[1] = ""
    end
 
    return result_lines
 end
 
 -- Automatically wraps lines within given array,
 -- attempting to limit line length to `max_length`.
 -- Existing line splits are preserved.
 local function autowrap(lines, max_length)
    local result_lines = {}
 
    for _, line in ipairs(lines) do
       local autowrapped_lines = autowrap_line(line, max_length)
 
       for _, autowrapped_line in ipairs(autowrapped_lines) do
          table.insert(result_lines, autowrapped_line)
       end
    end
 
    return result_lines
 end
 
 function Parser:_get_element_help(element)
    local label_lines = element:_get_label_lines()
    local description_lines = split_lines(element:_get_description())
 
    local result_lines = {}
 
    -- All label lines should have the same length (except the last one, it has no comma).
    -- If too long, start description after all the label lines.
    -- Otherwise, combine label and description lines.
 
    local usage_margin_len = self:_inherit_property("help_usage_margin", 3)
    local usage_margin = (" "):rep(usage_margin_len)
    local description_margin_len = self:_inherit_property("help_description_margin", 25)
    local description_margin = (" "):rep(description_margin_len)
 
    local help_max_width = self:_inherit_property("help_max_width")
 
    if help_max_width then
       local description_max_width = math.max(help_max_width - description_margin_len, 10)
       description_lines = autowrap(description_lines, description_max_width)
    end
 
    if #label_lines[1] >= (description_margin_len - usage_margin_len) then
       for _, label_line in ipairs(label_lines) do
          table.insert(result_lines, usage_margin .. label_line)
       end
 
       for _, description_line in ipairs(description_lines) do
          table.insert(result_lines, description_margin .. description_line)
       end
    else
       for i = 1, math.max(#label_lines, #description_lines) do
          local label_line = label_lines[i]
          local description_line = description_lines[i]
 
          local line = ""
 
          if label_line then
             line = usage_margin .. label_line
          end
 
          if description_line and description_line ~= "" then
             line = line .. (" "):rep(description_margin_len - #line) .. description_line
          end
 
          table.insert(result_lines, line)
       end
    end
 
    return table.concat(result_lines, "\n")
 end
 
 local function get_group_types(group)
    local types = {}
 
    for _, element in ipairs(group) do
       types[getmetatable(element)] = true
    end
 
    return types
 end
 
 function Parser:_add_group_help(blocks, added_elements, label, elements)
    local buf = {label}
 
    for _, element in ipairs(elements) do
       if not element._hidden and not added_elements[element] then
          added_elements[element] = true
          table.insert(buf, self:_get_element_help(element))
       end
    end
 
    if #buf > 1 then
       table.insert(blocks, table.concat(buf, ("\n"):rep(self:_inherit_property("help_vertical_space", 0) + 1)))
    end
 end
 
 function Parser:get_help()
    if self._help then
       return self._help
    end
 
    local blocks = {self:get_usage()}
 
    local help_max_width = self:_inherit_property("help_max_width")
 
    if self._description then
       local description = self._description
 
       if help_max_width then
          description = table.concat(autowrap(split_lines(description), help_max_width), "\n")
       end
 
       table.insert(blocks, description)
    end
 
    -- 1. Put groups containing arguments first, then other arguments.
    -- 2. Put remaining groups containing options, then other options.
    -- 3. Put remaining groups containing commands, then other commands.
    -- Assume that an element can't be in several groups.
    local groups_by_type = {
       [Argument] = {},
       [Option] = {},
       [Command] = {}
    }
 
    for _, group in ipairs(self._groups) do
       local group_types = get_group_types(group)
 
       for _, mt in ipairs({Argument, Option, Command}) do
          if group_types[mt] then
             table.insert(groups_by_type[mt], group)
             break
          end
       end
    end
 
    local default_groups = {
       {name = "Arguments", type = Argument, elements = self._arguments},
       {name = "Options", type = Option, elements = self._options},
       {name = "Commands", type = Command, elements = self._commands}
    }
 
    local added_elements = {}
 
    for _, default_group in ipairs(default_groups) do
       local type_groups = groups_by_type[default_group.type]
 
       for _, group in ipairs(type_groups) do
          self:_add_group_help(blocks, added_elements, group.name .. ":", group)
       end
 
       local default_label = default_group.name .. ":"
 
       if #type_groups > 0 then
          default_label = "Other " .. default_label:gsub("^.", string.lower)
       end
 
       self:_add_group_help(blocks, added_elements, default_label, default_group.elements)
    end
 
    if self._epilog then
       local epilog = self._epilog
 
       if help_max_width then
          epilog = table.concat(autowrap(split_lines(epilog), help_max_width), "\n")
       end
 
       table.insert(blocks, epilog)
    end
 
    return table.concat(blocks, "\n\n")
 end
 
 function Parser:add_help_command(value)
    if value then
       assert(type(value) == "string" or type(value) == "table",
          ("bad argument #1 to 'add_help_command' (string or table expected, got %s)"):format(type(value)))
    end
 
    local help = self:command()
       :description "Show help for commands."
    help:argument "command"
       :description "The command to show help for."
       :args "?"
       :action(function(_, _, cmd)
          if not cmd then
             print(self:get_help())
             error(nil, 0)
          else
             for _, command in ipairs(self._commands) do
                for _, alias in ipairs(command._aliases) do
                   if alias == cmd then
                      print(command:get_help())
                      error(nil, 0)
                   end
                end
             end
          end
          help:error(("unknown command '%s'"):format(cmd))
       end)
 
    if value then
       help = help(value)
    end
 
    if not help._name then
       help "help"
    end
 
    help._is_help_command = true
    return self
 end
 
 function Parser:_is_shell_safe()
    if self._basename then
       if self._basename:find("[^%w_%-%+%.]") then
          return false
       end
    else
       for _, alias in ipairs(self._aliases) do
          if alias:find("[^%w_%-%+%.]") then
             return false
          end
       end
    end
    for _, option in ipairs(self._options) do
       for _, alias in ipairs(option._aliases) do
          if alias:find("[^%w_%-%+%.]") then
             return false
          end
       end
       if option._choices then
          for _, choice in ipairs(option._choices) do
             if choice:find("[%s'\"]") then
                return false
             end
          end
       end
    end
    for _, argument in ipairs(self._arguments) do
       if argument._choices then
          for _, choice in ipairs(argument._choices) do
             if choice:find("[%s'\"]") then
                return false
             end
          end
       end
    end
    for _, command in ipairs(self._commands) do
       if not command:_is_shell_safe() then
          return false
       end
    end
    return true
 end
 
 function Parser:add_complete(value)
    if value then
       assert(type(value) == "string" or type(value) == "table",
          ("bad argument #1 to 'add_complete' (string or table expected, got %s)"):format(type(value)))
    end
 
    local complete = self:option()
       :description "Output a shell completion script for the specified shell."
       :args(1)
       :choices {"bash", "zsh", "fish"}
       :action(function(_, _, shell)
          io.write(self["get_" .. shell .. "_complete"](self))
          error(nil, 0)
       end)
 
    if value then
       complete = complete(value)
    end
 
    if not complete._name then
       complete "--completion"
    end
 
    return self
 end
 
 function Parser:add_complete_command(value)
    if value then
       assert(type(value) == "string" or type(value) == "table",
          ("bad argument #1 to 'add_complete_command' (string or table expected, got %s)"):format(type(value)))
    end
 
    local complete = self:command()
       :description "Output a shell completion script."
    complete:argument "shell"
       :description "The shell to output a completion script for."
       :choices {"bash", "zsh", "fish"}
       :action(function(_, _, shell)
          io.write(self["get_" .. shell .. "_complete"](self))
          error(nil, 0)
       end)
 
    if value then
       complete = complete(value)
    end
 
    if not complete._name then
       complete "completion"
    end
 
    return self
 end
 
 local function base_name(pathname)
    return pathname:gsub("[/\\]*$", ""):match(".*[/\\]([^/\\]*)") or pathname
 end
 
 local function get_short_description(element)
    local short = element:_get_description():match("^(.-)%.%s")
    return short or element:_get_description():match("^(.-)%.?$")
 end
 
 function Parser:_get_options()
    local options = {}
    for _, option in ipairs(self._options) do
       for _, alias in ipairs(option._aliases) do
          table.insert(options, alias)
       end
    end
    return table.concat(options, " ")
 end
 
 function Parser:_get_commands()
    local commands = {}
    for _, command in ipairs(self._commands) do
       for _, alias in ipairs(command._aliases) do
          table.insert(commands, alias)
       end
    end
    return table.concat(commands, " ")
 end
 
 function Parser:_bash_option_args(buf, indent)
    local opts = {}
    for _, option in ipairs(self._options) do
       if option._choices or option._minargs > 0 then
          local compreply
          if option._choices then
             compreply = 'COMPREPLY=($(compgen -W "' .. table.concat(option._choices, " ") .. '" -- "$cur"))'
          else
             compreply = 'COMPREPLY=($(compgen -f -- "$cur"))'
          end
          table.insert(opts, (" "):rep(indent + 4) .. table.concat(option._aliases, "|") .. ")")
          table.insert(opts, (" "):rep(indent + 8) .. compreply)
          table.insert(opts, (" "):rep(indent + 8) .. "return 0")
          table.insert(opts, (" "):rep(indent + 8) .. ";;")
       end
    end
 
    if #opts > 0 then
       table.insert(buf, (" "):rep(indent) .. 'case "$prev" in')
       table.insert(buf, table.concat(opts, "\n"))
       table.insert(buf, (" "):rep(indent) .. "esac\n")
    end
 end
 
 function Parser:_bash_get_cmd(buf, indent)
    if #self._commands == 0 then
       return
    end
 
    table.insert(buf, (" "):rep(indent) .. 'args=("${args[@]:1}")')
    table.insert(buf, (" "):rep(indent) .. 'for arg in "${args[@]}"; do')
    table.insert(buf, (" "):rep(indent + 4) .. 'case "$arg" in')
 
    for _, command in ipairs(self._commands) do
       table.insert(buf, (" "):rep(indent + 8) .. table.concat(command._aliases, "|") .. ")")
       if self._parent then
          table.insert(buf, (" "):rep(indent + 12) .. 'cmd="$cmd ' .. command._name .. '"')
       else
          table.insert(buf, (" "):rep(indent + 12) .. 'cmd="' .. command._name .. '"')
       end
       table.insert(buf, (" "):rep(indent + 12) .. 'opts="$opts ' .. command:_get_options() .. '"')
       command:_bash_get_cmd(buf, indent + 12)
       table.insert(buf, (" "):rep(indent + 12) .. "break")
       table.insert(buf, (" "):rep(indent + 12) .. ";;")
    end
 
    table.insert(buf, (" "):rep(indent + 4) .. "esac")
    table.insert(buf, (" "):rep(indent) .. "done")
 end
 
 function Parser:_bash_cmd_completions(buf)
    local cmd_buf = {}
    if self._parent then
       self:_bash_option_args(cmd_buf, 12)
    end
    if #self._commands > 0 then
       table.insert(cmd_buf, (" "):rep(12) .. 'COMPREPLY=($(compgen -W "' .. self:_get_commands() .. '" -- "$cur"))')
    elseif self._is_help_command then
       table.insert(cmd_buf, (" "):rep(12)
          .. 'COMPREPLY=($(compgen -W "'
          .. self._parent:_get_commands()
          .. '" -- "$cur"))')
    end
    if #cmd_buf > 0 then
       table.insert(buf, (" "):rep(8) .. "'" .. self:_get_fullname(true) .. "')")
       table.insert(buf, table.concat(cmd_buf, "\n"))
       table.insert(buf, (" "):rep(12) .. ";;")
    end
 
    for _, command in ipairs(self._commands) do
       command:_bash_cmd_completions(buf)
    end
 end
 
 function Parser:get_bash_complete()
    self._basename = base_name(self._name)
    assert(self:_is_shell_safe())
    local buf = {([[
 _%s() {
     local IFS=$' \t\n'
     local args cur prev cmd opts arg
     args=("${COMP_WORDS[@]}")
     cur="${COMP_WORDS[COMP_CWORD]}"
     prev="${COMP_WORDS[COMP_CWORD-1]}"
     opts="%s"
 ]]):format(self._basename, self:_get_options())}
 
    self:_bash_option_args(buf, 4)
    self:_bash_get_cmd(buf, 4)
    if #self._commands > 0 then
       table.insert(buf, "")
       table.insert(buf, (" "):rep(4) .. 'case "$cmd" in')
       self:_bash_cmd_completions(buf)
       table.insert(buf, (" "):rep(4) .. "esac\n")
    end
 
    table.insert(buf, ([=[
     if [[ "$cur" = -* ]]; then
         COMPREPLY=($(compgen -W "$opts" -- "$cur"))
     fi
 }
 
 complete -F _%s -o bashdefault -o default %s
 ]=]):format(self._basename, self._basename))
 
    return table.concat(buf, "\n")
 end
 
 function Parser:_zsh_arguments(buf, cmd_name, indent)
    if self._parent then
       table.insert(buf, (" "):rep(indent) .. "options=(")
       table.insert(buf, (" "):rep(indent + 2) .. "$options")
    else
       table.insert(buf, (" "):rep(indent) .. "local -a options=(")
    end
 
    for _, option in ipairs(self._options) do
       local line = {}
       if #option._aliases > 1 then
          if option._maxcount > 1 then
             table.insert(line, '"*"')
          end
          table.insert(line, "{" .. table.concat(option._aliases, ",") .. '}"')
       else
          table.insert(line, '"')
          if option._maxcount > 1 then
             table.insert(line, "*")
          end
          table.insert(line, option._name)
       end
       if option._description then
          local description = get_short_description(option):gsub('["%]:`$]', "\\%0")
          table.insert(line, "[" .. description .. "]")
       end
       if option._maxargs == math.huge then
          table.insert(line, ":*")
       end
       if option._choices then
          table.insert(line, ": :(" .. table.concat(option._choices, " ") .. ")")
       elseif option._maxargs > 0 then
          table.insert(line, ": :_files")
       end
       table.insert(line, '"')
       table.insert(buf, (" "):rep(indent + 2) .. table.concat(line))
    end
 
    table.insert(buf, (" "):rep(indent) .. ")")
    table.insert(buf, (" "):rep(indent) .. "_arguments -s -S \\")
    table.insert(buf, (" "):rep(indent + 2) .. "$options \\")
 
    if self._is_help_command then
       table.insert(buf, (" "):rep(indent + 2) .. '": :(' .. self._parent:_get_commands() .. ')" \\')
    else
       for _, argument in ipairs(self._arguments) do
          local spec
          if argument._choices then
             spec = ": :(" .. table.concat(argument._choices, " ") .. ")"
          else
             spec = ": :_files"
          end
          if argument._maxargs == math.huge then
             table.insert(buf, (" "):rep(indent + 2) .. '"*' .. spec .. '" \\')
             break
          end
          for _ = 1, argument._maxargs do
             table.insert(buf, (" "):rep(indent + 2) .. '"' .. spec .. '" \\')
          end
       end
 
       if #self._commands > 0 then
          table.insert(buf, (" "):rep(indent + 2) .. '": :_' .. cmd_name .. '_cmds" \\')
          table.insert(buf, (" "):rep(indent + 2) .. '"*:: :->args" \\')
       end
    end
 
    table.insert(buf, (" "):rep(indent + 2) .. "&& return 0")
 end
 
 function Parser:_zsh_cmds(buf, cmd_name)
    table.insert(buf, "\n_" .. cmd_name .. "_cmds() {")
    table.insert(buf, "  local -a commands=(")
 
    for _, command in ipairs(self._commands) do
       local line = {}
       if #command._aliases > 1 then
          table.insert(line, "{" .. table.concat(command._aliases, ",") .. '}"')
       else
          table.insert(line, '"' .. command._name)
       end
       if command._description then
          table.insert(line, ":" .. get_short_description(command):gsub('["`$]', "\\%0"))
       end
       table.insert(buf, "    " .. table.concat(line) .. '"')
    end
 
    table.insert(buf, '  )\n  _describe "command" commands\n}')
 end
 
 function Parser:_zsh_complete_help(buf, cmds_buf, cmd_name, indent)
    if #self._commands == 0 then
       return
    end
 
    self:_zsh_cmds(cmds_buf, cmd_name)
    table.insert(buf, "\n" .. (" "):rep(indent) .. "case $words[1] in")
 
    for _, command in ipairs(self._commands) do
       local name = cmd_name .. "_" .. command._name
       table.insert(buf, (" "):rep(indent + 2) .. table.concat(command._aliases, "|") .. ")")
       command:_zsh_arguments(buf, name, indent + 4)
       command:_zsh_complete_help(buf, cmds_buf, name, indent + 4)
       table.insert(buf, (" "):rep(indent + 4) .. ";;\n")
    end
 
    table.insert(buf, (" "):rep(indent) .. "esac")
 end
 
 function Parser:get_zsh_complete()
    self._basename = base_name(self._name)
    assert(self:_is_shell_safe())
    local buf = {("#compdef %s\n"):format(self._basename)}
    local cmds_buf = {}
    table.insert(buf, "_" .. self._basename .. "() {")
    if #self._commands > 0 then
       table.insert(buf, "  local context state state_descr line")
       table.insert(buf, "  typeset -A opt_args\n")
    end
    self:_zsh_arguments(buf, self._basename, 2)
    self:_zsh_complete_help(buf, cmds_buf, self._basename, 2)
    table.insert(buf, "\n  return 1")
    table.insert(buf, "}")
 
    local result = table.concat(buf, "\n")
    if #cmds_buf > 0 then
       result = result .. "\n" .. table.concat(cmds_buf, "\n")
    end
    return result .. "\n\n_" .. self._basename .. "\n"
 end
 
 local function fish_escape(string)
    return string:gsub("[\\']", "\\%0")
 end
 
 function Parser:_fish_get_cmd(buf, indent)
    if #self._commands == 0 then
       return
    end
 
    table.insert(buf, (" "):rep(indent) .. "set -e cmdline[1]")
    table.insert(buf, (" "):rep(indent) .. "for arg in $cmdline")
    table.insert(buf, (" "):rep(indent + 4) .. "switch $arg")
 
    for _, command in ipairs(self._commands) do
       table.insert(buf, (" "):rep(indent + 8) .. "case " .. table.concat(command._aliases, " "))
       table.insert(buf, (" "):rep(indent + 12) .. "set cmd $cmd " .. command._name)
       command:_fish_get_cmd(buf, indent + 12)
       table.insert(buf, (" "):rep(indent + 12) .. "break")
    end
 
    table.insert(buf, (" "):rep(indent + 4) .. "end")
    table.insert(buf, (" "):rep(indent) .. "end")
 end
 
 function Parser:_fish_complete_help(buf, basename)
    local prefix = "complete -c " .. basename
    table.insert(buf, "")
 
    for _, command in ipairs(self._commands) do
       local aliases = table.concat(command._aliases, " ")
       local line
       if self._parent then
          line = ("%s -n '__fish_%s_using_command %s' -xa '%s'")
             :format(prefix, basename, self:_get_fullname(true), aliases)
       else
          line = ("%s -n '__fish_%s_using_command' -xa '%s'"):format(prefix, basename, aliases)
       end
       if command._description then
          line = ("%s -d '%s'"):format(line, fish_escape(get_short_description(command)))
       end
       table.insert(buf, line)
    end
 
    if self._is_help_command then
       local line = ("%s -n '__fish_%s_using_command %s' -xa '%s'")
          :format(prefix, basename, self:_get_fullname(true), self._parent:_get_commands())
       table.insert(buf, line)
    end
 
    for _, option in ipairs(self._options) do
       local parts = {prefix}
 
       if self._parent then
          table.insert(parts, "-n '__fish_" .. basename .. "_seen_command " .. self:_get_fullname(true) .. "'")
       end
 
       for _, alias in ipairs(option._aliases) do
          if alias:match("^%-.$") then
             table.insert(parts, "-s " .. alias:sub(2))
          elseif alias:match("^%-%-.+") then
             table.insert(parts, "-l " .. alias:sub(3))
          end
       end
 
       if option._choices then
          table.insert(parts, "-xa '" .. table.concat(option._choices, " ") .. "'")
       elseif option._minargs > 0 then
          table.insert(parts, "-r")
       end
 
       if option._description then
          table.insert(parts, "-d '" .. fish_escape(get_short_description(option)) .. "'")
       end
 
       table.insert(buf, table.concat(parts, " "))
    end
 
    for _, command in ipairs(self._commands) do
       command:_fish_complete_help(buf, basename)
    end
 end
 
 function Parser:get_fish_complete()
    self._basename = base_name(self._name)
    assert(self:_is_shell_safe())
    local buf = {}
 
    if #self._commands > 0 then
       table.insert(buf, ([[
 function __fish_%s_print_command
     set -l cmdline (commandline -poc)
     set -l cmd]]):format(self._basename))
       self:_fish_get_cmd(buf, 4)
       table.insert(buf, ([[
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
 end]]):format(self._basename, self._basename, self._basename, self._basename))
    end
 
    self:_fish_complete_help(buf, self._basename)
    return table.concat(buf, "\n") .. "\n"
 end
 
 local function get_tip(context, wrong_name)
    local context_pool = {}
    local possible_name
    local possible_names = {}
 
    for name in pairs(context) do
       if type(name) == "string" then
          for i = 1, #name do
             possible_name = name:sub(1, i - 1) .. name:sub(i + 1)
 
             if not context_pool[possible_name] then
                context_pool[possible_name] = {}
             end
 
             table.insert(context_pool[possible_name], name)
          end
       end
    end
 
    for i = 1, #wrong_name + 1 do
       possible_name = wrong_name:sub(1, i - 1) .. wrong_name:sub(i + 1)
 
       if context[possible_name] then
          possible_names[possible_name] = true
       elseif context_pool[possible_name] then
          for _, name in ipairs(context_pool[possible_name]) do
             possible_names[name] = true
          end
       end
    end
 
    local first = next(possible_names)
 
    if first then
       if next(possible_names, first) then
          local possible_names_arr = {}
 
          for name in pairs(possible_names) do
             table.insert(possible_names_arr, "'" .. name .. "'")
          end
 
          table.sort(possible_names_arr)
          return "\nDid you mean one of these: " .. table.concat(possible_names_arr, " ") .. "?"
       else
          return "\nDid you mean '" .. first .. "'?"
       end
    else
       return ""
    end
 end
 
 local ElementState = class({
    invocations = 0
 })
 
 function ElementState:__call(state, element)
    self.state = state
    self.result = state.result
    self.element = element
    self.target = element._target or element:_get_default_target()
    self.action, self.result[self.target] = element:_get_action()
    return self
 end
 
 function ElementState:error(fmt, ...)
    self.state:error(fmt, ...)
 end
 
 function ElementState:convert(argument, index)
    local converter = self.element._convert
 
    if converter then
       local ok, err
 
       if type(converter) == "function" then
          ok, err = converter(argument)
       elseif type(converter[index]) == "function" then
          ok, err = converter[index](argument)
       else
          ok = converter[argument]
       end
 
       if ok == nil then
          self:error(err and "%s" or "malformed argument '%s'", err or argument)
       end
 
       argument = ok
    end
 
    return argument
 end
 
 function ElementState:default(mode)
    return self.element._defmode:find(mode) and self.element._default
 end
 
 local function bound(noun, min, max, is_max)
    local res = ""
 
    if min ~= max then
       res = "at " .. (is_max and "most" or "least") .. " "
    end
 
    local number = is_max and max or min
    return res .. tostring(number) .. " " .. noun ..  (number == 1 and "" or "s")
 end
 
 function ElementState:set_name(alias)
    self.name = ("%s '%s'"):format(alias and "option" or "argument", alias or self.element._name)
 end
 
 function ElementState:invoke()
    self.open = true
    self.overwrite = false
 
    if self.invocations >= self.element._maxcount then
       if self.element._overwrite then
          self.overwrite = true
       else
          local num_times_repr = bound("time", self.element._mincount, self.element._maxcount, true)
          self:error("%s must be used %s", self.name, num_times_repr)
       end
    else
       self.invocations = self.invocations + 1
    end
 
    self.args = {}
 
    if self.element._maxargs <= 0 then
       self:close()
    end
 
    return self.open
 end
 
 function ElementState:check_choices(argument)
    if self.element._choices then
       for _, choice in ipairs(self.element._choices) do
          if argument == choice then
             return
          end
       end
       local choices_list = "'" .. table.concat(self.element._choices, "', '") .. "'"
       local is_option = getmetatable(self.element) == Option
       self:error("%s%s must be one of %s", is_option and "argument for " or "", self.name, choices_list)
    end
 end
 
 function ElementState:pass(argument)
    self:check_choices(argument)
    argument = self:convert(argument, #self.args + 1)
    table.insert(self.args, argument)
 
    if #self.args >= self.element._maxargs then
       self:close()
    end
 
    return self.open
 end
 
 function ElementState:complete_invocation()
    while #self.args < self.element._minargs do
       self:pass(self.element._default)
    end
 end
 
 function ElementState:close()
    if self.open then
       self.open = false
 
       if #self.args < self.element._minargs then
          if self:default("a") then
             self:complete_invocation()
          else
             if #self.args == 0 then
                if getmetatable(self.element) == Argument then
                   self:error("missing %s", self.name)
                elseif self.element._maxargs == 1 then
                   self:error("%s requires an argument", self.name)
                end
             end
 
             self:error("%s requires %s", self.name, bound("argument", self.element._minargs, self.element._maxargs))
          end
       end
 
       local args
 
       if self.element._maxargs == 0 then
          args = self.args[1]
       elseif self.element._maxargs == 1 then
          if self.element._minargs == 0 and self.element._mincount ~= self.element._maxcount then
             args = self.args
          else
             args = self.args[1]
          end
       else
          args = self.args
       end
 
       self.action(self.result, self.target, args, self.overwrite)
    end
 end
 
 local ParseState = class({
    result = {},
    options = {},
    arguments = {},
    argument_i = 1,
    element_to_mutexes = {},
    mutex_to_element_state = {},
    command_actions = {}
 })
 
 function ParseState:__call(parser, error_handler)
    self.parser = parser
    self.error_handler = error_handler
    self.charset = parser:_update_charset()
    self:switch(parser)
    return self
 end
 
 function ParseState:error(fmt, ...)
    self.error_handler(self.parser, fmt:format(...))
 end
 
 function ParseState:switch(parser)
    self.parser = parser
 
    if parser._action then
       table.insert(self.command_actions, {action = parser._action, name = parser._name})
    end
 
    for _, option in ipairs(parser._options) do
       option = ElementState(self, option)
       table.insert(self.options, option)
 
       for _, alias in ipairs(option.element._aliases) do
          self.options[alias] = option
       end
    end
 
    for _, mutex in ipairs(parser._mutexes) do
       for _, element in ipairs(mutex) do
          if not self.element_to_mutexes[element] then
             self.element_to_mutexes[element] = {}
          end
 
          table.insert(self.element_to_mutexes[element], mutex)
       end
    end
 
    for _, argument in ipairs(parser._arguments) do
       argument = ElementState(self, argument)
       table.insert(self.arguments, argument)
       argument:set_name()
       argument:invoke()
    end
 
    self.handle_options = parser._handle_options
    self.argument = self.arguments[self.argument_i]
    self.commands = parser._commands
 
    for _, command in ipairs(self.commands) do
       for _, alias in ipairs(command._aliases) do
          self.commands[alias] = command
       end
    end
 end
 
 function ParseState:get_option(name)
    local option = self.options[name]
 
    if not option then
       self:error("unknown option '%s'%s", name, get_tip(self.options, name))
    else
       return option
    end
 end
 
 function ParseState:get_command(name)
    local command = self.commands[name]
 
    if not command then
       if #self.commands > 0 then
          self:error("unknown command '%s'%s", name, get_tip(self.commands, name))
       else
          self:error("too many arguments")
       end
    else
       return command
    end
 end
 
 function ParseState:check_mutexes(element_state)
    if self.element_to_mutexes[element_state.element] then
       for _, mutex in ipairs(self.element_to_mutexes[element_state.element]) do
          local used_element_state = self.mutex_to_element_state[mutex]
 
          if used_element_state and used_element_state ~= element_state then
             self:error("%s can not be used together with %s", element_state.name, used_element_state.name)
          else
             self.mutex_to_element_state[mutex] = element_state
          end
       end
    end
 end
 
 function ParseState:invoke(option, name)
    self:close()
    option:set_name(name)
    self:check_mutexes(option, name)
 
    if option:invoke() then
       self.option = option
    end
 end
 
 function ParseState:pass(arg)
    if self.option then
       if not self.option:pass(arg) then
          self.option = nil
       end
    elseif self.argument then
       self:check_mutexes(self.argument)
 
       if not self.argument:pass(arg) then
          self.argument_i = self.argument_i + 1
          self.argument = self.arguments[self.argument_i]
       end
    else
       local command = self:get_command(arg)
       self.result[command._target or command._name] = true
 
       if self.parser._command_target then
          self.result[self.parser._command_target] = command._name
       end
 
       self:switch(command)
    end
 end
 
 function ParseState:close()
    if self.option then
       self.option:close()
       self.option = nil
    end
 end
 
 function ParseState:finalize()
    self:close()
 
    for i = self.argument_i, #self.arguments do
       local argument = self.arguments[i]
       if #argument.args == 0 and argument:default("u") then
          argument:complete_invocation()
       else
          argument:close()
       end
    end
 
    if self.parser._require_command and #self.commands > 0 then
       self:error("a command is required")
    end
 
    for _, option in ipairs(self.options) do
       option.name = option.name or ("option '%s'"):format(option.element._name)
 
       if option.invocations == 0 then
          if option:default("u") then
             option:invoke()
             option:complete_invocation()
             option:close()
          end
       end
 
       local mincount = option.element._mincount
 
       if option.invocations < mincount then
          if option:default("a") then
             while option.invocations < mincount do
                option:invoke()
                option:close()
             end
          elseif option.invocations == 0 then
             self:error("missing %s", option.name)
          else
             self:error("%s must be used %s", option.name, bound("time", mincount, option.element._maxcount))
          end
       end
    end
 
    for i = #self.command_actions, 1, -1 do
       self.command_actions[i].action(self.result, self.command_actions[i].name)
    end
 end
 
 function ParseState:parse(args)
    for _, arg in ipairs(args) do
       local plain = true
 
       if self.handle_options then
          local first = arg:sub(1, 1)
 
          if self.charset[first] then
             if #arg > 1 then
                plain = false
 
                if arg:sub(2, 2) == first then
                   if #arg == 2 then
                      if self.options[arg] then
                         local option = self:get_option(arg)
                         self:invoke(option, arg)
                      else
                         self:close()
                      end
 
                      self.handle_options = false
                   else
                      local equals = arg:find "="
                      if equals then
                         local name = arg:sub(1, equals - 1)
                         local option = self:get_option(name)
 
                         if option.element._maxargs <= 0 then
                            self:error("option '%s' does not take arguments", name)
                         end
 
                         self:invoke(option, name)
                         self:pass(arg:sub(equals + 1))
                      else
                         local option = self:get_option(arg)
                         self:invoke(option, arg)
                      end
                   end
                else
                   for i = 2, #arg do
                      local name = first .. arg:sub(i, i)
                      local option = self:get_option(name)
                      self:invoke(option, name)
 
                      if i ~= #arg and option.element._maxargs > 0 then
                         self:pass(arg:sub(i + 1))
                         break
                      end
                   end
                end
             end
          end
       end
 
       if plain then
          self:pass(arg)
       end
    end
 
    self:finalize()
    return self.result
 end
 
 function Parser:error(msg)
    io.stderr:write(("%s\n\nError: %s\n"):format(self:get_usage(), msg))
    error(nil, 0)
 end
 
 -- Compatibility with strict.lua and other checkers:
 local default_cmdline = rawget(_G, "arg") or {...}
 
 function Parser:_parse(args, error_handler)
    return ParseState(self, error_handler):parse(args or default_cmdline)
 end
 
 function Parser:parse(args)
    return self:_parse(args, self.error)
 end
 
 local function xpcall_error_handler(err)
    return tostring(err) .. "\noriginal " .. debug.traceback("", 2):sub(2)
 end
 
 function Parser:pparse(args)
    local parse_error
 
    local ok, result = xpcall(function()
       return self:_parse(args, function(_, err)
          parse_error = err
          error(err, 0)
       end)
    end, xpcall_error_handler)
 
    if ok then
       return true, result
    elseif not parse_error then
       error(result, 0)
    else
       return false, parse_error
    end
 end
 
 local argparse = {}
 
 argparse.version = "0.7.1"
 
 setmetatable(argparse, {__call = function(_, ...)
    return Parser(default_cmdline[0]):add_help(true)(...)
 end})
 
 return argparse
end
preload["bin/moonc"] = function(...)
rawset(_G, "arg", { ... }) -- compatibility with argparse

-- package.path = "/?;/?.lua;/?/init.lua;/rom/modules/main/?;/rom/modules/main/?.lua;/rom/modules/main/?/init.lua"

local argparse = require "cc.argparse"
local lfs = require "cc.lfs"

local parser = argparse()

parser:flag("-l --lint", "Perform a lint on the file instead of compiling")

parser:flag("-v --version", "Print version")
parser:flag("-w --watch", "Watch file/directory for updates")
parser:option("--transform", "Transform syntax tree with module")

parser:mutex(
  parser:option("-t --output-to", "Specify where to place compiled files"),
  parser:option("-o", "Write output to file"),
  parser:flag("-p", "Write output to standard output"),
  parser:flag("-T", "Write parse tree instead of code (to stdout)"),
  parser:flag("-b", "Write parse and compile time instead of code(to stdout)"),
  parser:flag("-X", "Write line rewrite map instead of code (to stdout)")
)

parser:flag("-",
  "Read from standard in, print to standard out (Must be only argument)")

local read_stdin = _G.arg[1] == "-" -- luacheck: ignore 113

if not read_stdin then
  parser:argument("file/directory"):args("+")
else
  if arg[2] ~= nil then
    io.stderr:write("- must be the only argument\n")
    error(nil, 0)
  end
end

local opts = read_stdin and {} or parser:parse()

if opts.version then
  local v = require "moonscript.version"
  v.print_version()
  error(nil, 0)
end

function log_msg(...)
  if not opts.p then
    io.stderr:write(table.concat({...}, " ") .. "\n")
  end
end

local moonc = require("moonscript.cmd.moonc")
local util = require "moonscript.util"
local normalize_dir = moonc.normalize_dir
local compile_and_write = moonc.compile_and_write
local path_to_target = moonc.path_to_target

local function scan_directory(root, collected)
  root = normalize_dir(root)
  collected = collected or {}

  for fname in lfs.dir(root) do
    if not fname:match("^%.") then
      local full_path = root..fname

      if lfs.attributes(full_path, "mode") == "directory" then
        scan_directory(full_path, collected)
      elseif fname:match("%.moon$") then
        table.insert(collected, full_path)
      end
    end
  end

  return collected
end

local function remove_dups(tbl, key_fn)
  local hash = {}
  local final = {}

  for _, v in ipairs(tbl) do
    local dup_key = key_fn and key_fn(v) or v
    if not hash[dup_key] then
      table.insert(final, v)
      hash[dup_key] = true
    end
  end

  return final
end

-- creates tuples of input and target
local function get_files(fname, files)
  files = files or {}

  if lfs.attributes(fname, "mode") == "directory" then
    for _, sub_fname in ipairs(scan_directory(fname)) do
      table.insert(files, {
        sub_fname,
        path_to_target(sub_fname, opts.output_to, fname)
      })
    end
  else
    table.insert(files, {
      fname,
      path_to_target(fname, opts.output_to)
    })
  end

  return files
end

if read_stdin then
  local parse = require "moonscript.parse"
  local compile = require "moonscript.compile"

  local text = io.stdin:read("*a")
  local tree, err = parse.string(text)

  if not tree then error(err) end
  local code, err, pos = compile.tree(tree)

  if not code then
    error(compile.format_error(err, pos, text))
  end

  print(code)
  error(nil, 0)
end

local inputs = opts["file/directory"]

local files = {}
for _, input in ipairs(inputs) do
  get_files(input, files)
end

files = remove_dups(files, function(f)
  return f[2]
end)

-- returns an iterator that returns files that have been updated
local function create_watcher(files)
  local watchers = require("moonscript.cmd.watchers")

  if watchers.InotifyWacher:available() then
    return watchers.InotifyWacher(files):each_update()
  end

  return watchers.SleepWatcher(files):each_update()
end

if opts.watch then
  -- build function to check for lint or compile in watch
  local handle_file
  if opts.lint then
    local lint = require "moonscript.cmd.lint"
    handle_file = lint.lint_file
  else
    handle_file = compile_and_write
  end

  local watcher = create_watcher(files)
  -- catches interrupt error for ctl-c
  local protected = function()
    local status, file = true, watcher()
    if status then
      return file
    elseif file ~= "interrupted!" then
      error(file)
    end
  end

  for fname in protected do
    local target = path_to_target(fname, opts.t)

    if opts.o then
      target = opts.o
    end

    local success, err = handle_file(fname, target)
    if opts.lint then
      if success then
        io.stderr:write(success .. "\n\n")
      elseif err then
        io.stderr:write(fname .. "\n" .. err .. "\n\n")
      end
    elseif not success then
      io.stderr:write(table.concat({
        "",
        "Error: " .. fname,
        err,
        "\n",
      }, "\n"))
    elseif success == "build" then
      log_msg("Built", fname, "->", target)
    end
  end

  io.stderr:write("\nQuitting...\n")
elseif opts.lint then
  local has_linted_with_error;
  local lint = require "moonscript.cmd.lint"
  for _, tuple in pairs(files) do
    local fname = tuple[1]
    local res, err = lint.lint_file(fname)
    if res then
      has_linted_with_error = true
      io.stderr:write(res .. "\n\n")
    elseif err then
      has_linted_with_error = true
      io.stderr:write(fname .. "\n" .. err.. "\n\n")
    end
  end
  if has_linted_with_error then
    error(nil, 0)
  end
else
  for _, tuple in ipairs(files) do
    local fname, target = util.unpack(tuple)
    if opts.o then
      target = opts.o
    end

    local success, err = compile_and_write(fname, target, {
      print = opts.p,
      fname = fname,
      benchmark = opts.b,
      show_posmap = opts.X,
      show_parse_tree = opts.T,
      transform_module = opts.transform
    })

    if not success then
      io.stderr:write(fname .. "\t" .. err .. "\n")
      error(nil, 0)
    end
  end
end


end
return preload["bin/moonc"](...)
