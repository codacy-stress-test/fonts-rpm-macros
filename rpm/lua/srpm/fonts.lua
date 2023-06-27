-- Copyright © 2018-2019 Nicolas Mailhot <nim@fedoraproject.org>
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

-- Return a normalized name
local function norm(name)
  local r = name
  r = string.gsub(r, "[%p%s]+", "-")
  r = string.gsub(r, "^-", "")
  r = string.gsub(r, "-$", "")
  r = string.lower(r)
  return r
end

-- loop over suffixlist and return name minus the first suffix that matches
-- - is used as suffix separator
-- name should have passed through norm at one point in the past
local function dropsuffix(name,suffixlist)
  local r = name
  for _, s in ipairs(suffixlist) do
    r, n = string.gsub(r, "-" .. norm(s) .. "$", "")
    if (n == 1) then break end
  end
  return r
end

-- Compute a font family name that can be used in packaging, lowercasing, using
-- - as separator, and applying  “WPF font selection model” whitepaper
-- simplifications
local function rpmname(name)
  local r = norm(name)
  -- Normal & co
  r = dropsuffix(r,{"normal","book","regular","upright"})
  -- Slant
  r = dropsuffix(r,{"italic","ita","ital","cursive","kursiv",
                    "oblique","inclined","backslanted","backslant","slanted"})
  -- Width / Stretch
  r = dropsuffix(r,{"ultracondensed","extra-compressed","ext-compressed","ultra-compressed","ultra-condensed",
                    "extracondensed","compressed","extra-condensed","ext-condensed","extra-cond",
                    "semicondensed","narrow","semi-condens",
                    "semiexpanded","wide","semi-expanded","semi-extended",
                    "extraexpanded","extra-expanded","ext-expanded","extra-extended","ext-extended",
                    "ultraexpanded","ultra-expanded","ultra-extended",
                    "condensed","cond",
                    "expanded","extended"})
  -- Weight (no abbreviated suffix handling, too dangerous)
  r = dropsuffix(r,{"thin","extra-thin","ext-thin","ultra-thin",
                    "extralight","extra-light","ext-light","ultra-light",
                    "demibold","semi-bold","demi-bold",
                    "extrabold","extra-bold","ext-bold","ultra-bold",
                    "extrablack","extra-black","ext-black","ultra-black",
                    "bold","thin","light","medium",
                    "black","heavy","nord",
                    "demi","ultra"})
  local tokens = {}
  for _, t in ipairs({"font","fonts"}) do
    tokens[t] = true
  end
  local ts = string.gmatch(r, "[^%-]+")
  r = ""
  for t in ts do
     if not tokens[t] then
       r = r .. "-" .. t
       tokens[t] = true
     end
  end
  r = string.gsub(r, "^-", "") .. "-fonts"
  return r
end

-- The fontmeta macro main processing function
-- See the documentation in the macros.fonts file for argument description
local function meta(suffix, verbose)
  local fedora = require "fedora.common"
  local ismain = (suffix == "") or (suffix == "0")
  fedora.zalias({"foundry", "fontlicense"}, verbose)
  fedora.safeset("fontlicense", "%{license}", verbose)
  if ismain then
    fedora.zalias({"fontsummary", "fontdescription", "fontname", "fonthumanname",
                   "fontheader", "fonts", "fontsex", "fontconfs", "fontconfsex",
                   "fontconfngs", "fontconfngsex",
                   "fontappstreams", "fontappstreamsex",
                   "fontdocs", "fontdocsex", "fontlicense", "fontlicenses", "fontlicensesex",
                   "fontdir", "fontlist"}, verbose)
  end
  for _, v in ipairs({"foundry", "fontdocs", "fontdocsex",
                      "fontlicense", "fontlicenses", "fontlicensesex"}) do
    if (rpm.expand("%{" .. v .. "}") ~= "%{" .. v .. "}") then
      fedora.safeset(v .. suffix, "%{" .. v .. "}", verbose)
    end
  end
  local foundry = rpm.expand("%{?foundry" .. suffix .. ":%{foundry" .. suffix .. "}}")
  local family = string.gsub(rpm.expand("%{fontfamily" .. suffix .. "}"), "^" .. foundry, "")
  local basename = foundry .. " " .. family
  fedora.safeset("fontname"      .. suffix, rpmname(basename), verbose)
  fedora.safeset("fonthumanname" .. suffix, basename, verbose)
  fedora.safeset("fontdir"       .. suffix, "%{_fontbasedir}/%{fontname"  .. suffix .. "}", verbose)
  fedora.safeset("fontlist"      .. suffix, "%{_builddir}/%{?buildsubdir}/%{fontname" .. suffix .. "}.list", verbose)
  if ismain then
    fedora.zalias({"fontname", "fontdir", "fontlist"})
  end
