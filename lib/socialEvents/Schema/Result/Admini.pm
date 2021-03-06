package socialEvents::Schema::Result::Admini;

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

socialEvents::Schema::Result::Admini

=cut

__PACKAGE__->table("adminis");

=head1 ACCESSORS

=head2 adm

  data_type: 'varchar2'
  is_nullable: 0
  size: 100

=head2 pwd

  data_type: 'varchar2'
  is_nullable: 0
  size: 50

=head2 activo

  data_type: 'char'
  default_value: 1
  is_nullable: 0
  size: 1

=cut

__PACKAGE__->add_columns(
  "adm",
  { data_type => "varchar2", is_nullable => 0, size => 100 },
  "pwd",
  { data_type => "varchar2", is_nullable => 0, size => 50 },
  "activo",
  { data_type => "char", default_value => 1, is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("adm");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-02-02 05:48:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OMJAf9j5eWvS2i+mgMmufQ


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
