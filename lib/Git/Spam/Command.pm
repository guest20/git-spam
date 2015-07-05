package Git::Spam::Command;
#
#ABSTRACT: the git-spam program, see bin/git-spam for details;
#

use warnings; use strict;

use Log::Any qw($log);

use Object::Tiny::RW 
    should_push             => #

    num_authors             => # generate commits from this many authors

    community               => # Git::Spam::Community 

    repo                    => # Git::Repository object

    _odds_for_authors        => # [ array of authors names over and over again ]
;


sub run {
    my $self = shift;
    $log->debug('starting');

    use Git::Spam::Community;
    $self->community( Git::Spam::Community->new);

    $self->num_authors(100) if not $self->num_authors;

    # change authors back and forth
    for (1..$self->num_authors) {

        #TODO: create branches, move to the next author, and then merge the branch

        my $author = $self->select_author;

        my $author_style = $author->style;
        my ($min,$max) = @{ $author->commits_per_push || [] };
        my $num_commits = $min + int rand ($max-$min);

        $log->infof("Switching to '%s' for %s commits", $author->name, $author->commits_per_push);

        # mangle the repo, and commit the changes.
        for (1..$num_commits) {
            my $commit = $author->generate_commit;
            $commit->mangle( $self->repo, $author_style );
        }

        if ( $self->should_push ) {
            $self->repo->run('push');
            #TODO: error checking, rebase etc
        }
    }
    
    return my $exit = 0
}

sub select_author {
    my $self = shift;
    
    my @odds = @{ $self->_odds_for_authors || [] };
    unless (@odds) {
        my $authors = $self->community->authors;
        for my $author (keys %$authors) {
            push @odds, ($author) x $authors->{$author}{weight}
        }
        $self->_odds_for_authors( \@odds );
    }
    
    return $self->community->authors(
        $odds[ rand @odds ]
    );
}
1