end

-- Make currentfont* variables point to a specific suffix-indexed variable set
local function env(suffix, verbose)
  local fedora = require "fedora.common"
  for _, v in ipairs({"fonts", "fontsex", "fontconfs", "fontconfsex",
     "fontconfngs", "fontconfngsex", "fontappstreams", "fontappstreamsex",
     "fontdocs", "fontdocsex", "fontlicenses", "fontlicensesex",
     "foundry", "fontname", "fonthumanname", "fontheader", "fontdir",
     "fontlist", "fontfamily", "fontlicense", "fontsummary",
     "fontdescription"}) do
    if (rpm.expand("%{?" .. v .. suffix .. "}") ~= "") then
      fedora.explicitset(  "current" .. v, "%{" .. v .. suffix .. "}", verbose)
    else
      fedora.explicitunset("current" .. v,                             verbose)
    end
  end
end

-- Create a single package header for a fonts subpackage
local function pkg(suffix, verbose)
  meta(suffix, verbose)
  env(suffix, verbose)
  print(rpm.expand([[
%new_package -n %{currentfontname}
Summary:        %{currentfontsummary}
License:        %{currentfontlicense}
BuildArch:      noarch
BuildRequires:  fonts-rpm-macros
Requires:       fontpackages-filesystem
%{?currentfontheader}
%description -n %{currentfontname}
%wordwrap -v currentfontdescription
]]))
end

-- Create a font (sub)metapackage header
local function metapkg(name, summary, description, suffixes)
  local   fedora = require "fedora.common"
  local fontpkgs = fedora.getsuffixed("fontname")
  if (name == "") then
    name, _ = string.gsub(rpm.expand("%{source_name}"), "-fonts$", "")
    name    = name .. "-fonts-all"
  end
  if (summary == "") then
    summary = "All the font packages, created in %{source_name}"
  end
  if (description == "") then
    description = [[
This meta-package installs all the font packages, created in the
%{source_name} source package.
It is provided as end-user convenience. Do not depend on it in other packages.
]]
  end
  description = fedora.wordwrap(description)
  print(rpm.expand([[
%new_package   -n ]] .. name    .. [[

Summary:   ]]        .. summary .. [[

]]))
  if (suffixes == "") then
    for _, fontpkg in pairs(fontpkgs) do
      print(rpm.expand(  "Requires(meta):  " .. fontpkg .. " = %{version}-%{release}\n"))
    end
  else
    for suffix in string.gmatch(rpm.expand(suffixes), "[^%s%p]+") do
      local fontpkg = fontpkgs[suffix]
      if (fontpkg ~= nil) then
        print(rpm.expand("Requires(meta):  " .. fontpkg .. " = %{version}-%{release}\n"))
      end
    end
  end
  print(rpm.expand([[
BuildArch: noarch
%description -n ]]    .. name .. [[

]] .. description             .. [[
%files -n ]]          .. name .. [[
]]))
end

return {
  rpmname  = rpmname,
  env      = env,
  pkg      = pkg,
  metapkg  = metapkg,
}


