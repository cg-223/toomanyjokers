--- STEAMODDED HEADER
--- MOD_NAME: Too Many Jokers
--- MOD_ID: toomanyjokers
--- MOD_AUTHOR: [cg]
--- PREFIX: tmj
--- MOD_DESCRIPTION: Adds a filtering system to the Joker collection.
--- PRIORITY: 1




local function filterCenters(filters, list)
  local matchedCenters = {}
  for i, center in pairs(list) do
    local matchAgainst = {} --all strings in this table will be matched against all filters in {filters}

    local sub = string.gsub(string.lower(center.name), " ", "")
    table.insert(matchAgainst, sub) --match against the centers name
    local ourkey = ""
    for key, v in pairs(G.P_CENTERS) do
      --our lists wont include keys so we need to fetch them ourselves
      if v == center then
        --we've found the right center
        ourkey = key
      end
    end
    local sub = string.gsub(string.lower(ourkey), " ", "")
    table.insert(matchAgainst, sub) --match against the key

    if center.mod then
      local modname = center.mod.name or ""
      modname = string.lower(modname)
      modname = string.gsub(modname, " ", "")
      table.insert(matchAgainst, modname) --match against the name of the mod that implemented this center
    end

    
    if center.rarity then
      local raritystring = ""
      --this only supports a handful of mods, its fine though!
      if type(center.rarity) == "string" then
        if center.rarity == "cry_exotic" then
          raritystring = "Exotic"
        elseif center.rarity == "cry_epic" then
          raritystring = "Epic"
        else
          raritystring = center.rarity
        end
      elseif center.rarity == 1 then
        raritystring = "Common"
      elseif center.rarity == 2 then
        raritystring = "Uncommon"
      elseif center.rarity == 3 then
        raritystring = "Rare"
      elseif center.rarity == 4 then
        raritystring = "Legendary"
      end
      raritystring = string.lower(raritystring)
      raritystring = string.gsub(raritystring, " ", "")
      table.insert(matchAgainst, raritystring)
    end

    for _, loclist in pairs(G.localization.descriptions) do
      if loclist[ourkey] then   --G.localization.descriptions contains tables for tarots, tags, jokers, etc, this function covers all types of centers so we can iterate through
                                --i originally intended this to be usable for all cards, but in the end I decided to keep it to just jokers
        local ourDescription = loclist[ourkey]
        table.insert(matchAgainst, ourDescription.name) --this is localized name
        local descText = ourDescription.text  --description
        local lineConcat = ""
        for _, descLine in ipairs(descText) do
          local processedLine = descLine
          processedLine = string.gsub(processedLine, "{[^}]+}", "") --remove any formatting tags, e.g. {C:legendary}
          processedLine = string.gsub(processedLine, "#[^#]+#", "") --remove locvar tags, e.g. #1#
          processedLine = string.gsub(processedLine, "{}", "")      --remove ending formatting tags, e.g. {}
          processedLine = string.gsub(processedLine, " ", "")
          processedLine = string.lower(processedLine)
          --EXAMPLE: "{X:dark_edition,C:white}^#1#{} Mult only after"
          -->> "^#1#{} Mult only after"
          -->> "^{} Mult only after"
          -->> "^ Mult only after"
          -->> "^Multonlyafter"
          -->>"^multonlyafter"
          lineConcat = lineConcat .. processedLine
        end
        table.insert(matchAgainst, lineConcat) --this is a concatenation of every line in the description, with all formatting removed.
      end
    end

    for iiii, vvvv in pairs(filters) do
      vvvv = string.gsub(vvvv, " ", "")
      vvvv = string.lower(vvvv)
    end
    for iiii, vvvv in pairs(matchAgainst) do
      vvvv = string.gsub(vvvv, " ", "")
      vvvv = string.lower(vvvv)
    end --lower all our filters, and remove sapces
    --main loop
    local mastermatcher = ""
    for iaasdf, vcascsaz in pairs(matchAgainst) do
      mastermatcher = mastermatcher..vcascsaz --combine all of our matchers (description, name, mod, etc)
    end
    local flag = false
    for _, filter in pairs(filters) do
      if not string.find(mastermatcher, filter, 1, true) then --is filter contained in matcher, starting at the first character, using a raw text search as to ignore characters like ^?
        flag = true
      end
    end
    if not flag then
      table.insert(matchedCenters, center)
    end
  end
  local lastSeen
  local indicesToRemove = {}
  for i, v in ipairs(matchedCenters) do
    if v == lastSeen then --this code is redundant; we combine all our matchers so we cant get duplicates anymore. im keeping it here just in case
      table.insert(indicesToRemove, i - #indicesToRemove) 
    end
    lastSeen = v
  end 
  for i, v in ipairs(indicesToRemove) do
    table.remove(matchedCenters, v)
  end
  return matchedCenters
end




G.ENTERED_FILTER = "" --necessary for textbox for the variable to be intialized as a string



local oldjokers = G.FUNCS.your_collection_jokers
function G.FUNCS.your_collection_jokers()
  oldjokers()
  G.OVERLAY_MENU:recalculate()
end

function G.FUNCS.reloadJoker()
  local filter = G.ENTERED_FILTER or ""
  filter = string.gsub(filter, " ", "")
  filter = string.lower(filter)
  filter = string.split(filter) --remove spaces from filter and separate via commas
  _G.thegreatfilter = filter
  G.FUNCS.your_collection_jokers() --reload joker collection page
end


function string.split(input)
  local result = {}
  for match in (input..","):gmatch("(.-),") do --split up the string by its commas
      table.insert(result, match)
  end
  return result
end 

--overwrite all collection functions to allow for searching
function create_UIBox_your_collection_jokers()
  G.ENTERED_FILTER = "" --change filter textbox back to blank when we load/reload the page
  local deck_tables = {}

  G.your_collection = {}
  for j = 1, 2 do
    G.your_collection[j] = CardArea(
      G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
      5 * G.CARD_W,
      0.95 * G.CARD_H,
      { card_limit = 5, type = 'title', highlight_limit = 0, collection = true })
    table.insert(deck_tables,
      {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.07, no_fill = true },
        nodes = {
          { n = G.UIT.O, config = { object = G.your_collection[j] } }
        }
      }
    )
  end
  local jokerPool = filterCenters(thegreatfilter or {""}, G.P_CENTER_POOLS.Joker) --get the filtered out pool
  local joker_options = {}
  for i = 1, math.ceil(#jokerPool / (5 * #G.your_collection)) do
    table.insert(joker_options,
      localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#jokerPool / (5 * #G.your_collection))))
  end

  for i = 1, 5 do
    for j = 1, #G.your_collection do
      local center = jokerPool[i + (j - 1) * 5]
      if center then
        local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G.CARD_W,
          G.CARD_H, nil, center)
        card.sticker = get_joker_win_sticker(center)
        G.your_collection[j]:emplace(card)
      end
    end
  end

  INIT_COLLECTION_CARD_ALERTS()

  local t = create_UIBox_generic_options({
    back_func = 'your_collection',
    contents = {
      { n = G.UIT.R, config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables },
      {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
          create_option_cycle({ options = joker_options, w = 4.5, cycle_shoulders = true, opt_callback =
          'your_collection_joker_page', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = { snap_to = true, nav = 'wide' } })
        }
      },
      {
				n = G.UIT.R,
        config = { align = "cm" },
				nodes = {
					create_text_input({
						colour = G.C.RED,
						hooked_colour = darken(copy_table(G.C.RED), 0.3),
						w = 4.5,
						h = 1,
						max_length = 100,
						extended_corpus = true,
						prompt_text = "Keywords, separated by commas",
						ref_table = G,
						ref_value = "ENTERED_FILTER",
						keyboard_offset = 1,
            callback = function()
              G.FUNCS.reloadJoker()
            end
					}),
				},
			}, --textbox
    }
  })

  return t
end

G.FUNCS.your_collection_joker_page = function(args)
  if not args or not args.cycle_config then return end

  local jokerPool = filterCenters(thegreatfilter or {""}, G.P_CENTER_POOLS.Joker) --get our filtered joker list

  for j = 1, #G.your_collection do
    for i = #G.your_collection[j].cards, 1, -1 do
      local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
      c:remove()
      c = nil
    end
  end
  for i = 1, 5 do
    for j = 1, #G.your_collection do
      local center = jokerPool[i + (j - 1) * 5 + (5 * #G.your_collection * (args.cycle_config.current_option - 1))]
      if not center then break end
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G.CARD_W,
        G.CARD_H, G.P_CARDS.empty, center)
      card.sticker = get_joker_win_sticker(center)
      G.your_collection[j]:emplace(card)
    end
  end
  INIT_COLLECTION_CARD_ALERTS()
end




