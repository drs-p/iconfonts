local fonts = {
    solid       = "Font Awesome 7 Free-Solid-900.otf",
    regular     = "Font Awesome 7 Free-Regular-400.otf",
    brands      = "Font Awesome 7 Brands-Regular-400.otf",
    academicons = "academicons.ttf"
}

for fontname, filename in pairs(fonts) do
    fontfile = kpse.find_file(filename, "opentype fonts")
    if not fontfile then
        fontfile = kpse.find_file(filename, "truetype fonts")
    end
    if fontfile then
        tex.sprint(string.format("\\font\\IF%s = \"[%s]\"", fontname, fontfile))
        fonts[fontname] = fontfile
    else
        tex.error(
            string.format(
                "[iconfonts.sty] ERROR: font file '%s' not found!",
                filename
            )
        )
    end
end

local iconfont = {}

-- We want to access the fonts both from TeX and from Lua.
-- The easiest way to do that is to load the fonts in TeX
-- (which we do above) and use font.id() from Lua.
-- The downside of this approach is that TeX only loads
-- the fonts when typesetting has started, not in the preamble;
-- so we have to delay the Lua initialization until later.

local is_initialized = false
local function initialize()
    for fontname, _ in pairs(fonts) do
        iconfont[fontname] = font.getfont(font.id("IF" .. fontname)).resources.unicodes
    end

    is_initialized = true
end


--[[------------------------------------------------------------------------
    This function returns the named Font Awesome icon.

    There is some cleverness in the implementation to hide the fact
    that Font Awesome spreads its icons across three font files.
    If `name` is present in the `brands` font, we return that icon;
    if `name` ends with `-o`, we return the corresponding icon from
    the `regular` font (which is in fact the `light` or `open` font);
    otherwise we return the icon from the `solid` font (which is
    actually the real `regular` font).
    ------------------------------------------------------------------------]]
local function fontawesome(name)
    if not is_initialized then initialize() end

    local b = iconfont.brands[name]
    local s = iconfont.solid[name]
    local r, is_regular = string.gsub(name, "-o$", "", 1)
    if is_regular > 0 then
        r = iconfont.regular[r]
    else
        r = nil
    end

    local result
    if b then
        result = string.format("{\\IFbrands\\char%d}", b)
    elseif r then
        result = string.format("{\\IFregular\\char%d}", r)
    elseif s then
        result = string.format("{\\IFsolid\\char%d}", s)
    else
        tex.error(string.format("[iconfonts.sty] ERROR: no icon named '%s'!", name))
    end

    return tex.sprint(result)
end


--[[------------------------------------------------------------------------
    This function returns the named Academicons icon.
    ------------------------------------------------------------------------]]
local function academicons(name)
    if not is_initialized then initialize() end

    local a = iconfont.academicons[name]

    local result
    if a then
        result = string.format("{\\IFacademicons\\char%d}", a)
    else
        tex.error(string.format("[iconfonts.sty] ERROR: no icon named '%s'!", name))
    end

    return tex.sprint(result)
end


--  Font Awesome and Academicons contains a number of characters that aren't really icons;
--  we ignore these when processing "all" icons.
local t = {
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e",
    "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
    "u", "v", "w", "x", "y", "z", "asterisk", "at", "divide", "equals",
    "exclamation", "greater-than", "greater-than-equal", "hashtag", "hyphen",
    "less-than", "less-than-equal", "minus", "nonmarkingreturn", "notdef",
    ".notdef", "not-equal", "null", ".null", "percent", "plus", "plus-minus",
    "question", "space", "trademark", "zero-width-space"
}

local ignore = {}
for _, name in pairs(t) do
    ignore[name] = true
end


--[[------------------------------------------------------------------------
    This function processes all icons from one or more icon fonts.
    For each icon, it calls a user-defined callback function
    with two arguments: the name of the icon and the icon itself.

    The varargs argument ... specifies the icon fonts to be processed;
    this should be one or more of "solid", "regular" and "brands"
    (i.e., the keys of the table `fonts` at the top of this file).
    ------------------------------------------------------------------------]]
local function process_all_icons(callback, ...)
    if not is_initialized then initialize() end

    local names, icons = {}, {}
    for _, font in ipairs{...} do
        for name, unicode in pairs(iconfont[font]) do
            if not (ignore[name] or string.match(name, "-sign$")) then
                if font == "regular" then name = name .. "-o" end
                table.insert(names, name)
                icons[name] = string.format("\\IF%s\\char%d", font, unicode)
            end
        end
    end

    table.sort(names)
    for _, name in ipairs(names) do
        callback(name, icons[name])
    end
end


local fontawesome_version, academicons_version
_, _, fontawesome_version = string.find(
    fontloader.info(fonts.solid).version,
    "%(Font Awesome version: ([%d.]+)%)"
)
fontawesome_version = fontawesome_version or "[\\emph{unknown}]"
academicons_version = fontloader.info(fonts.academicons).version or "[\\emph{unknown}]"


return {
    fontawesome = fontawesome,
    academicons = academicons,

    -- The following items are not part of the supported API
    -- and may change without warning!
    _process_all_icons = process_all_icons,
    _fontawesome_version = fontawesome_version,
    _academicons_version = academicons_version,
}
