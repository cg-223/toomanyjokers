# toomanyjokers
Adds a UI allowing for searching of cards.

## Usage
Press T to open TMJ.

Searches are loosely matched against many aspects of every card.

If a card checked in the search matches those, it will show up.

You can use multiple search terms by using commas. Virtually unlimited search terms are supported.

All provided search terms must match with a card for the card to show. (e.g. `+mult, xmult` will only show jokers that give both xmult and +mult, not any joker that gives either)

## Advanced uses

There are several special search terms, surrounded by braces (`{}`). These allow you to specify more about your search. They MUST come before any non-special terms.

`{any}`

{any} specifies that if ANY of the search terms are matched, a card will show up. Using the example above, `{any}, +mult, xmult` will show jokers that give either +mult or xmult.

`{regex}`

{regex} specifies that we should use Lua's pattern matcher instead of just a raw search. Keep in mind this is Lua patterns, not actual regex.

Additionally, any non-special search term can be prefixed with `!` to specify that you should NOT match that search term.

A use of all these is as follows:

`{any}, {regex}, legendary, cryptid, xmult.*hearts, !joker`

Explanation: Any joker that is either legendary, is from cryptid, gives xmult AND has to do with hearts (assuming the xmult came first), or does not have "joker" anywhere in its properties.

Credits to Dimserene for the idea to create this mod.
