# Too Many Jokers
Adds a toggleable sidebar displaying your collection, along with a searchbar.

## Usage
Press T to open TMJ on your left.

At the bottom is a text input for searching. Searches are loosely matched against every card. If a card doesn't match your search terms, it won't be displayed.

You can use multiple search terms using commas. All provided search terms must match with a card for the card to show. (e.g. `+mult, xmult` will only show jokers that give both xmult and +mult, not any joker that gives either)

## Advanced uses

There are several special search terms, surrounded by braces (`{}`). These allow you to specify more about your search. They MUST come before any normal search terms.

`{any}`

{any} specifies that if ANY of the search terms are matched, a card will show up. Using the example above, `{any}, +mult, xmult` will show jokers that give either +mult or xmult.

`{regex}`

{regex} specifies that we should use Lua's pattern matcher instead of just a raw search. Keep in mind this is Lua patterns, not actual regex.

Additionally, any non-special search term can be prefixed with `!` to specify that you want to negate that search term (so if it IS matched, do not show the card)

A use of all these is as follows:

`{any}, {regex}, legendary, cryptid, xmult.*hearts, !joker`

Explanation: Any joker that is either legendary, is from cryptid (or is the Spectral card Cryptid), gives xmult AND has to do with hearts (assuming the xmult came first), or is not a joker.

Credits to Dimserene for the idea to create this mod.
