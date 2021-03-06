package socialEvents::Schema::Result::EFoi;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

socialEvents::Schema::Result::EFoi

=cut

__PACKAGE__->table("e_foi");

=head1 ACCESSORS

=head2 idevento

  data_type: 'numeric'
  is_foreign_key: 1
  is_nullable: 0
  original: {data_type => "number"}
  size: 126

=head2 usr

  data_type: 'varchar2'
  is_foreign_key: 1
  is_nullable: 0
  size: 100

=cut

__PACKAGE__->add_columns(
  "idevento",
  {
    data_type => "numeric",
    is_foreign_key => 1,
    is_nullable => 0,
    original => { data_type => "number" },
    size => 126,
  },
  "usr",
  { data_type => "varchar2", is_foreign_key => 1, is_nullable => 0, size => 100 },
);
__PACKAGE__->set_primary_key("idevento", "usr");

=head1 RELATIONS

=head2 usr

Type: belongs_to

Related object: L<socialEvents::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "usr",
  "socialEvents::Schema::Result::User",
  { usr => "usr" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 idevento

Type: belongs_to

Related object: L<socialEvents::Schema::Result::Evento>

=cut

__PACKAGE__->belongs_to(
  "idevento",
  "socialEvents::Schema::Result::Evento",
  { idevento => "idevento" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-02-02 05:48:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FpRZHNVbHCEIHeN0Bcof9w


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
