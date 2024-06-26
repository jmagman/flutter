// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_tools/executable.dart' as executable;
import 'package:flutter_tools/src/runner/flutter_command.dart';
import 'package:flutter_tools/src/runner/flutter_command_runner.dart';

import '../src/common.dart';
import '../src/context.dart';
import '../src/testbed.dart';

class CommandDummy extends FlutterCommand{
  @override
  String get description => 'description';

  @override
  String get name => 'test';

  @override
  Future<FlutterCommandResult> runCommand() async {
    return FlutterCommandResult.success();
  }
}

void main() {
  test('Help for command line arguments is consistently styled and complete', () => Testbed().run(() {
    final FlutterCommandRunner runner = FlutterCommandRunner(verboseHelp: true);
    executable.generateCommands(
      verboseHelp: true,
      verbose: true,
    ).forEach(runner.addCommand);
    verifyCommandRunner(runner);
  }));

  testUsingContext('String? safe argResults', () async {
    final CommandDummy command = CommandDummy();
    final FlutterCommandRunner runner = FlutterCommandRunner(verboseHelp: true);
    command.argParser.addOption('key');
    runner.addCommand(command);
    await runner.run(<String>['test', '--key=value']);

    expect(command.stringArg('key'), 'value');
    expect(command.stringArg('empty'), null);

    expect(command.stringArgDeprecated('key'), 'value');
    expect(() => command.stringArgDeprecated('empty'), throwsA(const TypeMatcher<ArgumentError>()));
  });
}

void verifyCommandRunner(CommandRunner<Object> runner) {
  expect(runner.argParser, isNotNull, reason: '${runner.runtimeType} has no argParser');
  expect(runner.argParser.allowsAnything, isFalse, reason: '${runner.runtimeType} allows anything');
  expect(runner.argParser.allowTrailingOptions, isFalse, reason: '${runner.runtimeType} allows trailing options');
  verifyOptions(null, runner.argParser.options.values);
  runner.commands.values.forEach(verifyCommand);
}

void verifyCommand(Command<Object> runner) {
  expect(runner.argParser, isNotNull, reason: 'command ${runner.name} has no argParser');
  verifyOptions(runner.name, runner.argParser.options.values);
  if (runner.hidden == false && runner.parent == null) {
    expect(
      runner.category,
      anyOf(
        FlutterCommandCategory.sdk,
        FlutterCommandCategory.project,
        FlutterCommandCategory.tools,
      ),
      reason: "top-level command ${runner.name} doesn't have a valid category",
    );
  }

  runner.subcommands.values.forEach(verifyCommand);
}

// Patterns for arguments names.
final RegExp _allowedArgumentNamePattern = RegExp(r'^([-a-z0-9]+)$');
final RegExp _allowedArgumentNamePatternForPrecache = RegExp(r'^([-a-z0-9_]+)$');
final RegExp _bannedArgumentNamePattern = RegExp(r'-uri$');

// Patterns for help messages.
final RegExp _bannedLeadingPatterns = RegExp(r'^[-a-z]', multiLine: true);
final RegExp _allowedTrailingPatterns = RegExp(r'([^ ][.!:]\)?|: https?://[^ ]+[^.]|^)$');
final RegExp _bannedQuotePatterns = RegExp(r" '|' |'\.|\('|'\)|`");
final RegExp _bannedArgumentReferencePatterns = RegExp(r'[^"=]--[^ ]');
final RegExp _questionablePatterns = RegExp(r'[a-z]\.[A-Z]');
final RegExp _bannedUri = RegExp(r'\b[Uu][Rr][Ii]\b');
const String _needHelp = "Every option must have help explaining what it does, even if it's "
                         'for testing purposes, because this is the bare minimum of '
                         'documentation we can add just for ourselves. If it is not intended '
                         'for developers, then use "hide: !verboseHelp" to only show the '
                         'help when people run with "--help --verbose".';

const String _header = ' Comment: ';

