local success = setmetatable({ }, {
  __tostring = function()
    return "success"
  end
})
local running = setmetatable({ }, {
  __tostring = function()
    return "running"
  end
})
local fail = setmetatable({ }, {
  __tostring = function()
    return "fail"
  end
})
local Node
do
  local _class_0
  local _base_0 = {
    addObject = function(self, obj)
      obj[self.u] = {
        started = false
      }
    end,
    run = function(self)
      return success
    end,
    update = function(self, obj, ...)
      local result = success
      if not obj[self.u].started and self.start then
        result = self:start(obj, ...)
        obj[self.u].started = true
      end
      if result == success then
        result = self:run(obj, ...)
      end
      if result == success then
        if self.finish then
          result = self:finish(obj, ...)
        end
        obj[self.u].started = false
      end
      return result
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, fns)
      if fns == nil then
        fns = { }
      end
      for key, value in pairs(fns) do
        self[key] = value
      end
      self.success = success
      self.running = running
      self.fail = fail
      self.u = { }
    end,
    __base = _base_0,
    __name = "Node"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Node = _class_0
end
local Composite
do
  local _class_0
  local _parent_0 = Node
  local _base_0 = {
    addObject = function(self, obj)
      local _list_0 = self.nodes
      for _index_0 = 1, #_list_0 do
        local node = _list_0[_index_0]
        node:addObject(obj)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, nodes)
      if nodes == nil then
        nodes = { }
      end
      self.nodes = nodes
      return _class_0.__parent.__init(self)
    end,
    __base = _base_0,
    __name = "Composite",
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
  Composite = _class_0
