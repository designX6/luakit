--- Provides luakit://help/ page.
--
-- @module help_chrome
-- @copyright 2016 Aidan Holm
-- @copyright 2012 Mason Larobina <mason.larobina@gmail.com>

local lousy = require("lousy")
local chrome = require("chrome")
local history = require("history")
local add_cmds = require("binds").add_cmds
local error_page = require("error_page")

local _M = {}

local index_html_template = [==[
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Luakit Help</title>
    <style type="text/css">{style}
    </style>
</head>
<body>
    <header id="page-header"><h1>Luakit Help</h1></header>
    <div class=content-margin>
        <h2>About Luakit</h2>
            <p>Luakit is a highly configurable, browser framework based on the <a
            href="http://webkit.org/" target="_blank">WebKit</a> web content engine and the <a
            href="http://gtk.org/" target="_blank">GTK+</a> toolkit. It is very fast, extensible with <a
            href="http://lua.org/" target="_blank">Lua</a> and licensed under the <a
            href="https://raw.github.com/aidanholm/luakit/develop/COPYING.GPLv3" target="_blank">GNU GPLv3</a>
            license.  It is primarily targeted at power users, developers and any people with too much time
            on their hands who want to have fine-grained control over their web browser&rsquo;s behaviour and
            interface.</p>
        <h2>Introspector</h2>
        <p> To view the automatically generated documentation for currently loaded
        modules and available keybinds, open the Luakit introspector.</p>
        <ul>
            <li><a href="luakit://introspector/">Introspector</a></li>
        </ul>
        <h2>API Documentation</h2>
        <ul>
            <li><a href="luakit://help/doc/index.html">API Index</a></li>
        </ul>
        <h2>Questions, Bugs, and Contributions</h2>

        <p>Please report any bugs or issues you find at the GitHub
        <a href="https://github.com/aidanholm/luakit/issues" target="_blank">issue tracker</a>.</p>
        <p>If you have any feature requests or questions, feel free to open an
        issue for those as well. Pull requests and patches are both welcome,
        and there are plenty of areas that could be improved, especially tests
        and documentation.</p>

        <h2>License</h2>
        <p>Luakit is licensed under the GNU General Public License version 3 or later.
        The abbreviated text of the license is as follows:</p>
        <div class=license>
            <p>This program is free software: you can redistribute it and/or modify
            it under the terms of the GNU General Public License as published by
            the Free Software Foundation, either version 3 of the License, or
            (at your option) any later version.</p>

            <p>This program is distributed in the hope that it will be useful,
            but WITHOUT ANY WARRANTY; without even the implied warranty of
            MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
            GNU General Public License for more details.</p>

            <p>You should have received a copy of the GNU General Public License
            along with this program.  If not, see
            <a href="https://www.gnu.org/licenses/">https://www.gnu.org/licenses/</a>.</p>
        </div>
    </div>
</body>
]==]

local help_index_page = function ()
    local html_subs = { style = chrome.stylesheet, }
    local html = string.gsub(index_html_template, "{(%w+)}", html_subs)
    return html
end

local help_doc_index_page_preprocess = function (inner, style)
    -- Mark each list with the section heading just above it
    inner = inner:gsub("<h2>(%S+)</h2>%s*<ul>", "<h2>%1</h2><ul class=%1>")
    -- Customize each module link bullet
    inner = inner:gsub('<li><a href="modules/(%S+).html">', function (pkg)
        local builtins = {
            extension = true,
            ipc = true,
            luakit = true,
            msg = true,
            soup = true,
        }
        local class = package.loaded[pkg] and "enabled" or "disabled"
        if builtins[pkg] then class = "builtin" end
        return '<li class=' .. class .. '><a title="' .. pkg .. ": " .. class .. '" href="modules/' .. pkg .. '.html">'
    end)
    style = style .. [===[
        div#wrap { padding-top: 0; }
        h2 { margin: 1.5em 0 0.75em; }
        h2 + ul { margin: 0.5em 0; }
        ul {
            display: flex;
            flex-wrap: wrap;
            padding-left: 1em;
            list-style-type: none;
        }
        ul > li {
            flex: 1 0 200px;
            padding: 5px;
            margin: 0px !important;
            position: relative;
            padding-left: 1.5em;
        }
        ul > li:before {
            font-weight: bold;
            width: 1.5em;
            text-align: center;
            left: 0;
            position: absolute;
        }
        ul > li:before { content: "●"; transform: translate(1px, -1px); z-index: 0; }
        ul.Modules > li.enabled:before { content: "\2713 "; color: darkgreen; }
        ul.Modules > li.disabled:before { content: "\2717 "; color: darkred; }
        ul.Modules > li.enabled:before, ul.Modules > li.disabled:before {
            transform: none;
        }
        #page-header { z-index: 100; }
    ]===]
    return inner, style
end

local help_doc_page = function (v, path, request)
    local extract_doc_html = function (file)
        local prefix = luakit.dev_paths and "doc/apidocs/" or luakit.install_path  .. "/doc/"
        local blob = lousy.load(prefix .. file)
        local style = blob:match("<style>(.*)</style>")
        -- Remove some css rules
        style = style:gsub("html %b{}", ""):gsub("#hdr %b{}", ""):gsub("#hdr > h1 %b{}", "")
        local inner = blob:match("(<div id=wrap>.*</div>)%s*</body>")
        if file == "index.html" then
            inner, style = help_doc_index_page_preprocess(inner, style)
        end
        return inner, style
    end

    local doc_html_template = [==[
    <!doctype html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Luakit API Documentation</title>
        <style type="text/css">
        {style}
        #wrap { padding: 2em 0; }
        #content > h1 { font-size: 28px; }
        </style>
    </head>
    <body>
        <header id="page-header">
            <h1>Luakit API Documentation</h1>
        </header>
        <div class="content-margin">
        {doc_html}
        </div>
    </body>
    ]==]
    local ok, doc_html, doc_style = pcall(extract_doc_html, path)
    if not ok then
        print(doc_html)
        error_page.show_error_page(v, {
            heading = "Documentation not found",
            content = [==[]==],
            buttons = {{
                label = "Return to API Index",
                callback = function (vv) vv.uri = "luakit://help/doc/index.html" end
            }},
            request = request,
        })
        return
    end
    local html_subs = {
        style = doc_style .. chrome.stylesheet,
        doc_html = doc_html,
    }
    local html = string.gsub(doc_html_template, "{([%w_]+)}", html_subs)
    return html
end

chrome.add("help", function (v, meta)
    if meta.path:match("^/?$") then
        return help_index_page()
    elseif meta.path:match("^doc/?") then
        return help_doc_page(v, ({meta.path:match("^doc/?(.*)$")})[1], meta.request)
    end
end, nil, {})

local cmd = lousy.bind.cmd
add_cmds({
    cmd("help", "Open [luakit://help/](luakit://help/) in a new tab.",
        function (w) w:new_tab("luakit://help/") end),
})

-- Prevent history items from turning up in history
history.add_signal("add", function (uri)
    if string.match(uri, "^luakit://help/") then return false end
end)

return _M

-- vim: et:sw=4:ts=8:sts=4:tw=80
