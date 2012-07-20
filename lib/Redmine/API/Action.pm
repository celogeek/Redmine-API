package Redmine::API::Action;
# ABSTRACT: Action to the API
use strict;
use warnings;
# VERSION
use Moo;
use Carp;
use Data::Dumper;

use Net::HTTP::Spore;
use JSON::XS;

has 'request' => (
    is => 'ro',
    isa => sub {
        croak "request should be a Redmine::API::Request object" unless ref $_[0] eq 'Redmine::API::Request';
    },
    required => 1,
);

has 'action' => (
    is => 'ro',
    required => 1,
);

has '_spec' => (
    is => 'lazy',
);
sub _build__spec {
    my $self = shift;
    my $request = $self->request;
    my $api = $request->api;

    my $spec = encode_json({
            version => 1.0,
            methods => {
                'create' => {
                    path => '/'.$request->route.'.json',
                    method => 'POST',
                    authentication => 1,
                },
                'all' => {
                    path => '/'.$request->route.'.json',
                    method => 'GET',
                    authentication => 1,
                },
                'get' => {
                    path => '/'.$request->route.'/:id.json',
                    method => 'GET',
                    authentication => 1,
                },
                'update' => {
                    path => '/'.$request->route.'/:id.json',
                    method => 'PUT',
                    authentication => 1,
                },
                'del' => {
                    path => '/'.$request->route.'/:id.json',
                    method => 'DELETE',
                    authentication => 1,
                },
            },
            api_format => [
                'json',
            ],
            name => 'Redmine',
            author => ['celogeek <me@celogeek.com>'],
            meta => {
                "documentation" => "http://www.redmine.org/projects/redmine/wiki/Rest_api"
            },
    });

    return $spec;
}

has '_spore' => (
    is => 'lazy',
);
sub _build__spore {
    my $self = shift;
    my $api = $self->request->api;

    my $spore = Net::HTTP::Spore->new_from_string($self->_spec, base_url => $api->base_url, trace => $api->trace);
    $spore->enable('Format::JSON');
    $spore->enable('Auth::Header',
        header_name => 'X-Redmine-API-Key',
        header_value => $api->auth_key,
    );

    return $spore;
}

sub create {
    my $self = shift;
    my %data = @_;

    $self->_spore->create(payload => {$self->action => \%data});
}

sub all {
    my $self = shift;
    my %options = @_;
    $self->_spore->all(%options);
}

sub get {
    my $self = shift;
    my ($id, %options) = @_;
    $self->_spore->get(id => $id, %options);
}

sub del {
    my $self = shift;
    my ($id) = @_;
    $self->_spore->del(id => $id);
}

sub update {
    my $self = shift;
    my ($id, %data) = @_;
    $self->_spore->update(id => $id, payload => {$self->action => \%data});
}
1;
