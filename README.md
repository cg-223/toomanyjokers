# Too Many Jokers
Adds a toggleable sidebar displaying your collection, along with a searchbar.

## Usage
Press T to open TMJ on your left.

At the bottom is a text input for searching. Searches are loosely matched against every card. If a card doesn't match your search terms, it won't be displayed.

You can use multiple search terms using commas. All provided search terms must match with a card for the card to show. (e.g. `+mult, xmult` will only show jokers that give both xmult and +mult, not any joker that gives either)

## Advanced uses

There are several special search terms, surrounded by braces (`{}`). These allow you to specify more about your search. They MUST come before any normal search terms.

## `{any}`

{any} specifies that if ANY of the search terms are matched, a card will show up. Using the example above, `{any}, +mult, xmult` will show jokers that give either +mult or xmult.

## `{regex}`

{regex} specifies that we should use Lua's pattern matcher instead of just a raw search. Keep in mind this is Lua patterns, not actual regex.

## `{edition:modprefix_editionkey}`

{edition} will apply the specified edition to all cards in TMJ. This is useful for mod developers making shaders that want to see how their shader looks on various (or specific) jokers.

## `{ace:<lua code here>}`

{ace} will run the lua code as the block of a function (or just a single expression e.g. `center.pools.Kitties`, or in the case of a full function body `if center.pools.Kitties then return true end`) given the argument of `center`. If it returns `false`, `nil`, or errors (which will be caught), then the center passed into the function will not show in TMJ.

It is okay for the function given to error, it will be treated as if the function returned false.

This is helpful for... uh.... uhm.... idk but it's cool right?

## `!`
Any non-special search term can be prefixed with `!` to specify that you want to negate that search term (so if it IS matched, do not show the card)

Credits to Dimserene for the idea to create this mod.

