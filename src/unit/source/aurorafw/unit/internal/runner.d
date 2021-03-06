/*
                                    __
                                   / _|
  __ _ _   _ _ __ ___  _ __ __ _  | |_ ___  ___ ___
 / _` | | | | '__/ _ \| '__/ _` | |  _/ _ \/ __/ __|
| (_| | |_| | | | (_) | | | (_| | | || (_) \__ \__ \
 \__,_|\__,_|_|  \___/|_|  \__,_| |_| \___/|___/___/

Copyright (C) 2019 Anton Fediushin
Copyright (C) 2019 Aurora Free Open Source Software.
Copyright (C) 2019 Luís Ferreira <luis@aurorafoss.org>

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
https://www.gnu.org/licenses/gpl-3.0.html.

NOTE: All products, services or anything associated to trademarks and
service marks used or referenced on this file are the property of their
respective companies/owners or its subsidiaries. Other names and brands
may be claimed as the property of others.

For more info about intellectual property visit: aurorafoss.org or
directly send an email to: contact (at) aurorafoss.org .

This file was based on silly runner.
More about silly: https://gitlab.com/AntonMeep/silly
*/

module aurorafw.unit.internal.runner;

package(aurorafw.unit):
version(unittest):

import std.datetime;
import aurorafw.unit.internal.test;
import core.exception : AssertError;
import std.stdio : stdout;
import aurorafw.unit.internal.console;
import std.string : lastIndexOf, lineSplitter;
import std.format : formattedWrite;
import std.ascii : newline;
import std.range : drop;
import std.algorithm : canFind;

void runTest(ref Test testCase, bool isVerbose)
{

	auto started = MonoTime.currTime;

	try {
		scope(exit) testCase.duration = MonoTime.currTime - started;
		testCase.test.testFunc();
		testCase.status = true;
	} catch(Throwable t)
	{
		if(!(cast(Exception) t || cast(AssertError) t))
			throw t;

		foreach(th; t) {
			immutable(string)[] trace;
			foreach(i; th.info)
				trace ~= i.idup;

			testCase.thrown ~= Test.Thrown(typeid(th).name, th.message.idup, th.file, th.line, trace);
		}
	}

	auto writer = stdout.lockingTextWriter;

	writer.formattedWrite(" %s %s %s",
		testCase.status
			? Console.colour("✓", Colour.ok)
			: Console.colour("✗", Colour.achtung),
		Console.emphasis(Console.truncateName(testCase.test.fullName[0..testCase.test.fullName.lastIndexOf('.')], isVerbose)),
		testCase.test.testName,
	);

	if(isVerbose)
		writer.formattedWrite(" (%.3f ms)", (cast(real) testCase.duration.total!"usecs") / 10.0f ^^ 3);

	writer.put(newline);
	foreach(th; testCase.thrown) {
		writer.formattedWrite("    %s thrown from %s on line %d: %s%s",
			th.type,
			th.file,
			th.line,
			th.msg.lineSplitter.front,
			newline,
		);

		foreach(line; th.msg.lineSplitter.drop(1))
			writer.formattedWrite("      %s%s", line, newline);

		writer.formattedWrite("    --- Stack trace ---%s", newline);
		if(isVerbose) {
			foreach(line; th.info)
				writer.formattedWrite("    %s%s", line, newline);
		} else {
			for(size_t i = 0; i < th.info.length && !th.info[i].canFind(__FILE__); ++i)
				writer.formattedWrite("    %s%s", th.info[i], newline);
		}
	}
}
