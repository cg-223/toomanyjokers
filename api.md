Implementing support for TMJ:
TMJ.SEARCH_FIELD_FUNCS contains functions that take a center and return a string that can be indexed by TMJ.

Example:
```lua
for i, v in pairs(G.P_CENTERS) do
    v.ilove = "you"
end
table.insert(TMJ.SEARCH_FIELD_FUNCS, function(center)
    return v.ilove
end)
```

Alternatively, if your mod adds multiple things to search for, you can do this.
```lua
for i, v in pairs(G.P_CENTERS) do
    v.thing1 = "one"
    v.thing2 = "two"
end
table.insert(TMJ.SEARCH_FIELD_FUNCS, function(center)
    return {v.thing1, v.thing2}
end)
```

This is equivalent to
```lua
for i, v in pairs(G.P_CENTERS) do
    v.thing1 = "one"
    v.thing2 = "two"
end
table.insert(TMJ.SEARCH_FIELD_FUNCS, function(center)
    return v.thing1
end)
table.insert(TMJ.SEARCH_FIELD_FUNCS, function(center)
    return v.thing2
end)
```
