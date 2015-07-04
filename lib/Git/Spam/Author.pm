package Git::Spam::Author;
use warnings; use strict;

use Object::Tiny::RW qw[ 
    community
    name

];

# gives you back a hash-based object, representing a commit (that hasn't happened yet)
# $author->generate_commit( $repo );
#
sub style {
    $_[0]->community->commit_styles(
        $_[0]->{style}
    )
}
sub generate_commit {
    my ($self, $repo) = @_;

    my $author   = $self;
    my $style    = $self->style;
    my $language = $self->community->languages->{ $author->{language} };

    use Data::Dumper;
    print Dumper [$author, $language ];

    my $commit = {
        subject => [],
        body => [],
        author => $self,
    };

    push @{ $commit->{subject} }, split ' ', $language->[ rand @$language ]
        until @{ $commit->{subject} } > $author->{content}{subject}{words};

    while ( @{ $commit->{body} } < $author->{content}{body}{paras} ) { 
        my $para = [];
        #TODO: sentences in paragraphs, and some casing stuff
        push @$para, split ' ', $language->[ rand @$language ]
            until @$para > $author->{content}{body}{para_size};

        push @{ $commit->{body} }, $para;
    }

    use Git::Spam::Commit;
    return Git::Spam::Commit->new( %$commit )
}


1
