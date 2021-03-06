package App::Exobrain;

use v5.010;
use strict;
use warnings;
use autodie;
use Moose;
use Method::Signatures;

# ABSTRACT: Core Exobrain accessor class

# VERSION: Generated by DZP::OurPkg:Version

use App::Exobrain::Bus;
use App::Exobrain::Config;
use App::Exobrain::Message;
use App::Exobrain::Message::Raw;

has 'config' => (
    is => 'ro',
    isa => 'App::Exobrain::Config',
    builder => '_build_config',
);

# Pub/Sub interfaces to our bus. These don't get generated unless
# our end code actually asks for them. Many things will only require
# one, or will use higher-level functions to do their work.

has 'pub' => (
    is => 'ro',
    isa => 'App::Exobrain::Bus',
    builder => '_build_pub',
    lazy => 1,
);

has 'sub' => (
    is => 'ro',
    isa => 'App::Exobrain::Bus',
    builder => '_build_sub',
    lazy => 1,
);

sub _build_config { return App::Exobrain::Config->new; };
sub _build_pub    { return App::Exobrain::Bus->new(type => 'PUB', exobrain => shift) }
sub _build_sub    { return App::Exobrain::Bus->new(type => 'SUB', exobrain => shift) }

=method message

    $exobrain->message( ... )->send;

Shortcut to create a 'raw' message. The exobrain parameter will be passed
to the class constructor automatically.

=cut

method message(@args) {
    return App::Exobrain::Message::Raw->new(
        exobrain => $self,
        @args,
    );
}

use constant CLASS_PREFIX => 'App::Exobrain::';

method message_class($class, @args) {
    $class = CLASS_PREFIX . $class;

    eval "require $class";
    die $@ if $@;

    return $class->new(
        exobrain => $self,
        @args,
    );
}

=method measure

    $exobrain->measure( 'Mailbox',
        count  => 42,
        user   => 'pjf',
        server => 'imap.example.com',
        fodler => 'INBOX',
    )->send;

Preferred shortcut for creating a measurement of the desired class. The
C<exobrain> parameter will be passed to the measurement class constructor
automatically.

=cut

use constant MEASURE_PREFIX => CLASS_PREFIX . 'Measurement::';

method measure($type, @args) {
    my $class = MEASURE_PREFIX . $type;

    eval "require $class";
    die $@ if $@;

    return $class->new(
        exobrain => $self,
        @args,
    );
}

=for Pod::Coverage BUILD DEMOLISH

=cut

1;