void verifyOptions(String command, Iterable<Option> options) {
  String target;
  if (command == null) {
    target = 'the global argument "';
  } else {
    target = '"flutter $command ';
  }
  assert(target.contains('"'));
  for (final Option option in options) {
    // If you think you need to add an exception here, please ask Hixie (but he'll say no).
    if (command == 'precache') {
      expect(option.name, matches(_allowedArgumentNamePatternForPrecache), reason: '$_header$target--${option.name}" is not a valid name for a command line argument. (Is it all lowercase?)');
    } else {
      expect(option.name, matches(_allowedArgumentNamePattern), reason: '$_header$target--${option.name}" is not a valid name for a command line argument. (Is it all lowercase? Does it use hyphens rather than underscores?)');
    }
    expect(option.name, isNot(matches(_bannedArgumentNamePattern)), reason: '$_header$target--${option.name}" is not a valid name for a command line argument. (We use "--foo-url", not "--foo-uri", for example.)');
    expect(option.hide, isFalse, reason: '${_header}Help for $target--${option.name}" is always hidden. $_needHelp');
    expect(option.help, isNotNull, reason: '${_header}Help for $target--${option.name}" has null help. $_needHelp');
    expect(option.help, isNotEmpty, reason: '${_header}Help for $target--${option.name}" has empty help. $_needHelp');
    expect(option.help, isNot(matches(_bannedLeadingPatterns)), reason: '${_header}A line in the help for $target--${option.name}" starts with a lowercase letter. For stylistic consistency, all help messages must start with a capital letter.');
    expect(option.help, isNot(startsWith('(Deprecated')), reason: '${_header}Help for $target--${option.name}" should start with lowercase "(deprecated)" for consistency with other deprecated commands.');
    expect(option.help, isNot(startsWith('(Required')), reason: '${_header}Help for $target--${option.name}" should start with lowercase "(required)" for consistency with other deprecated commands.');
    expect(option.help, isNot(contains('?')), reason: '${_header}Help for $target--${option.name}" has a question mark. Generally we prefer the passive voice for help messages.');
    expect(option.help, isNot(contains('Note:')), reason: '${_header}Help for $target--${option.name}" uses "Note:". See our style guide entry about "empty prose".');
    expect(option.help, isNot(contains('Note that')), reason: '${_header}Help for $target--${option.name}" uses "Note that". See our style guide entry about "empty prose".');
    expect(option.help, isNot(matches(_bannedQuotePatterns)), reason: '${_header}Help for $target--${option.name}" uses single quotes or backticks instead of double quotes in the help message. For consistency we use double quotes throughout.');
    expect(option.help, isNot(matches(_questionablePatterns)), reason: '${_header}Help for $target--${option.name}" may have a typo. (If it does not you may have to update args_test.dart, sorry. Search for "_questionablePatterns")');
    if (option.defaultsTo != null) {
      expect(option.help, isNot(contains('Default')), reason: '${_header}Help for $target--${option.name}" mentions the default value but that is redundant with the defaultsTo option which is also specified (and preferred).');

      if (option.allowedHelp != null) {
        for (final String allowedValue in option.allowedHelp.keys) {
          expect(
            option.allowedHelp[allowedValue],
            isNot(anyOf(contains('default'), contains('Default'))),
            reason: '${_header}Help for $target--${option.name} $allowedValue" mentions the default value but that is redundant with the defaultsTo option which is also specified (and preferred).',
          );
        }
      }
    }
    expect(option.help, isNot(matches(_bannedArgumentReferencePatterns)), reason: '${_header}Help for $target--${option.name}" contains the string "--" in an unexpected way. If it\'s trying to mention another argument, it should be quoted, as in "--foo".');
    for (final String line in option.help.split('\n')) {
      if (!line.startsWith('    ')) {
        expect(line, isNot(contains('  ')), reason: '${_header}Help for $target--${option.name}" has excessive whitespace (check e.g. for double spaces after periods or round line breaks in the source).');
        expect(line, matches(_allowedTrailingPatterns), reason: '${_header}A line in the help for $target--${option.name}" does not end with the expected period that a full sentence should end with. (If the help ends with a URL, place it after a colon, don\'t leave a trailing period; if it\'s sample code, prefix the line with four spaces.)');
      }
    }
    expect(option.help, isNot(endsWith(':')), reason: '${_header}Help for $target--${option.name}" ends with a colon, which seems unlikely to be correct.');
    expect(option.help, isNot(contains(_bannedUri)), reason: '${_header}Help for $target--${option.name}" uses the term "URI" rather than "URL".');
    // TODO(ianh): add some checking for embedded URLs to make sure we're consistent on how we format those.
    // TODO(ianh): arguably we should ban help text that starts with "Whether to..." since by definition a flag is to enable a feature, so the "whether to" is redundant.
  }
}
