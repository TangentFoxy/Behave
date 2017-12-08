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

    @started = false

  run: =>
    return success

  update: (...) =>
    result = success
    if not @started and @start
      result = @\start ...
      @started = true
    if result == success
      result = @\run ...
    if result == success
      result = @\finish(...) if @finish
      @started = false
    return result

-- Runs children in order until one returns fail, or all succeed.
class Sequence extends Node
  new: (@nodes={}) =>
    super!

    @index = 0
    @_running = false

  update: (...) =>
    result = success

    if @_running
      result = @_running\update ...
      unless result == running
        @_running = false

    while result == success and @index < #@nodes
      @index += 1
      result = @nodes[@index]\update ...

    if result == running
      @_running = @nodes[@index]
    else
      @index = 0

    return result

-- Runs children in order until one succeeds or all fail.
class Selector extends Node
  new: (@nodes={}) =>
    super!

    @index = 0
    @_running = false

  update: (...) =>
    result = fail
    if @_running
      result = @_running\update ...
      unless result == running
        @_running = false

    while result == fail and @index < #@nodes
      @index += 1
      result = @nodes[@index]\update ...

    if result == running
      @_running = @nodes[@index]
    else
      @index = 0

    return result

-- Runs a random child.
class Random extends Node
  new: (@nodes={}) =>
    super!

  update: (...) =>
    index = math.floor math.random! * #@nodes + 1
    return @nodes[index]\update ...

-- Randomizes order of nodes in between complete runs of them as a Sequence.
class RandomSequence extends Node
  new: (@nodes={}) =>
    super!

    @_running = false
    @shuffle!

  shuffle: =>
    @_shuffled = {}
    for i = 1, #@nodes
      r = math.random i
      unless r == i
        @_shuffled[i] = @_shuffled[r]
      @_shuffled[r] = @nodes[i]

  update: (...) =>
    result = success

    if @_running
      result = @_running\update ...
      unless result == running
        @_running = false

    local tmp
    while result == success and #@_shuffled > 0
      result = @_shuffled[1]\update ...
      tmp = table.remove @_shuffled, 1

    if result == running
      @_running = tmp
    else
      @shuffle!

    return result

-- Randomizes order of nodes in between complete runs of them as a Selector.
class RandomSelector extends Node
  new: (@nodes={}) =>
    super!

    @_running = false
    @shuffle!

  shuffle: =>
    @_shuffled = {}
    for i = 1, #@nodes
      r = math.random i
      unless r == i
        @_shuffled[i] = @_shuffled[r]
      @_shuffled[r] = @nodes[i]

  update: (...) =>
    result = fail

    if @_running
      result = @_running\update ...
      unless result == running
        @_running = false

    local tmp
    while result == fail and #@_shuffled > 0
      result = @_shuffled[1]\update ...
      tmp = table.remove @_shuffled, 1

    if result == running
      @_running = tmp
    else
      @shuffle!

    return result

-- Repeats a node a specified number of times, unless it fails.
class Repeat extends Node
  new: (@cycles=2, @node=Node!) =>
    super!

    @counter = 1
    @_running = false

  update: (...) =>
    result = success

    if @_running
      result = @node\update ...
      unless result == running
        @_running = false

    while result == success and @counter < @cycles
      @counter += 1
      result = @node\update ...

    if result == running
      @_running = true
    else
      @counter = 1

    return result

-- Returns success whether or not the node succeeds.
class Succeed extends Node
  new: (@node=Node!) =>
    super!

  update: (...) =>
    if running == @node\update ...
      return running
    else
      return success

-- Returns fail whether or not the node fails.
class Fail extends Node
  new: (@node=Node!) =>
    super!

  update: (...) =>
    if running == @node\update ...
      return running
    else
      return fail

-- Returns success when the node fails, and failure on success.
class Invert extends Node
  new: (@node=Node!) =>
    super!

  update: (...) =>
    result = @node\update ...
    if result == running
      return running
    elseif result == success
      return fail
    else
      return success

-- Only runs children once, and returns fail from then on.
class RunOnce extends Node
  new: (@node=Node!) =>
    super!

    @ran = false

  update: (...) =>
    unless @ran
      result = @node\update ...
      unless result == running
        @run = true
      return result
    else
      return fail

behave = {
  -- Leaf Node
  :Node

  -- Composite Nodes
  :Sequence
  :Selector
  :Random
  :RandomSequence
  :RandomSelector

  -- Decorator Nodes
  :Repeat
  :Succeed
  :Fail
  :Invert
  :RunOnce

  -- Return Values
  :success
  :running
  :fail
}

behave.clone = (object) ->
  local new
  cls = getmetatable(object).__class.__name

  if cls == "Repeat"
    new = behave[cls] object.cycles, object
  else
    new = behave[cls] object

  if object.nodes
    nodes = {}
    for k,v in pairs object.nodes
      nodes[k] = behave.clone v
    new.nodes = nodes
  elseif object.node
    new.node = behave.clone object.node

  return new

return behave
