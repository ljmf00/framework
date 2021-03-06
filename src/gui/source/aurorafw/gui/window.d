/*
                                    __
                                   / _|
  __ _ _   _ _ __ ___  _ __ __ _  | |_ ___  ___ ___
 / _` | | | | '__/ _ \| '__/ _` | |  _/ _ \/ __/ __|
| (_| | |_| | | | (_) | | | (_| | | || (_) \__ \__ \
 \__,_|\__,_|_|  \___/|_|  \__,_| |_| \___/|___/___/

Copyright (C) 2018-2019 Aurora Free Open Source Software.

This file is part of the Aurora Free Open Source Software. This
organization promote free and open source software that you can
redistribute and/or modify under the terms of the GNU Lesser General
Public License Version 3 as published by the Free Software Foundation or
(at your option) any later version approved by the Aurora Free Open Source
Software Organization. The license is available in the package root path
as 'LICENSE' file. Please review the following information to ensure the
GNU Lesser General Public License version 3 requirements will be met:
https://www.gnu.org/licenses/lgpl.html .

Alternatively, this file may be used under the terms of the GNU General
Public License version 3 or later as published by the Free Software
Foundation. Please review the following information to ensure the GNU
General Public License requirements will be met:
http://www.gnu.org/licenses/gpl-3.0.html.

NOTE: All products, services or anything associated to trademarks and
service marks used or referenced on this file are the property of their
respective companies/owners or its subsidiaries. Other names and brands
may be claimed as the property of others.

For more info about intellectual property visit: aurorafoss.org or
directly send an email to: contact (at) aurorafoss.org .
*/

module aurorafw.gui.window;

struct WindowProperties {
	uint width = 800;
	uint height = 600;
	uint depth = 24;
}

abstract class Window {
	static final Window create(string name, WindowProperties wp = WindowProperties())
	{
		Window _instance;
		version(linux)
		{
			import std.process : environment;

			immutable auto xdg_session_type = environment.get("XDG_SESSION_TYPE");
			if(xdg_session_type == "x11")
			{
				import aurorafw.gui.api.x11.window : X11Window;
				_instance = new X11Window();
			}
			else if(xdg_session_type == "wayland")
			{
				import aurorafw.gui.api.wayland.window : WLWindow;
				_instance = new WLWindow();
			}
		}

		_instance._name = name;
		_instance._wp = wp;
		return _instance;
	}

	import aurorafw.core.input.manager;
	void pollEvents(InputManager inmanager = InputManager());

protected:
	string _name;
	WindowProperties _wp;
}
