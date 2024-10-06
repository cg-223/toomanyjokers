# toomanyjokers
Adds a search bar to the Joker collection in Balatro.

Usage:
In the joker section of your collection, enter as many search terms as you want.
Searches are loosely matched against the name of the joker, the rarity of the joker, the jokers description, the jokers center key (don't worry about this one), and the mod that added the joker.
If the search matches any of those, it will show up.
You can use multiple search terms by using commas. Virtually unlimited search terms are supported.
All search terms must match with a joker for the joker to show. (e.g. "+mult, xmult" will only show jokers that give both xmult and +mult, not any joker that gives either)


Technicalities:
Whitespaces and capital letters are wiped from search terms and the things they're matched against.
All strings a search is matched against are combined before matching. This means, technically, that if a jokers name is "Kin", and its description starts with "Get", searching "King" will yield a success because the name and description are combined into "kinget".
This code is commented and intended to be somewhat readable, feel free to view or use my code however you like.

Credits to Dimserene for the idea to create this mod.