end
local Sequence
do
  local _class_0
  local _parent_0 = Composite
  local _base_0 = {
    addObject = function(self, obj)
      _class_0.__parent.__base.addObject(self)
      obj[self.u] = {
        index = 0,
        running = 0
      }
    end,
    update = function(self, obj, ...)
      local result = success
      if obj[self.u].running then
        result = obj[self.u].running:update(obj, ...)
        if not (result == running) then
          obj[self.u].running = false
        end
      end
      while result == success and obj[self.u].index < #self.nodes do
        obj[self.u].index = obj[self.u].index + 1
        result = self.nodes[obj[self.u].index]:update(obj, ...)
      end
      if result == running then
        obj[self.u].running = self.nodes[obj[self.u].index]
      else
        obj[self.u].index = 0
      end
      return result
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Sequence",
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
  Sequence = _class_0
end
local Selector
do
  local _class_0
  local _parent_0 = Composite
  local _base_0 = {
    addObject = function(self, obj)
      _class_0.__parent.__base.addObject(self)
      obj[self.u] = {
        index = 0,
        running = 0
      }
    end,
    update = function(self, obj, ...)
      local result = fail
      if obj[self.u].running then
        result = obj[self.u].running:update(obj, ...)
        if not (result == running) then
          obj[self.u].running = false
        end
      end
      while result == fail and obj[self.u].index < #self.nodes do
        obj[self.u].index = obj[self.u].index + 1
        result = self.nodes[obj[self.u].index]:update(obj, ...)
      end
      if result == running then
        obj[self.u].running = self.nodes[obj[self.u].index]
      else
        obj[self.u].index = 0
      end
      return result
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Selector",
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
  Selector = _class_0
end
local Random
do
  local _class_0
  local _parent_0 = Composite
  local _base_0 = {
    update = function(self, obj, ...)
      local index = math.floor(math.random() * #self.nodes + 1)
      return self.nodes[index]:update(obj, ...)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Random",
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
  Random = _class_0
end
local Randomizer
do
  local _class_0
  local _parent_0 = Composite
  local _base_0 = {
    addObject = function(self, obj)
      _class_0.__parent.__base.addObject(self)
      obj[self.u] = {
        running = false
      }
      return self:shuffle(obj)
    end,
    shuffle = function(self, obj)
      obj[self.u].shuffledNodes = { }
      for i = 1, #self.nodes do
        local r = math.random(i)
        if not (r == i) then
          obj[self.u].shuffledNodes[i] = obj[self.u].shuffledNodes[r]
        end
        obj[self.u].shuffledNodes[r] = self.nodes[i]
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Randomizer",
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
  Randomizer = _class_0
end
local RandomSequence
do
  local _class_0
  local _parent_0 = Randomizer
  local _base_0 = {
    update = function(self, obj, ...)
      local result = success
      if obj[self.u].running then
        result = obj[self.u].running:update(obj, ...)
        if not (result == running) then
          obj[self.u].running = false
        end
      end
      local tmp
      while result == success and #obj[self.u].shuffledNodes > 0 do
        result = obj[self.u].shuffledNodes[1]:update(obj, ...)
        tmp = table.remove(obj[self.u].shuffledNodes, 1)
      end
      if result == running then
        obj[self.u].running = tmp
      else
        self:shuffle(obj)
      end
      return result
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "RandomSequence",
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
  RandomSequence = _class_0
end
local RandomSelector
do
  local _class_0
  local _parent_0 = Randomizer
  local _base_0 = {
    update = function(self, obj, ...)
      local result = fail
      if obj[self.u].running then
        result = obj[self.u].running:update(obj, ...)
        if not (result == running) then
          obj[self.u].running = false
        end
      end
      local tmp
      while result == fail and #obj[self.u].shuffledNodes > 0 do
        result = obj[self.u].shuffledNodes[1]:update(obj, ...)
        tmp = table.remove(obj[self.u].shuffledNodes, 1)
      end
      if result == running then
        obj[self.u].running = tmp
      else
        self:shuffle()
      end
      return result
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "RandomSelector",
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
  RandomSelector = _class_0
end
local Decorator
do
  local _class_0
  local _parent_0 = Node
  local _base_0 = {
    addObject = function(self, obj)
      return self.node:addObject(obj)
    end,
    update = function(self, obj, ...)
      return self.node:update(obj, ...)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, node)
      if node == nil then
        node = Node()
      end
      self.node = node
      return _class_0.__parent.__init(self)
    end,
    __base = _base_0,
    __name = "Decorator",
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
  Decorator = _class_0
end
local Repeat
do
  local _class_0
  local _parent_0 = Decorator
  local _base_0 = {
    addObject = function(self, obj)
      _class_0.__parent.__base.addObject(self)
      obj[self.u] = {
        counter = 1,
        running = false
      }
    end,
    update = function(self, obj, ...)
      local result = success
      if obj[self.u].running then
        result = self.node:update(obj, ...)
        if not (result == running) then
          obj[self.u].running = false
        end
      end
      while result == success and obj[self.u].counter < self.cycles do
        obj[self.u].counter = obj[self.u].counter + 1
        result = self.node:update(obj, ...)
      end
      if result == running then
        obj[self.u].running = true
      else
        obj[self.u].counter = 1
      end
      return result
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, cycles, node)
      if cycles == nil then
        cycles = 2
      end
      if node == nil then
        node = Node()
      end
      self.cycles, self.node = cycles, node
      return _class_0.__parent.__init(self, self.node)
    end,
    __base = _base_0,
    __name = "Repeat",
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
  Repeat = _class_0
end
local Succeed
do
  local _class_0
  local _parent_0 = Decorator
  local _base_0 = {
    update = function(self, obj, ...)
      if running == self.node:update(obj, ...) then
        return running
      else
        return success
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Succeed",
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
  Succeed = _class_0
end
local Fail
do
  local _class_0
  local _parent_0 = Decorator
  local _base_0 = {
    update = function(self, obj, ...)
      if running == self.node:update(obj, ...) then
        return running
      else
        return fail
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Fail",
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
  Fail = _class_0
end
local Invert
do
  local _class_0
  local _parent_0 = Decorator
  local _base_0 = {
    update = function(self, obj, ...)
      local result = self.node:update(obj, ...)
      if result == running then
        return running
      elseif result == success then
        return fail
      else
        return success
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Invert",
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
  Invert = _class_0
end
local RunOnce
do
  local _class_0
  local _parent_0 = Decorator
  local _base_0 = {
    addObject = function(self, obj)
      obj[self.u] = {
        ran = false
      }
    end,
    update = function(self, obj, ...)
      if not (obj[self.u].ran) then
        local result = self.node:update(obj, ...)
        if not (result == running) then
          obj[self.u].ran = true
        end
        return result
      else
        return fail
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "RunOnce",
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
  RunOnce = _class_0
end
local Class
Class = function(name, parent)
  local newClass, base
  base = {
    __index = base,
    __class = newClass
  }
  newClass = setmetatable({
    __init = function() end,
    __base = base,
    __name = name
  }, {
    __call = function(cls, ...)
      local self = setmetatable({ }, base)
      cls.__init(self, ...)
      return self
    end
  })
  if parent then
    setmetatable(base, {
      __parent = parent.__base
    })
    newClass.__parent = parent
    newClass.__index = function(cls, name)
      local val = rawget(base, name)
      if val == nil then
        return parent[name]
      else
        return val
      end
    end
    if parent.__inherited then
      parent:__inherited(newClass)
    end
  end
  return newClass, base
end
return setmetatable({
  Node = Node,
  Sequence = Sequence,
  Selector = Selector,
  Random = Random,
  RandomSequence = RandomSequence,
  RandomSelector = RandomSelector,
  Decorator = Decorator,
  Repeat = Repeat,
  Succeed = Succeed,
  Fail = Fail,
  Invert = Invert,
  RunOnce = RunOnce,
  success = success,
  running = running,
  fail = fail,
  Class = Class
}, {
  __call = function(bt, ...)
    return bt.Sequence(...)
  end
})
