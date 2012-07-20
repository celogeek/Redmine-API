package Redmine::API::Action;
# ABSTRACT: Action to the API
use strict;
use warnings;
# VERSION
use Moo;
use Carp;
use Data::Dumper;

use Net::HTTP::Spore;
use Net::HTTP::Spore::Middleware::Header;
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
    my ($self) = @_;
    my $request = $self->request;

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
    my ($self) = @_;
    my $api = $self->request->api;

    my $spore = Net::HTTP::Spore->new_from_string($self->_spec, base_url => $api->base_url, trace => $api->trace);
    $spore->enable('Auth::Header',
        header_name => 'X-Redmine-API-Key',
        header_value => $api->auth_key,
    );

    #json for all in and out
    $spore->enable('Header',
        header_name => 'Content-Type',
        header_value => 'application/json',
    );
    $spore->enable('Header',
        header_name => 'Accept',
        header_value => 'application/json',
    );

    #serialize for create (post) and get
    #delete / update (put) don t send data
    $spore->enable_if(sub{$_[0]->method =~ /^GET|POST$/x}, 'Format::JSON');

    return $spore;
}

=method create

Create entry into Redmine.

Args: %data

data is pass thought payload

=cut
sub create {
    my ($self, %data) = @_;
    return $self->_spore->create(payload => {$self->action => \%data});
}

=method all

Get all data from Redmine.

Args: %options

You can pass offset, limit ...

=cut
sub all {
    my ($self, %options) = @_;
    return $self->_spore->all(%options);
}


=method get

Get one entry from Redmine.

Args: $id, %options

=cut
sub get {
    my ($self, $id, %options) = @_;
    return $self->_spore->get(id => $id, %options);
}

=method del

Delete one entry from Redmine

Args: $id

=cut
sub del {
    my ($self, $id) = @_;
    return $self->_spore->del(id => $id);
}

=method update

Update one entry from Redmine

Args: $id, %data

data is pass thought payload to Redmine

=cut

sub update {
    my ($self, $id, %data) = @_;
    return $self->_spore->update(id => $id, payload => encode_json({$self->action => \%data}));
}
1;
