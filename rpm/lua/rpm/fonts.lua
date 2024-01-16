-- Copyright © 2019 Nicolas Mailhot <nim@fedoraproject.org>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
--
-- SPDX-License-Identifier: GPL-3.0-or-later

-- Convenience lua functions used to create rpm font packages

-- A helper to close AppStream XML runs
local function closetag(oldtag, newtag)
  if (oldtag == nil) then
    return ""
  else
    local output = "]]></" .. oldtag .. ">"
    if (oldtag == "li") and (newtag ~= oldtag) then
      output = output .. "</ul>"
    end
    return output
  end
end

-- A helper to open AppStream XML runs
local function opentag(oldtag, newtag)
  if (newtag == nil) then
    return ""
  else
    local output = "<" .. newtag .. "><![CDATA["
    if (newtag == "li") and (newtag ~= oldtag) then
      output = "<ul>" .. output
    end
    return output
  end
end

-- A helper to switch AppStream XML runs
local function switchtag(oldtag, newtag)
  return closetag(oldtag, newtag) .. opentag(oldtag, newtag)
end

-- Reformat some text into something that can be included in an AppStream
-- XML description
local function txt2xml(text)
  local      fedora = require "fedora.common"
  local        text = fedora.wordwrap(text)
  local      output = ""
  local     oldtag  = nil
  local oldadvance  = nil
  local      newtag = nil
  text = string.gsub(text, "^\n*", "")
  text = string.gsub(text, "\n*$", "\n")
  for line in string.gmatch(text, "[^\n]*\n") do
    local change = true
    local advance, n = string.gsub(line, "^(%s*– ).*", "%1")
    if (n == 1) then
      newtag = "li"
    else
      advance = string.gsub(line, "^(%s*).*", "%1")
      if (line == "\n") then
        newtag = nil
      elseif (advance ~= oldadvance) then
        newtag = "p"
      else
        change = false
      end
    end
    local result = ""
    if change then
      result     = string.gsub(line, "^" .. advance, switchtag(oldtag,newtag))
      oldtag     = newtag
      oldadvance = string.gsub(advance, "– ", "  ")
    else
      result = string.gsub(line, "^" .. advance, " ")
    end
    result = string.gsub(result, "\n$", "")
    output = output .. result
  end
  output = output .. closetag(oldtag, nil)
  return output
end

return {
  txt2xml = txt2xml,
}
