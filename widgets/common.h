/*
 * widgets/common.h - common widget functions or callbacks
 *
 * Copyright © 2010 Mason Larobina <mason.larobina@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef LUAKIT_WIDGETS_COMMON_H
#define LUAKIT_WIDGETS_COMMON_H

#include "clib/widget.h"

#define LUAKIT_WIDGET_INDEX_COMMON(widget)            \
    case L_TK_PARENT:                                \
      return luaH_widget_get_parent(L, widget);      \
    case L_TK_FOCUSED:                                \
      return luaH_widget_get_focused(L, widget);      \
    case L_TK_VISIBLE:                                \
      return luaH_widget_get_visible(L, widget);      \
    case L_TK_TOOLTIP:                                \
      return luaH_widget_get_tooltip(L, widget);      \
    case L_TK_WIDTH:                                  \
      return luaH_widget_get_width(L, widget);        \
    case L_TK_HEIGHT:                                 \
      return luaH_widget_get_height(L, widget);       \
    case L_TK_MIN_SIZE:                               \
      return luaH_widget_get_min_size(L, widget);     \
    case L_TK_SHOW:                                   \
      lua_pushcfunction(L, luaH_widget_show);         \
      return 1;                                       \
    case L_TK_HIDE:                                   \
      lua_pushcfunction(L, luaH_widget_hide);         \
      return 1;                                       \
    case L_TK_FOCUS:                                  \
      lua_pushcfunction(L, luaH_widget_focus);        \
      return 1;                                       \
    case L_TK_DESTROY:                                \
      lua_pushcfunction(L, luaH_widget_destroy);      \
      return 1;

#define LUAKIT_WIDGET_NEWINDEX_COMMON(widget)         \
    case L_TK_VISIBLE:                                \
      return luaH_widget_set_visible(L, widget);      \
    case L_TK_TOOLTIP:                                \
      return luaH_widget_set_tooltip(L, widget);      \
    case L_TK_MIN_SIZE:                               \
      return luaH_widget_set_min_size(L, widget);     \

#define LUAKIT_WIDGET_BIN_INDEX_COMMON(widget)        \
    case L_TK_CHILD:                                  \
      return luaH_widget_get_child(L, widget);

#define LUAKIT_WIDGET_BIN_NEWINDEX_COMMON(widget)     \
    case L_TK_CHILD:                                  \
      luaH_widget_set_child(L, widget);               \
      break;

#define LUAKIT_WIDGET_CONTAINER_INDEX_COMMON(widget)  \
    case L_TK_REMOVE:                                 \
      lua_pushcfunction(L, luaH_widget_remove);       \
      return 1;                                       \
    case L_TK_CHILDREN:                               \
      return luaH_widget_get_children(L, widget);

#define LUAKIT_WIDGET_SIGNAL_COMMON(w)                       \
    "signal::destroy",         G_CALLBACK(destroy_cb),    w, \
    "signal::size-allocate",   G_CALLBACK(resize_cb),     w, \
    "signal::focus-in-event",  G_CALLBACK(focus_cb),      w, \
    "signal::focus-out-event", G_CALLBACK(focus_cb),      w, \
    "signal::parent-set",      G_CALLBACK(parent_set_cb), w,

gboolean button_cb(GtkWidget*, GdkEventButton*, widget_t*);
gboolean mouse_cb(GtkWidget*, GdkEventCrossing*, widget_t*);
gboolean focus_cb(GtkWidget*, GdkEventFocus*, widget_t*);
gboolean key_press_cb(GtkWidget*, GdkEventKey*, widget_t*);
gboolean key_release_cb(GtkWidget*, GdkEventKey*, widget_t*);
gboolean true_cb();

gint luaH_widget_destroy(lua_State*);
gint luaH_widget_focus(lua_State*);
gint luaH_widget_get_child(lua_State*, widget_t*);
gint luaH_widget_get_children(lua_State*, widget_t*);
gint luaH_widget_hide(lua_State*);
gint luaH_widget_remove(lua_State*);
gint luaH_widget_set_child(lua_State*, widget_t*);
gint luaH_widget_show(lua_State*);
gint luaH_widget_get_parent(lua_State *L, widget_t *w);
gint luaH_widget_get_focused(lua_State *L, widget_t*);
gint luaH_widget_get_visible(lua_State *L, widget_t*);
gint luaH_widget_get_width(lua_State *L, widget_t*);
gint luaH_widget_get_height(lua_State *L, widget_t*);
gint luaH_widget_set_visible(lua_State *L, widget_t*);
gint luaH_widget_set_tooltip(lua_State *L, widget_t *w);
gint luaH_widget_get_tooltip(lua_State *L, widget_t *w);
gint luaH_widget_set_min_size(lua_State *L, widget_t *w);
gint luaH_widget_get_min_size(lua_State *L, widget_t *w);


void add_cb(GtkContainer*, GtkWidget*, widget_t*);
void parent_set_cb(GtkWidget*, GtkWidget*, widget_t*);
void resize_cb(GtkWidget*, GdkRectangle *, widget_t *);
void remove_cb(GtkContainer*, GtkWidget*, widget_t*);
void destroy_cb(GtkWidget* UNUSED(win), widget_t *w);
void widget_destructor(widget_t*);

#endif

// vim: ft=c:et:sw=4:ts=8:sts=4:tw=80
