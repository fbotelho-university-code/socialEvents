package socialEvents::Schema::Result::Tipospreferido;

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

socialEvents::Schema::Result::Tipospreferido

=cut

__PACKAGE__->table("tipospreferidos");

=head1 ACCESSORS

=head2 usr

  data_type: 'varchar2'
  is_nullable: 0
  size: 100

=head2 codtipoe

  data_type: 'numeric'
  is_nullable: 0
  original: {data_type => "number"}
  size: 126

=head2 vezes

  data_type: 'numeric'
  is_nullable: 1
  original: {data_type => "number"}
  size: 126

=cut

__PACKAGE__->add_columns(
  "usr",
  { data_type => "varchar2", is_nullable => 0, size => 100 },
  "codtipoe",
  {
    data_type => "numeric",
    is_nullable => 0,
    original => { data_type => "number" },
    size => 126,
  },
  "vezes",
  {
    data_type => "numeric",
    is_nullable => 1,
    original => { data_type => "number" },
    size => 126,
  },
);
__PACKAGE__->set_primary_key("usr", "codtipoe");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-02-02 06:23:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jy1zGBy+AWKji0fWAlvirQ


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
