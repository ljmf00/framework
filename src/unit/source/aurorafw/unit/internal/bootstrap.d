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

module aurorafw.unit.internal.bootstrap;

package(aurorafw.unit):
version(unittest):

import core.runtime : Runtime, UnitTestResult;
import std.parallelism : TaskPool, totalCPUs;
import std.range.primitives;
import std.stdio : writeln, stdout;
import std.ascii : newline;
import std.format : format;
import std.algorithm.iteration : filter;
import std.getopt : getopt;
import std.traits;

import aurorafw.unit.internal.test;
import aurorafw.unit.internal.runner;
import aurorafw.unit.internal.console;

private Test[] getTests()()
{
	Test[] tests;
	static if(__traits(compiles, () {static import dub_test_root;})) {
		static import dub_test_root;
		foreach(m; dub_test_root.allModules)
		{
			import std.traits : fullyQualifiedName, isAggregateType;
			static if(__traits(compiles, __traits(getUnitTests, m)) &&
					!(__traits(isTemplate, m) || (__traits(compiles, isAggregateType!m) && isAggregateType!m))) {
				alias module_ = m;
			} else {
				import std.meta : Alias;
				// For cases when module contains member of the same name
				alias module_ = Alias!(__traits(parent, m));
			}

			foreach(test; __traits(getUnitTests, module_))
				tests ~= Test(Test.Unit(fullyQualifiedName!test, getTestName!test, &test));

			// Unittests in structs and classes
			foreach(member; __traits(derivedMembers, module_))
				static if(__traits(compiles, __traits(parent, __traits(getMember, module_, member))) &&
					__traits(isSame, __traits(parent, __traits(getMember, module_, member)), module_) &&
					__traits(compiles, __traits(getUnitTests, __traits(getMember, module_, member))))
						foreach(test; __traits(getUnitTests, __traits(getMember, module_, member)))
							tests ~= Test(Test.Unit(fullyQualifiedName!test, getTestName!test, &test));
		}
	} else {
		foreach(m; ModuleInfo)
			if(m && m.unitTest)
				tests ~= Test(Test.Unit(m.name, null, m.unitTest));
	}

	return tests;
}

shared static this() {
	Runtime.extendedModuleUnitTester = () {
		bool isVerbose;
		shared size_t passed, failed;
		uint threadNumber;
		string include, exclude;

		{
			auto args = Runtime.args;

			auto getoptResult = args.getopt(
				"no-colours",
					"Disable colours",
					&noColours,
				"v|verbose",
					"Show verbose output (full stack traces and durations)",
					&isVerbose,
				"t|threads",
					"Show verbose output (full stack traces and durations)",
					&threadNumber,
				"i|include",
					"Run tests if their name matches specified regular expression",
					&include,
				"e|exclude",
					"Skip tests if their name matches specified regular expression",
					&exclude
			);

			if(getoptResult.helpWanted)
			{
				import std.string : leftJustifier;
				stdout.writefln("Usage:%1$s\t%2$s -- <options>%1$s%1$sOptions:", newline, args.front);

				foreach(option; getoptResult.options)
					stdout.writefln("  %s\t%s\t%s", option.optShort, option.optLong.leftJustifier(20), option.help);

				return UnitTestResult(0, 0, false, false);
			}
		}

		import std.regex : matchFirst;
		import std.array;

		Test[] tests = getTests!()
			.filter!(t => (!include && !exclude) ||
					(include && !(t.test.fullName ~ " " ~ t.test.testName).matchFirst(include).empty) ||
					(exclude && (t.test.fullName ~ " " ~ t.test.testName).matchFirst(exclude).empty)
				).array;

		import core.atomic : atomicOp;

		auto started = MonoTime.currTime;

		if(threadNumber > 1)
		{
			with(new TaskPool(threadNumber-1)) {
				foreach(ref test; parallel(tests))
				{
					runTest(test, isVerbose);
					atomicOp!"+="(test.status ? passed : failed, 1UL);
				}

				finish(true);
			}

		}
		else
		{
			foreach(ref test; tests)
			{
				runTest(test, isVerbose);
				atomicOp!"+="(test.status ? passed : failed, 1UL);
			}
		}

		stdout.writeln;
		stdout.writefln("%s: %s passed, %s failed in %d ms",
			Console.emphasis("Summary"),
			Console.colour(passed, Colour.ok),
			Console.colour(failed, failed ? Colour.achtung : Colour.none),
			(MonoTime.currTime - started).total!"msecs",
		);

		return UnitTestResult(passed + failed, passed, false, false);
	};
}
