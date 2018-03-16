# Behave

A simple implementation of behavior trees in MoonScript / Lua. Define behaviors
as functions or small tables, then call `behave.make` on them to get a function
you can call repeatedly to execute behaviors.

A node should return a truthy or falsy value to indicate success or failure, or
`behave.running` to indicate that the node needs to be called again to continue
running.

Examples are in MoonScript, but shouldn't be too difficult to understand even if
you are unfamiliar with its syntax.

## Example

```
TODO
```

## Leaf Nodes

The easiest node is just a function that will be passed all arguments sent to a
behavior tree it is part of. There is a slightly more complex leaf node for
maintaining an internal state, and optional `start`/`finish` functions only
called at the beginning and end of processing.

```
WalkPath = {
  start: (state, entity) ->
    state.path = findPath(entity, entity.target)
    return state.path
  run: (state, entity) ->
    -- this will not run if start fails
    state.path.step!
  finish: (state, entity) ->
    -- this will run only if run returns a truthy value besides behave.running
    state.path = nil
}
```

## The Decorator Node

A very basic extension to the result of a leaf node, allowing you to alter the
result it returns. Note: You cannot alter a `behave.running` return.

```
InvertSomeNode = {
  decorator: (result) ->
    return not result
  SomeNode
}
```

## Composite Nodes

Selector skips any failures and returns on the first node that returns a truthy
value (or returns `false` if nothing succeeds). Sequence continues until there
is a failure or returns success. Random executes a random node underneath it.

```
Behaviors = {
  type: behave.Random
  WalkRandomly, LookAtPhone, LeaveArea
}
```

## Custom Nodes

You can create custom nodes and easily use them. Rather than explaining how to,
here's an example:

```
-- defining the node type:
Invert = (tab) ->                   -- your fn will be passed a table describing the node
  node = behave.make tab[1]         -- call make on any sub-nodes that you will be using, save the result
  return (...) ->                   -- use variable arguments, so sub-nodes can
    result = node(...)              -- get what they need
    unless result == behave.running -- running nodes should not be interrupted
      result = not result           -- and finally we invert the result before
    return result                   -- returning it

-- using the node type:
SomeInvertedNode = {
  type: Invert       -- this is how the library knows what function to call
  SomeNode           -- this is the node that will be inverted
}
```
