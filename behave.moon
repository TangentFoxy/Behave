success = setmetatable({}, {__tostring: -> return "success"})
running = setmetatable({}, {__tostring: -> return "running"})
fail =    setmetatable({}, {__tostring: -> return "fail"})

class Node
  new: (fns={}) =>
    for key, value in pairs fns
      @[key] = value

    @success = success
    @running = running
    @fail = fail

    @u = {}

  addObject: (obj) =>
    obj[@u] = {
      started: false
    }

  run: =>
    return success

  update: (obj, ...) =>
    result = success
    if not obj[@u].started and @start
      result = @\start obj, ...
      obj[@u].started = true
    if result == success
      result = @\run obj, ...
    if result == success
      result = @\finish(obj, ...) if @finish
      obj[@u].started = false
    return result

class Composite extends Node
  new: (@nodes={}) =>
    super!

  addObject: (obj) =>
    for node in *@nodes
      node\addObject obj

-- Runs children in order until one returns fail, or all succeed.
class Sequence extends Composite
  addObject: (obj) =>
    super!
    obj[@u] = {
      index: 0
      running: 0
    }

  update: (obj, ...) =>
    result = success

    if obj[@u].running
      result = obj[@u].running\update obj, ...
      unless result == running
        obj[@u].running = false

    while result == success and obj[@u].index < #@nodes
      obj[@u].index += 1
      result = @nodes[obj[@u].index]\update obj, ...

    if result == running
      obj[@u].running = @nodes[obj[@u].index]
    else
      obj[@u].index = 0

    return result

-- Runs children in order until one succeeds or all fail.
class Selector extends Composite
  addObject: (obj) =>
    super!
    obj[@u] = {
      index: 0
      running: 0
    }

  update: (obj, ...) =>
    result = fail
    if obj[@u].running
      result = obj[@u].running\update obj, ...
      unless result == running
        obj[@u].running = false

    while result == fail and obj[@u].index < #@nodes
      obj[@u].index += 1
      result = @nodes[obj[@u].index]\update obj, ...

    if result == running
      obj[@u].running = @nodes[obj[@u].index]
    else
      obj[@u].index = 0

    return result

-- Runs a random child.
class Random extends Composite
  update: (obj, ...) =>
    index = math.floor math.random! * #@nodes + 1
    return @nodes[index]\update obj, ...

class Randomizer extends Composite
  addObject: (obj) =>
    super!
    obj[@u] = {
      running: false
    }
    @shuffle obj

  shuffle: (obj) =>
    obj[@u].shuffledNodes = {}
    for i = 1, #@nodes
      r = math.random i
      unless r == i
        obj[@u].shuffledNodes[i] = obj[@u].shuffledNodes[r]
      obj[@u].shuffledNodes[r] = @nodes[i]

-- Randomizes order of nodes in between complete runs of them as a Sequence.
class RandomSequence extends Randomizer
  update: (obj, ...) =>
    result = success

    if obj[@u].running
      result = obj[@u].running\update obj, ...
      unless result == running
        obj[@u].running = false

    local tmp
    while result == success and #obj[@u].shuffledNodes > 0
      result = obj[@u].shuffledNodes[1]\update obj, ...
      tmp = table.remove obj[@u].shuffledNodes, 1

    if result == running
      obj[@u].running = tmp
    else
      @shuffle obj

    return result

-- Randomizes order of nodes in between complete runs of them as a Selector.
class RandomSelector extends Randomizer
  update: (obj, ...) =>
    result = fail

    if obj[@u].running
      result = obj[@u].running\update obj, ...
      unless result == running
        obj[@u].running = false

    local tmp
    while result == fail and #obj[@u].shuffledNodes > 0
      result = obj[@u].shuffledNodes[1]\update obj, ...
      tmp = table.remove obj[@u].shuffledNodes, 1

    if result == running
      obj[@u].running = tmp
    else
      @shuffle!

    return result

class Decorator extends Node
  new: (@node=Node!) =>
    super!

  addObject: (obj) =>
    @node\addObject obj

  update: (obj, ...) =>
    return @node\update obj, ...

-- Repeats a node a specified number of times, unless it fails.
class Repeat extends Decorator
  new: (@cycles=2, @node=Node!) =>
    super @node

  addObject: (obj) =>
    super!
    obj[@u] = {
      counter: 1
      running: false
    }

  update: (obj, ...) =>
    result = success

    if obj[@u].running
      result = @node\update obj, ...
      unless result == running
        obj[@u].running = false

    while result == success and obj[@u].counter < @cycles
      obj[@u].counter += 1
      result = @node\update obj, ...

    if result == running
      obj[@u].running = true
    else
      obj[@u].counter = 1

    return result

-- Returns success whether or not the node succeeds.
class Succeed extends Decorator
  update: (obj, ...) =>
    if running == @node\update obj, ...
      return running
    else
      return success

-- Returns fail whether or not the node fails.
class Fail extends Decorator
  update: (obj, ...) =>
    if running == @node\update obj, ...
      return running
    else
      return fail

-- Returns success when the node fails, and failure on success.
class Invert extends Decorator
  update: (obj, ...) =>
    result = @node\update obj, ...
    if result == running
      return running
    elseif result == success
      return fail
    else
      return success

-- Only runs children once, and returns fail from then on.
class RunOnce extends Decorator
  addObject: (obj) =>
    obj[@u] = {
      ran: false
    }

  update: (obj, ...) =>
    unless obj[@u].ran
      result = @node\update obj, ...
      unless result == running
        obj[@u].ran = true
      return result
    else
      return fail

-- A MoonScript-compatible class implementation for creating your own classes.
Class = (name, parent) ->
  local newClass, base
  base = {
    __index: base
    __class: newClass
  }

  newClass = setmetatable {
    __init: ->
    __base: base
    __name: name
  }, {
    __call: (cls, ...) ->
      @ = setmetatable({}, base)
      cls.__init(@, ...)
      return @
  }

  if parent
    setmetatable base, {
      __parent: parent.__base
    }

    newClass.__parent = parent
    newClass.__index = (cls, name) ->
      val = rawget(base, name)
      if val == nil
        return parent[name]
      else
        return val

    if parent.__inherited
      parent\__inherited newClass

  return newClass, base

setmetatable {
  -- Leaf Node
  :Node

  -- Composite Nodes
  :Composite
  :Sequence
  :Selector
  :Random
  :RandomSequence
  :RandomSelector

  -- Decorator Nodes
  :Decorator
  :Repeat
  :Succeed
  :Fail
  :Invert
  :RunOnce

  -- Return Values
  :success
  :running
  :fail

  -- Utility Fns
  :Class
}, {
  __call: (bt, ...) ->
    bt.Sequence ...
}
