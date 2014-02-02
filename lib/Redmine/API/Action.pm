package Redmine::API::Action;
# ABSTRACT: Action to the API
use strict;
use warnings;
# VERSION
use Moo;

use Carp;
use JSON;
use REST::Client;

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

has '_rest_cli' => (
  is => 'lazy'
);

sub _build__rest_cli {
  my ($self) = @_;
  my $api = $self->request->api;

  my $cli = REST::Client->new();
  $cli->setHost($api->base_url);
  $cli->addHeader('X-Redmine-API-Key' => $api->auth_key);
  $cli->addHeader('Content-Type' => 'application/json');
  $cli->addHeader('Accept' => 'application/json');
  return $cli;

}

=method create

Create entry into Redmine.

Args: %data

data is pass thought payload

=cut
sub create {
    my ($self, %data) = @_;
    return $self->formatResponse(
      $self->_rest_cli->POST(
        '/' . $self->request->route . '.json',
        encode_json({$self->action => \%data}),
      )
    );
}

=method all

Get all data from Redmine.

Args: %options

You can pass offset, limit ...

=cut
sub all {
    my ($self, %options) = @_;
    return $self->formatResponse($self->_rest_cli->GET('/' . $self->request->route . '.json' . $self->_rest_cli->buildQuery(\%options)));
}


=method get

Get one entry from Redmine.

Args: $id, %options

=cut
sub get {
    my ($self, $id, %options) = @_;
    return $self->formatResponse($self->_rest_cli->GET('/' . $self->request->route . '/' . $id . '.json' . $self->_rest_cli->buildQuery(\%options)));
}

=method del

Delete one entry from Redmine

Args: $id

=cut
sub del {
    my ($self, $id) = @_;
    return $self->formatResponse($self->_rest_cli->DELETE('/' . $self->request->route . '/' . $id . '.json'));
}

=method update

Update one entry from Redmine

Args: $id, %data

data is pass thought payload to Redmine

=cut

sub update {
    my ($self, $id, %data) = @_;
    return $self->formatResponse(
      $self->_rest_cli->PUT(
        '/' . $self->request->route . '/' . $id . '.json',
        encode_json({$self->action => \%data}),
      )
    );
}

=method formatResponse

return response except if the message has not the right status

=cut

sub formatResponse {
  my ($self, $req) = @_;

  return {} if $req->responseCode == 404;

  croak "ERROR ", $req->responseCode, " : ACCESS FORBIDDEN, CHECK YOUR TOKEN !" if $req->responseCode == 401;  
  croak "ERROR ", $req->responseCode, " : ", $req->responseContent if $req->responseCode >= 500;

  return {} if !length($req->responseContent);

  my $resp;
  if (! eval{ $resp = decode_json($req->responseContent); 1 }) {
    croak "Bad JSON format : ", $req->responseContent;
  }

  return $resp;
}

1;
