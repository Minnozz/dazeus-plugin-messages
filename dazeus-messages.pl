#!/usr/bin/perl
# Messages plugin for DaZeus
# Copyright (C) 2014-2015  Aaron van Geffen <aaron@aaronweb.net>
# 'Je moeder' function (C) 2010 Pen-Pen, 2013 Quis
# Original module (C) 2007  Sjors Gielen <sjorsgielen@gmail.com>

use strict;
use warnings;
use DaZeus;

my ($socket) = @ARGV;

if (!$socket) {
	warn "Usage: $0 socket\n";
	exit 1;
}

my $dazeus = DaZeus->connect($socket);

#####################################################################
#                       CONTROLLER FUNCTIONS
#####################################################################

# Test!
$dazeus->subscribe_command("test" => sub {
	my ($self, $network, $sender, $channel, @rest) = @_;
	reply("Test back - I think it works.", $network, $sender, $channel);
});

# Hey?
$dazeus->subscribe_command("hey" => sub {
	my ($self, $network, $sender, $channel, @rest) = @_;
	reply("Hey $sender!", $network, $sender, $channel);
});

# Hi?
$dazeus->subscribe_command("hi" => sub {
	my ($self, $network, $sender, $channel, @rest) = @_;
	reply("Hi $sender!", $network, $sender, $channel);
});

# Hello?
$dazeus->subscribe_command("hello" => sub {
	my ($self, $network, $sender, $channel, @rest) = @_;
	reply("Hello $sender!", $network, $sender, $channel);
});

# Ping?
$dazeus->subscribe_command("ping" => sub {
	my ($self, $network, $sender, $channel, @rest) = @_;
	reply("Pong!", $network, $sender, $channel);
});

# Pong?
$dazeus->subscribe_command("pong" => sub {
	my ($self, $network, $sender, $channel, @rest) = @_;
	reply("Ping!", $network, $sender, $channel);
});

# Borsatofy?
$dazeus->subscribe_command("b" => sub {
	my ($self, $network, $sender, $channel, $command, $line) = @_;
	my $verb = $line eq "" ? "Binnen" : ucfirst($line);
	reply("$verb~~~ $verb in m'n hart, $verb in m'n ziel~~~", $network, $sender, $channel);
});

# Mo?
$dazeus->subscribe_command("mo" => sub {
	my ($self, $network, $sender, $channel, $command, $line) = @_;
	$line = "winkel" if $line eq "";
	reply("Dat is niet mijn $line, vriend!", $network, $sender, $channel);
});

# Sarcasm sign?
$dazeus->subscribe_command("sarcasm" => sub {
	my ($self, $network, $sender, $channel, @rest) = @_;
	reply("+-------+\n|Sarcasm|\n+---+---+\n    | (o.o;\n    o=", $network, $sender, $channel);
});

# Ordering something?
$dazeus->subscribe_command("order" => sub {
	my ($self, $network, $sender, $channel, $command, $line) = @_;
	my ($what, $forwhom) = $line =~ /^(.+?)\sfor\s(.+)$/i;

	if (!defined($what)) {
		# Didn't match -- maybe they forgot 'for $somebody'.
		$what = $line;
		$forwhom = $sender;
	}
	if (!defined($what)) {
		# Still didn't match -- they probably just said '}order'.
		reply("Syntax error. Please say }order [something] for [somebody].", $network, $sender, $channel);
	}

	$dazeus->action($network, $channel, "slides $what down the bar to $forwhom.", $network, $sender, $channel);
});

# Oprah?
$dazeus->subscribe_command("oprah" => sub {
	my ($self, $network, $sender, $channel, $command, $line) = @_;
	$line = "car" if $line eq "";
	reply("You get a $line! You get a $line! Everybody gets a $line!", $network, $sender, $channel);
});

# Villa Volta?
$dazeus->subscribe_command("vv" => sub {
	my ($self, $network, $sender, $channel, $command, $line) = @_;
	$line = "huis" if $line eq "";
	reply("Dit $line, dit vervloekte $line...", $network, $sender, $channel);
});

# Fetch the hilight character(s).
my $sigil = $dazeus->getConfig("core", "highlight");

# Remember messages potentially concerning your mother.
my %lastJeMoederableMessages;

$dazeus->subscribe("PRIVMSG" => sub {
	my ($self, $event) = @_;
	my ($network, $sender, $channel, $msg) = @{$event->{params}};

	# As long as the message isn't a command or factoid request, save it.
	if (substr($msg, 0, length($sigil)) ne $sigil && substr($msg, 0, 1) ne "]" && $channel ne $dazeus->getNick($network)) {
		if ($msg =~ /\b(is|ben|bent|zijn|was|waren|hebben|heeft|hebt|heb)\s+(.*)$/i) {
			$lastJeMoederableMessages{$channel} = $2;
		} else {
			$lastJeMoederableMessages{$channel} = $msg;
		}
	}
});

# Send 'witty' replies concerning your mother.
$dazeus->subscribe_command("m" => sub {
	my ($self, $network, $sender, $channel, $command, $line) = @_;

	# Look up a previously saved message for this channel.
	if ($line eq "" && defined($lastJeMoederableMessages{$channel})) {
		$line = $lastJeMoederableMessages{$channel};
	}

	# Anything interesting to add?
	if ($line eq "") {
		reply("Je moeder is een null-pointer!", $network, $sender, $channel);
	} else {
		reply("Je moeder is $line!", $network, $sender, $channel);
	}
});

# Or, indeed, your father...
$dazeus->subscribe_command("v" => sub {
	my ($self, $network, $sender, $channel, $command, $line) = @_;

	# Look up a previously saved message for this channel.
	if ($line eq "" && defined($lastJeMoederableMessages{$channel})) {
		$line = $lastJeMoederableMessages{$channel};
	}

	# Anything interesting to add?
	if ($line eq "") {
		reply("Je vader is een null-pointer!", $network, $sender, $channel);
	} else {
		reply("Je vader is $line!", $network, $sender, $channel);
	}
});

while($dazeus->handleEvents()) {}

#####################################################################
#                       MODEL FUNCTIONS
#####################################################################

sub reply {
	my ($response, $network, $sender, $channel) = @_;

	if ($channel eq $dazeus->getNick($network)) {
		$dazeus->message($network, $sender, $response);
	} else {
		$dazeus->message($network, $channel, $response);
	}
}
