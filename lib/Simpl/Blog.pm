package Simpl::Blog;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Home;
use Text::MultiMarkdown 'markdown';
use Data::Dumper;

# retrieve a list of markdown files from given
# directory
sub get_posts {
    my $posts_dir = shift;
    
    opendir(my $dh, $posts_dir)
        or die "can't open $posts_dir";
    
    # in case there are non-markdown files
    # only grab those with a sane extension
    my @posts = grep { /.*\.md$/ } readdir($dh);

    # prepend the proper directory to the filenames
    map { $_ = $posts_dir . '/' . $_ } @posts;
    return \@posts;
}

# stick content of post file into scalar
sub read_post {
    my $post_file = shift;
    open(my $handle, '<', $post_file)
        or die 'can not open post';
    
    my $post_content = '';
    map { $post_content .= $_ } <$handle>;
        
    return $post_content;
}

sub render_post {
    my $post_content = shift;
    my $post_html = markdown($post_content);

    return $post_html;
}

sub render_posts {
    my $self = shift;
    my $home = Mojo::Home->new;
    $home->detect('Simpl');

    my $posts_dir = $home->rel_dir('posts');
    say $posts_dir;
    my $posts = get_posts($posts_dir);

    print Dumper($posts);
    
    my @rendered = ();
    foreach(@$posts) {
        push @rendered, render_post( read_post($_) );
    }

    $self->stash( { posts => \@rendered } );
    $self->render( 'blog/blog' );
}

1;
