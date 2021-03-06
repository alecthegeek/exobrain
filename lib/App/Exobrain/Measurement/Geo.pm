package App::Exobrain::Measurement::Geo;

# ABSTRACT: Geo measurement packet

# VERSION

use 5.010;
use autodie;
use Moose;
use Method::Signatures;

# Declare that we will have a summary attribute. This is to make
# our roles happy.
sub summary;

# This needs to happen at begin time so it can add the 'payload'
# keyword.
BEGIN { with 'App::Exobrain::Message'; }

=head1 DESCRIPTION

A standard form of measuring a geolocation, which may be
from Foursquare, brightkite, twitter, facebook, or anything
else that lets us snoop on poeple.

Eg:

    $exobrain->measure('Geo',
        source => 'Foursquare',
        user    => 'pjf',
        user_name => 'Paul Fenwick',
        is_me   => 1,
        poi     => App::Exobrain::Measurement::Geo::POI->new(
            id   => 'abc01234ff',
            name => 'Some place',
        )
        message => 'Drinking a coffee',
    );

In the future C<user> and C<user_name> may be combined into
a user object.

=cut

payload user     => ( isa => 'Str' );    # User on that service
payload user_name=> ( isa => 'Str', required => 0);
payload poi      => ( isa => 'App::Exobrain::Measurement::Geo::POI' );    # Point of interest
payload is_me    => ( isa => 'Bool' );   # Is this the current user?
payload message  => ( isa => 'Str', required => 0);  # Any message with checkin

has summary => (
    isa => 'Str', builder => '_build_summary', lazy => 1, is => 'ro'
);

has '+namespace' => ( is => 'ro', isa => 'Str', default => 'GEO' );

method _build_summary() {

    my $fmt_msg = "";

    if (my $message = $self->message) {
        $fmt_msg = qq{with message: "$message"};
    }
    return join(" ",
        $self->user_name || $self->user, 'is at', $self->poi->name,
        $fmt_msg,
        '( via', $self->source, ')', ($self->is_me ? "[Me]" : ""),
    );
}

package App::Exobrain::Measurement::Geo::POI;

use Moose;

# Practically a stub class for now.

has id   => (is => 'ro', isa => 'Str', required => 1);
has name => (is => 'ro', isa => 'Str', required => 1);

no Moose;

1;
