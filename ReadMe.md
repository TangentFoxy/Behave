# Behave

A simple implementation of behavior trees in MoonScript / Lua.

## Example

(Note: The top example and last example work. The others are from experimenting
with ideas about how to make it easier to write code interfacing with this
library.)

```
bt = require "behave"

tree = bt.Sequence({
  bt.Node({
    run = function(self)
      -- do stuff
    end,
    finish = function(self)
      -- finish up
    end
  }),
  bt.Random({
    bt.Node({
      -- add some functions
    }),
    bt.Node({
      -- even more functionality!
    })
  })
})

node1 = {
  -- pretend this has run/finish functions or whatever
}
node2 = {} -- same
bt.Make ({
  "Sequence",
  node1, node2, {
    "Random",
    node3, node4 -- these are in 'Random'
  }
})

tree = bt.Factory({
  "Sequence",
  {
    "Node",
    {
      run = function(self) end,
      finish = function(self) end
    }
  }
})

node1 = bt.Node()
function node1:run()
  -- do stuff!
end
```

## The Leaf Node

`Node` accepts a table of values to be set on it. It expects a `run` function,
and optionally a `start` and a `finish` function, which will only be run at the
beginning and end of a node being run (whereas `run` can be called multiple
times).

To run a behavior tree, call `update` on itself, with optional arguments (which
will be passed to their children as they are called).

## Composite Nodes

Pass a table of nodes to these to set their contents. All composite nodes repeat
after the entire tree has been processed.

- Sequence: Runs children until a failure or success of all.
- Selector: Runs children until a success or failure of all.
- Random: Runs a random child and returns its result.
- RandomSequence: Randomizes the order of its children, then acts like a
  Sequence.
- RandomSelector: Randomizes the order of its children, then acts like a
  Selector.

## Decorator Nodes

Pass a single node to these, except for `Repeat`, which needs a number followed
by a node. All decorator nodes (except `RunOnce`) repeat after the entire tree
has been processed.

- Repeat: Repeats a node a specified number of times, fails if the node fails.
- Decorator: Does nothing except return the result of its child node.
- Succeed: Runs a node and returns success.
- Fail: Runs a node and returns failure.
- Invert: Runs a node, reporting a success on fail, and failure on success.
- RunOnce: Runs a node, reporting its results, and fail after that.

## Return Values

Within the module, `success`, `running`, and `fail` are defined. They are also
present on all nodes (so you can use `self.success` and such).
