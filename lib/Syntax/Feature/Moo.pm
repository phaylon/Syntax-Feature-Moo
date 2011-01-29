use strictures 1;

# ABSTRACT: Provide class and role keywords for Moo

package Syntax::Feature::Moo;

use Syntax::Feature::Module 0.001       ();
use Carp                                qw( croak );
use Params::Classify        0.011       qw( is_ref );
use Moo                     0.009005    ();

use namespace::clean 0.18;

$Carp::Internal{ +__PACKAGE__ }++;

=method install

    $class->install( %arguments )

Used by L<syntax> to install this extension into a package.

=cut

sub install {
    my ($class, %args) = @_;
    my $target  = $args{into};
    my $outer   = $args{outer};
    my $options = is_ref($args{options}, 'HASH')
        ? $args{options}
        : {};
    Syntax::Feature::Module->install_multiple(
        %args,
        blocks => {
            class => {
                -inner      => [$class->_default_inner($options)],
                -preamble   => [
                    $class->_class_preamble($options),
                    $class->_final_preamble($options),
                ],
            },
            role => {
                -inner      => [$class->_default_inner($options)],
                -preamble   => [
                    $class->_role_preamble($options),
                    $class->_final_preamble($options),
                ],
            },
        },
    );
    return 1;
}

sub _default_inner   { () }
sub _class_preamble  { $_[0]->_common_preamble($_[1]), 'use Moo' }
sub _role_preamble   { $_[0]->_common_preamble($_[1]), 'use Moo::Role' }
sub _common_preamble { () }
sub _final_preamble  { () }

1;

__END__

=head1 SYNOPSIS

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

The L<Syntax::Feature::Moo::Default> extension is a subclass of this
module that will provide other common extensions automatically.

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

=item * L<Syntax::Feature::Moo::Default>

=item * L<Syntax::Feature::Module>

=item * L<Moo>

=back

=cut
