package Git::Spam::Command;
#
#ABSTRACT: the git-spam program, see bin/git-spam for details;
#

use warnings; use strict;
use Object::Tiny::RW 
    should_push             => #
    should_push_each_commit => # 

    num_authors             => # generate commits from this many authors

    community               => # Git::Spam::Community 

    repo                    => # Git::Repository object
;

sub run {
    my $self = shift;

    use Git::Spam::Community;
    $self->community(
        Git::Spam::Community->new
    );

    $self->num_authors(1) if not $self->num_authors;

    for (1..$self->num_authors) {
        my $author = $self->select_author;
        my $author_style = $author->style;
        # for 1..$self->num_commits_per

        my $commit = $author->generate_commit;
        my $ci     = $author_style->format_message( $commit );

        $commit->mangle( $self->repo );

        print $ci;
        #}
    }
0
}

sub select_author { $_[0]->community->authors('me') }
1
