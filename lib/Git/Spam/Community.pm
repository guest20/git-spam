package Git::Spam::Community;
#
#ABSTRACT: Represents a collection of authors / commit styles / etc
#

use warnings; use strict;
use YAML::Syck qw[ Load ];

use Object::Tiny::RW qw[ 
    _authors
    _world
    _languages
    _commit_styles
];

sub _init { # load everything from DATA

    my $self = shift;

    unless ($self->_world) {
        # load it up
        my $world= Load( do{ local $/; <DATA> } );
        $self->_world( $world );
    }

}
sub languages {
    my $self = shift;
    my $language = shift;
    unless ($self->_languages) {
        $self->_init;
        $self->_languages( $self->_world->{language} )
    }
    if ($language) {
        die sprintf "'$language' is not a language, try [%s]",
        $language,
        join ',', keys %{ $self->_languages}
            if not exists $self->_languages->{$language};

        return $self->_languages->{$language}
    }
    $self->_languages
    
}

sub commit_styles {
    my $self = shift;
    my $style = shift;

    unless ($self->_commit_styles) {
        $self->_init;

        my $commit_styles = $self->_world->{styles};

        use Git::Spam::CommitStyle;
        $self->_commit_styles(
            {
            map {
                $_ => Git::Spam::CommitStyle->new(
                        %{ $commit_styles->{$_} },
                        community => $self,
                )
            } keys %{ $commit_styles }
            }
        );
        
    }

    if ($style) {
        die sprintf "no style called '%s', try one of [%s]", 
            $style, keys %{ $self->_commit_styles }
                if not exists $self->_commit_styles->{$style};

        return $self->_commit_styles->{$style} 
    }
    return $self->_commit_styles
}
sub authors {
    my $self = shift;
    my $author = shift;

    unless ($self->_authors) {
        $self->_init;

        my $authors = $self->_world->{authors};

        use Git::Spam::Author;
        $self->_authors(
            {
            map {
                $_ => Git::Spam::Author->new(
                        %{ $authors->{$_} },
                        community => $self,
                        name => $_,
                )
            } keys %{ $authors }
            }
        );
        
    }

    if ($author) {
        die sprintf "no author called '%s', try one of [%s]", 
            $author, keys %{ $self->_authors }
                if not exists $self->_authors->{$author};

        return $self->_authors->{$author} 
    }
    return $self->_authors
}
1

__DATA__
---
styles:
    chris_beams:
        Cite: "http://chris.beams.io/posts/git-commit/"
        Flags:
            subject: 
                max: 50
                ending: off
                ucfirst: on
                when: always
            body: 
                wrap:72
            paragraphs: blank
            tone: imperative
    oneline:
        Cite: jerks
        Flags:
            subject: 
                when: never
            body:
                wrap: no
authors:
    Anna Nemous:
        email: "Anna.Nemous@example.com"
        style: chris_beams
        commits_per_push:
            - 1
            - 5
        content: 
            subject:
                words: 20
                word_fuzz: 0
                
            body:
                paras: 3
                para_fuzz: 0
                para_size: 50
                para_size_fuzz: 0
            length: 4lines
        language: en_AU
        weight: 5

    Spammy McJerkerson:
        email: spammy@gmail.example.com
        style: chris_beams
        language: en_AU
        weight: 5
        commits_per_push:
            - 1
            - 5
        content: 
            subject:
                words: 20
                word_fuzz: 0
                
            body:
                paras: 6
                para_fuzz: 0
                para_size: 50
                para_size_fuzz: 0

    sysadmin0:
        style: oneline
        paragraphs: [1]
        words: [1,10]
        weight: 0

project_type:
    cpan_dist:
        classify:
  

language:
    en_AU:
      - "On-ya mate"
      - "Barbie?"
      - "BYO"
      - "bring a plate"
      - "roast chook"
      - "a slab"
      - "Ridgy-didge"
      - "The old bugger had it coming. "
      - "Bazza broke his leg playing cricket the other day "
      - "gidday"
      - "your better half"
      - "see- ya!"
      - "fortnight. "
      - "Fair Dinkum!!"
      - "No Wuckas"
      - "G'day . "
      - "Bloody"
      - "bloody hell "
      - "Long Necks "
      - "Mate "
      - "Cya this avo "
      - "Tea "
      - "Ta "
      - "The bloody mongrel "
      - "My clubby mates "
      - "My clubby cossie's "
      - "Cossie's "
      - "Boardies "
      - "The Idiot box "
      - "The local "
      - "Bloody Idiot's "
      - "Clown's "
      - "Ripper "
      - "Beauty "
      - "I'm a seppo "
      - "Get on your bike "
      - "Get under the house "
      - "The old man and the old lady "
