package socialEvents::Controller::Locais;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use socialEvents::Form::LocalEdit;
use socialEvents::Form::LocalView;
has 'edit_form' => ( isa => 'socialEvents::Form::LocalEdit' , is => 'rw' , lazy => 1 , default => sub { socialEvents::Form::LocalEdit->new }) ; 

has 'view_form' => ( isa => 'socialEvents::Form::LocalView' , is => 'rw' , lazy => 1 , default => sub { socialEvents::Form::LocalView->new }) ; 


sub checkUser:Private {
    my ($self , $c ) = @_ ;
    if (!$c->user_exists()){
        $c->response->redirect( $c->uri_for('/user/login')); 
        $c->detach(); 
    }
 }   

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $self->checkUser($c); 
    $c->stash( template => 'local/index.tt' ); 
    $self->do_list($c) ; 
}

sub view : Local : Args(1){
    my ($self , $c, $id_local) = @_; 
    #check to see if this local exists 
    $self->checkUser($c); 

    my $local = $c->model('DB::Locai')->find($id_local );  # returns just one or undef
    if (!$local) {
        $c->stash(error => 'Local inexistente' ); 
        $c->response->redirect( $c->uri_for('index')); 
        $c->detach();
    }

    my $usr = $c->user->get('usr'); 
    my $criador= $local->criadorl->usr; 
    $c->log->debug("Value of criador is " .  $criador);
    $c->log->debug("valug of get usr is " . $usr);
        
    #check to see if we are the owner 
    if ($usr eq $criador){
        $c->stash(form => $self->edit_form, 
                  template => 'local/edit.tt'); 

        $self->edit_form->process( 
        item => $local, 
        params => $c->request->parameters, 
        schema => $c->model('DB')->schema,
        criador_local => $c->user->get('usr')
        );

        return if !$self->edit_form->is_valid; 

        $c->flash->{message} = 'Alterações efectuadas'; 
        $c->response->redirect( $c->uri_for('/locais/index')); 
        $c->detach();
#edita o local
    }
    else{
       $c->stash( template => 'local/view.tt',
                  form => $self->view_form); 
       $self->view_form->process( 
            item => $local, 
            params => $c->request->parameters, 
            schema => $c->model('DB')->schema,
        );
    }
} 
sub do_list
{
   my ( $self, $c ) = @_;
   my @locais_criados =  $c->model('DB::Locai')->search({ criadorl => $c->user->get('usr') })->all();
   if (@locais_criados > 0){
       my @colref = ('Nome', 'cap', 'publicol', 'm18'); 
       my @colnames = ('Nome' , 'Capacidade' , 'Tipo' , 'Maior que 18', 'Cidade' ); 
       $c->stash(locais_criados => \@locais_criados , colref => \@colref, colnames => \@colnames );
   }
}

sub create: Local: Args(0){
    my ($self , $c ) = @_; 
    $self->checkUser($c); 

    $c->stash( template => 'local/edit.tt' , 
               form => $self->edit_form ) ; 

    my $new_local = $c->model('DB::Locai')->new_result({}); 

    $self->edit_form->process( 
        item => $new_local, 
        params => $c->request->parameters, 
        schema => $c->model('DB')->schema,
        criador_local => $c->user->get('usr')
        );

    return if !$self->edit_form->is_valid; 

    $c->flash->{message} = 'Local Criado'; 
    $c->response->redirect( $c->uri_for('/locais/index')); 
}

__PACKAGE__->meta->make_immutable;

1;
