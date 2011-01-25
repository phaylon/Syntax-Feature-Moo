use strictures 1;

package Syntax::Feature::Moo;

use Carp                            qw( croak );
use Params::Classify        0.011   qw( is_ref );
use Syntax::Feature::Module 0.001;

use Moo 0.009005 ();

use namespace::clean 0.18;

$Carp::Internal{ +__PACKAGE__ }++;

=method install

    $class->install( %arguments );

Used by L<syntax> to install this extension into a package.

=cut

sub install {
    my ($class, %args) = @_;
    my $target = $args{into};
    my $outer  = $args{outer};

    my $options = $args{options};
    $options = { -inner => $options }
        if is_ref $options, 'ARRAY';
    $options = {}
        unless defined $options;
    croak qq{The options for $class have to be an array or hash ref}
        unless is_ref $options, 'HASH';

    my $inner = $options->{ -inner };
    $inner = []
        unless defined $inner;
    croak qq{The -inner option for $class has to be an array ref}
        unless is_ref $inner, 'ARRAY';

    my $names = $options->{ -as };
    $names = {}
        unless defined $names;
    croak qq{The -as option for $class has to be a hash ref}
        unless is_ref $names, 'HASH';
    my $role_name  = $names->{role}  || 'role';
    my $class_name = $names->{class} || 'class';

    my $preamble = $options->{ -preamble };
    $preamble = []
        unless defined $preamble;
    croak qq{The -preamble option for $class has to be an array ref}
        unless is_ref $preamble, 'ARRAY';

    Syntax::Feature::Module->install(
        into    => $target,
        outer   => $outer,
        options => {
            -inner      => $inner,
            -as         => $class_name,
            -preamble   => ['use Moo', @$preamble],
        },
    );
    Syntax::Feature::Module->install(
        into    => $target,
        outer   => $outer,
        options => {
            -inner      => $inner,
            -as         => $role_name,
            -preamble   => ['use Moo::Role', @$preamble],
        },
    );

    return 1;
}

1;

__END__

=head1 SYNAPSIS

    use syntax qw( moo );

    role Named {
        has name => (is => 'ro');
    };

    class Point 1.23 {
        has x => (is => 'ro');
        has y => (is => 'ro');
        with 'Named';
        sub coord {
            my ($self) = @_;
            return sprintf '(%s,%s)', $self->x, $self->y;
        }
    };

=head1 DESCRIPTION

This syntax extension uses L<Syntax::Feature::Module> to provide a
C<class> and a C<role> keyword that will automatically load L<Moo> and
L<Moo::Role> respectively.

=head1 SYNTAX

The L<Syntax::Feature::Module/SYNTAX> is valid for the C<role> and C<class>
keywords as well.

=head1 OPTIONS

=head2 -as

    use syntax moo => { -as => { role => 'trait', class => 'moo' } };

    moo My::Class 2.34 { ... };

    trait My::Role  3.45 { ... };

This option needs to be a hash reference. You can set the values for
C<class> or C<role> to supply your own names for role and class blocks.

=head2 -inner

    use syntax moo => { -inner => [qw( method )] };

    class Foo {
        method class_method { ... }
    }

    role Bar {
        method role_method { ... }
    }

This option can be used to load further syntax extensions inside the
namespaced blocks. The same C<-inner> settings will be passed to both
block types.

As with L<Syntax::Feature::Module> you can specify the C<-inner> array
reference option directly if you don't have anything else to configure:

    use syntax moo => [qw( method )];

    class Foo {
        method class_method { ... }
    }

    role Bar {
        method role_method { ... }
    }

This has the same effect as the code above. These examples are using
L<Syntax::Feature::Method> to provide a C<method> keyword inside the
blocks.

=head2 -preamble

    use syntax moo => { -preamble => [
        'use namespace::clean',
        'no namespace::clean',
    ] };

    class Foo { ... }

    role Bar { ... }

The C<-preamble> is an array reference of strings that will be inserted
into the namespaced block after L<Moo> or L<Moo::Role> were invoked. The
above example would use L<namespace::clean> to clean up the namespace after
compiletime and reset it for a future manual cleanup pass.

=head1 SEE ALSO

=over

=item * L<syntax>

=item * L<Syntax::Feature::Module>

=item * L<Moo>

=back

=cut
