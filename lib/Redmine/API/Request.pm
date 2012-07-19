package Redmine::API::Request;
# ABSTRACT: handle request to the Redmine API
use strict;
use warnings;
# VERSION
use Carp;
use Data::Dumper;

use Moo;
use Redmine::API::Action;

use vars qw/$AUTOLOAD/;

sub AUTOLOAD {
    my $self = shift;
    my $route = substr($AUTOLOAD, length(__PACKAGE__) + 2);
    return if $route eq 'DESTROY';
    Redmine::API::Action->new(request => $self, action => $route);
}

has 'api' => (
    is => 'ro',
    required => 1,
    isa => sub {
        croak "api should be a Redmine::API object" if ref $_[0] ne 'Redmine::API';
    }
);

has 'route' => (
    is => 'ro',
    required => 1,
);

1;
