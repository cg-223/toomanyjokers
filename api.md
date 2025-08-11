Implementing support for TMJ:
TMJ.SEARCH_FIELD_FUNCS contains functions that take a center and return a string that can be indexed by TMJ.

Example:
```lua
for i, v in pairs(G.P_CENTERS) do
    center.ilove = "you"
end
table.insert(TMJ.SEARCH_FIELD_FUNCS, function(center)
    return center.ilove
end)
```

Alternatively, if your mod adds multiple things to search for, you can do this.
```lua
for i, v in pairs(G.P_CENTERS) do
    center.thing1 = "one"
    center.thing2 = "two"
end
table.insert(TMJ.SEARCH_FIELD_FUNCS, function(center)
    return {center.thing1, center.thing2}
end)
```

This is equivalent to
```lua
for i, v in pairs(G.P_CENTERS) do
    center.thing1 = "one"
    center.thing2 = "two"
end
table.insert(TMJ.SEARCH_FIELD_FUNCS, function(center)
    return center.thing1
end)
table.insert(TMJ.SEARCH_FIELD_FUNCS, function(center)
    return center.thing2
end)
```

Now if I search "two" in TMJ, center.thing1 and center.thing2 will be indexed. 