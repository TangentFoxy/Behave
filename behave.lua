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
    run = function(self)
      return success
    end,
    update = function(self, ...)
      local result = success
      if not self.started and self.start then
        result = self:start(...)
        self.started = true
      end
      if result == success then
        result = self:run(...)
      end
      if result == success then
        if self.finish then
          result = self:finish(...)
        end
        self.started = false
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
      self.started = false
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
local Sequence
do
  local _class_0
  local _parent_0 = Node
  local _base_0 = {
    update = function(self, ...)
      local result = success
      if self._running then
        result = self._running:update(...)
        if not (result == running) then
          self._running = false
        end
      end
      while result == success and self.index < #self.nodes do
        self.index = self.index + 1
        result = self.nodes[self.index]:update(...)
      end
      if result == running then
        self._running = self.nodes[self.index]
      else
        self.index = 0
      end
      return result
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
      _class_0.__parent.__init(self)
      self.index = 0
      self._running = false
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
  local _parent_0 = Node
  local _base_0 = {
    update = function(self, ...)
      local result = fail
      if self._running then
        result = self._running:update(...)
        if not (result == running) then
          self._running = false
        end
      end
      while result == fail and self.index < #self.nodes do
        self.index = self.index + 1
        result = self.nodes[self.index]:update(...)
      end
      if result == running then
        self._running = self.nodes[self.index]
      else
        self.index = 0
      end
      return result
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
      _class_0.__parent.__init(self)
      self.index = 0
      self._running = false
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
  local _parent_0 = Node
  local _base_0 = {
    update = function(self, ...)
      local index = math.floor(math.random() * #self.nodes + 1)
      return self.nodes[index]:update(...)
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
local RandomSequence
do
  local _class_0
  local _parent_0 = Node
  local _base_0 = {
    shuffle = function(self)
      self._shuffled = { }
      for i = 1, #self.nodes do
        local r = math.random(i)
        if not (r == i) then
          self._shuffled[i] = self._shuffled[r]
        end
        self._shuffled[r] = self.nodes[i]
      end
    end,
    update = function(self, ...)
      local result = success
      if self._running then
        result = self._running:update(...)
        if not (result == running) then
          self._running = false
        end
      end
      local tmp
      while result == success and #self._shuffled > 0 do
        result = self._shuffled[1]:update(...)
        tmp = table.remove(self._shuffled, 1)
      end
      if result == running then
        self._running = tmp
      else
        self:shuffle()
      end
      return result
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
      _class_0.__parent.__init(self)
      self._running = false
      return self:shuffle()
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
  local _parent_0 = Node
  local _base_0 = {
    shuffle = function(self)
      self._shuffled = { }
      for i = 1, #self.nodes do
        local r = math.random(i)
        if not (r == i) then
          self._shuffled[i] = self._shuffled[r]
        end
        self._shuffled[r] = self.nodes[i]
      end
    end,
    update = function(self, ...)
      local result = fail
      if self._running then
        result = self._running:update(...)
        if not (result == running) then
          self._running = false
        end
      end
      local tmp
      while result == fail and #self._shuffled > 0 do
        result = self._shuffled[1]:update(...)
        tmp = table.remove(self._shuffled, 1)
      end
      if result == running then
        self._running = tmp
      else
        self:shuffle()
      end
      return result
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
      _class_0.__parent.__init(self)
      self._running = false
      return self:shuffle()
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
local Repeat
do
  local _class_0
  local _parent_0 = Node
  local _base_0 = {
    update = function(self, ...)
      local result = success
      if self._running then
        result = self.node:update(...)
        if not (result == running) then
          self._running = false
        end
      end
      while result == success and self.counter < self.cycles do
        self.counter = self.counter + 1
        result = self.node:update(...)
      end
      if result == running then
        self._running = true
      else
        self.counter = 1
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
      _class_0.__parent.__init(self)
      self.counter = 1
      self._running = false
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
  local _parent_0 = Node
  local _base_0 = {
    update = function(self, ...)
      if running == self.node:update(...) then
        return running
      else
        return success
      end
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
  local _parent_0 = Node
  local _base_0 = {
    update = function(self, ...)
      if running == self.node:update(...) then
        return running
      else
        return fail
      end
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
  local _parent_0 = Node
  local _base_0 = {
    update = function(self, ...)
      local result = self.node:update(...)
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
    __init = function(self, node)
      if node == nil then
        node = Node()
      end
      self.node = node
      return _class_0.__parent.__init(self)
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
  local _parent_0 = Node
  local _base_0 = {
    update = function(self, ...)
      if not (self.ran) then
        local result = self.node:update(...)
        if not (result == running) then
          self.run = true
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
    __init = function(self, node)
      if node == nil then
        node = Node()
      end
      self.node = node
      _class_0.__parent.__init(self)
      self.ran = false
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
local behave = {
  Node = Node,
  Sequence = Sequence,
  Selector = Selector,
  Random = Random,
  RandomSequence = RandomSequence,
  RandomSelector = RandomSelector,
  Repeat = Repeat,
  Succeed = Succeed,
  Fail = Fail,
  Invert = Invert,
  RunOnce = RunOnce,
  success = success,
  running = running,
  fail = fail
}
behave.clone = function(object)
  local cls = getmetatable(object).__class.__name
  local new = behave[cls](object)
  if object.nodes then
    local nodes = { }
    for k, v in pairs(object.nodes) do
      nodes[k] = behave.clone(v)
    end
    new.nodes = nodes
  elseif object.node then
    new.node = behave.clone(object.node)
  end
  return new
end
return behave
