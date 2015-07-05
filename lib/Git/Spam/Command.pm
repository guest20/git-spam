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
;


sub run {
    my $self = shift;
    $log->debug('starting');

    use Git::Spam::Community;
    $self->community( Git::Spam::Community->new);

    $self->num_authors(100) if not $self->num_authors;

    for (1..$self->num_authors) {
        my $author = $self->select_author;

        my $author_style = $author->style;
        my ($min,$max) = @{ $author->commits_per_push || [] };
        my $num_commits = $min + int rand ($max-$min);

        $log->infof("Switching to '%s' for %s commits", $author->name, $author->commits_per_push);

        for (1..$num_commits) {
            #$log->infof('%s of %s', $_, $num_commits);

            my $commit = $author->generate_commit;
            $commit->mangle( $self->repo, $author_style );
        }

        if ( $self->should_push ) {
            
        }
    }
    
0
}

sub select_author {
    $_[0]->community->authors('Anna Nemous')
}
1
