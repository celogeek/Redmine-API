package Redmine::API;

# ABSTRACT: Communicate with Redmine thought the API

use strict;
use warnings;
# VERSION

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

__END__

=head1 OVERVIEW

Redmine::API is a module to communicate with Redmine thought the REST::Api.

Any result will be a perl HASH, transformation of the json response into a perl HASH.

=head1 SYNOPSIS

    use Redmine::API;
    my $c = Redmine::API->new('auth_key' => 'MYREDMINE_REST_API_KEY', base_url => 'MYREDMINE_SERVER', trace => 1);

    #this command will POST to MYREDMINE_SERVER/time_entries.json
    #{time_entry => {issue_id => 3, activity_id => 9, hours => 1, comments => 'test'}} in JSON format
    $c->time_entries->time_entry->create(issue_id => 3, activity_id => 9, hours => 1, comments => 'test');
    
    #to get all time_entries
    $c->time_entries->list->all();
    #note that "list" is useless in that case, you can also use time_entry

    #to get one id
    $c->time_entries->time_entry->get(1);

    #to delete one entry
    $c->time_entries->time_entry->del(1);

    #to update one entry
    $c->time_entries->time_entry->update(1, hours => 2);

=head1 NOTES

The Redmine API is not fully complete, and you should use the latest version to have access to the most features.

In the above example, I have access to the issues, so I can found the ID I want, but the activity_id (which is mandatory) has not REST API route.
So you need to know it before sending something. You can also set it by default so the field become not mandatory.

=head1 REST API

The complete doc of the REST API is here :

L<http://www.redmine.org/projects/redmine/wiki/Rest_api>

If the API say : "GET /projects.xml" to get all project, you can do :

    $c->projects->list->all();

If the API say : "GET /projects/:id.:format", you can do :

    $c->projects->project->get(1);

