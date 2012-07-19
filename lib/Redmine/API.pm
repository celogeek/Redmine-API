package Redmine::API;

# ABSTRACT: Communicate with Redmine thought the API

use strict;
use warnings;
# VERSION
use Data::Dumper;
use Carp;

use Moo;
use Redmine::API::Request;

use vars qw/$AUTOLOAD/;
sub AUTOLOAD {
    my $self = shift;
    my $route = substr($AUTOLOAD, length(__PACKAGE__) + 2);
    return if $route eq 'DESTROY';
    return Redmine::API::Request->new(api => $self, route => $route);
}

has 'auth_key' => (
    is => 'ro',
    required => 1,
);

has 'base_url' => (
    is => 'ro',
    required => 1,
);

has 'trace' => (
    is => 'ro',
    default => sub { 0 },
);

1;
