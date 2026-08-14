-- Pandoc filter: restructure the resume markdown for the typst PDF writer.
--
--   * "### Job Title" + "**Org** | Location | Dates"  -> #job() with right-aligned dates
--   * "**Label:** a, b, c"                            -> #skill() two-column row
--   * the contact line under the name                 -> #contactline(), pipes become dots
--   * thematic breaks (---)                           -> dropped (sections carry their own rule)

local function to_typst(inlines)
  local doc = pandoc.Pandoc({ pandoc.Plain(inlines) })
  return (pandoc.write(doc, 'typst', { wrap_text = 'none' }):gsub('%s+$', ''))
end

local function raw(s)
  return pandoc.RawBlock('typst', s)
end

-- Split a list of inlines on "|" separators, trimming surrounding spaces.
local function split_pipes(inlines)
  local parts, cur = {}, {}
  for _, il in ipairs(inlines) do
    if il.t == 'Str' and il.text == '|' then
      table.insert(parts, cur)
      cur = {}
    else
      table.insert(cur, il)
    end
  end
  table.insert(parts, cur)
  for _, part in ipairs(parts) do
    while #part > 0 and part[1].t == 'Space' do table.remove(part, 1) end
    while #part > 0 and part[#part].t == 'Space' do table.remove(part) end
  end
  return parts
end

local function join(parts, sep)
  local out = {}
  for i, part in ipairs(parts) do
    if i > 1 then table.insert(out, pandoc.Str(sep)) end
    for _, il in ipairs(part) do table.insert(out, il) end
  end
  return out
end

-- "March 2010 - January 2013" reads better with an en dash.
local function endash(inlines)
  return pandoc.Inlines(inlines):walk({
    Str = function(s)
      if s.text == '-' then return pandoc.Str('\u{2013}') end
    end,
  })
end

local function is_meta_line(block)
  if not block or block.t ~= 'Para' then return false end
  if block.content[1] == nil or block.content[1].t ~= 'Strong' then return false end
  for _, il in ipairs(block.content) do
    if il.t == 'Str' and il.text == '|' then return true end
  end
  return false
end

-- "**Languages:** C, C++, ..." -> label + values
local function skill_parts(block)
  if block.t ~= 'Para' then return nil end
  local lead = block.content[1]
  if not lead or lead.t ~= 'Strong' then return nil end
  local last = lead.content[#lead.content]
  if not last or last.t ~= 'Str' or not last.text:match(':$') then return nil end
  local label = pandoc.List(lead.content):clone()
  label[#label] = pandoc.Str(last.text:gsub(':$', ''))
  local rest = pandoc.List({})
  for i = 2, #block.content do rest:insert(block.content[i]) end
  while #rest > 0 and rest[1].t == 'Space' do rest:remove(1) end
  return label, rest
end

function Pandoc(doc)
  local blocks, out, i = doc.blocks, pandoc.List({}), 1

  while i <= #blocks do
    local b = blocks[i]

    if b.t == 'HorizontalRule' then
      i = i + 1

    elseif b.t == 'Header' and b.level == 1 then
      out:insert(raw('#name[' .. to_typst(b.content) .. ']'))
      i = i + 1
      if blocks[i] and blocks[i].t == 'Para' then
        local contact = join(split_pipes(blocks[i].content), ' \u{00b7} ')
        out:insert(raw('#contactline[' .. to_typst(contact) .. ']'))
        i = i + 1
      end

    elseif b.t == 'Header' and b.level == 3 and is_meta_line(blocks[i + 1]) then
      local parts = split_pipes(blocks[i + 1].content)
      local dates = endash(table.remove(parts))
      out:insert(raw(table.concat({
        '#job(',
        '[' .. to_typst(b.content) .. '], ',
        '[' .. to_typst(join(parts, ' \u{00b7} ')) .. '], ',
        '[' .. to_typst(dates) .. '])',
      })))
      i = i + 2

    elseif skill_parts(b) then
      -- consecutive "**Label:** ..." paragraphs become one aligned grid
      local rows = {}
      while blocks[i] and skill_parts(blocks[i]) do
        local label, values = skill_parts(blocks[i])
        table.insert(rows, '  ([' .. to_typst(label) .. '], [' .. to_typst(values) .. ']),')
        i = i + 1
      end
      out:insert(raw('#skills(\n' .. table.concat(rows, '\n') .. '\n)'))

    else
      out:insert(b)
      i = i + 1
    end
  end

  return pandoc.Pandoc(out, doc.meta)
end
