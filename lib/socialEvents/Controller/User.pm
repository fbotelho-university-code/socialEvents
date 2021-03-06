package socialEvents::Controller::User;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }
use socialEvents::Form::Login;
use socialEvents::Form::Register; 
use socialEvents::Form::Perfil; 
use socialEvents::Form::UserView; 
use DateTime; 
use SQL::Translator; 

has 'login_form' => ( isa => 'socialEvents::Form::Login' , is => 'rw' , lazy => 1 , default => sub { socialEvents::Form::Login->new }) ; 

has 'view_form' => ( isa => 'socialEvents::Form::UserView' , is => 'rw' , lazy => 1 , default => sub { socialEvents::Form::UserView->new }) ; 

has 'register_form' => ( isa => 'socialEvents::Form::Register' , is => 'rw' , lazy => 1 , default => sub { socialEvents::Form::Register->new }) ; 

has 'perfil_form' => ( isa => 'socialEvents::Form::Perfil' , is => 'rw' , lazy => 1 , default => sub { socialEvents::Form::Perfil->new }) ; 

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $self->checkUser($c); 
    
    my $naoSaiDeCasa  =  $c->model('DB::Evento')->search({'e_fois.usr' => $c->user->get('usr')}, {join => 'e_fois', order_by => 'me.datai DESC'});

    my $data_hoje = DateTime->from_epoch( epoch => time());
    my $dtf = $c->model('DB')->schema->storage->datetime_parser;
    
    my $vaiSairDeCasa = $c->model('DB::Evento')->search({'e_inscritoes.usr' => $c->user->get('usr'), 'me.datai' => {'>=' => $dtf->format_datetime($data_hoje)}} , { join => 'e_inscritoes' , order_by => 'me.datai'}); 


    my @eventos_amigos = $c->model('DB::Amigosincritosevento')->search({ 'usr' =>  $c->user->get('usr')} , { order_by => 'namigos DESC' } )->all() ;


    if (@eventos_amigos > 0) {
	$c->log->debug("$#eventos_amigos"); 
	my @colnames = ('Evento' , 'Local' , 'Data' , 'Quantidade de Amigos que vao'); 
	my @colref  = ('idevento.nomee', 'idevento.idlocal.nomel', 'idevento.datai', 'idevento.namigos');
	$c->stash ( eventos_amigos => \@eventos_amigos, colref => \@colref , colnames => \@colnames); 
    }
    $c->stash ( ultimo_evento => $naoSaiDeCasa->first); 
    $c->stash ( proximo_evento => $vaiSairDeCasa->first); 
    
    $c->stash( template => 'user/index.tt') ; 
}

 sub schema : Local {
      my ( $self, $c ) = @_;
      my $translator = SQL::Translator->new(
          parser        => 'SQL::Translator::Parser::DBIx::Class',
          data          => $c->model('DB')->schema,
          producer      => 'Diagram',
          producer_args => {
              output_type => 'png',
              title       => 'MyApp Schema',
          },
      ) or die SQL::Translator->error;

      $c->res->content_type('image/png');
      $c->res->body( $translator->translate );
  }

sub login :Local :Args(0) {
    my ( $self, $c ) = @_;

    if ($c->user_exists()){
        $c->response->redirect( $c->uri_for('/')) ; 
        $c->detach(); 
    }

    $c->stash( template => 'user/login.tt' , 
               form => $self->login_form ) ; 
    return unless $self->login_form->process( $ c->req->params ); 
    
    if ($c->authenticate( { usr => $self->login_form->value->{user},  pwd => $c->req->params->{'password'}  , activo => ['1']})){
	$c->stash->{'message'} = "You are now logged in."; 
  
#Change the state of logged in user in database. 
  my $user = $c->user->get_object(); 
  $user->update( { login => '1'} ); 
	$c->response->redirect( $c->uri_for($c->controller('User')->action_for('index') )) ; 
  
	$c->detach(); 
	return;
    }
    
    else {
        $c->stash->{'message'} = "Não foi possível efectuar o login" ;
    }
}

sub logout :Local :Args(0) {
    my ( $self, $c ) = @_;
    $self->checkUser($c); 
    $c->stash->{'template'} = 'user/logout.tt';



    my $user = $c->user->get_object();
    $user->update( { login => '0' } ) ; 
    $c->logout();
    $c->delete_session(); 
    $c->stash->{'message'} = "Logout efectuado!";
}

sub view : Local : Args(1){
    my ($self , $c, $id_usr) = @_; 
    $self->checkUser($c); 
    my $usr = $c->model('DB::User')->find($id_usr );  # returns just one or undef
    if (!$usr){
        $c->stash(error => 'User inexistente' ); 
        $c->response->redirect( $c->uri_for('/')); 
        $c->detach();
    }


    my $usr_logado = $c->user->get('usr');

    #check to see if we are the owner 
    if ($usr_logado eq $id_usr){
        $c->response->redirect( $c->uri_for('perfil')) ; 
        $c->detach(); 
    }
    else{
       $c->stash( template => 'user/view.tt',
                  form => $self->view_form); 
       $self->view_form->process( 
            item => $usr, 
            params => $c->request->parameters, 
            schema => $c->model('DB')->schema,
        );
    }
    
    my $is_amigo = $c->model('DB::Amigo')->find({usr => $usr_logado , amigo => $id_usr}); 
    if ($is_amigo){ $c->stash( is_amigo => $is_amigo); }
	
} 

sub perfil:Local :Args(0){
    my ($self , $c ) = @_; 
    if (!$c->user_exists() ){
        $c->forward('login'); 
        return; 
    }

    $c->stash( template => 'user/perfil.tt' , 
               form => $self->perfil_form ) ; 
    
    $self->perfil_form->process( 
        item_id => $c->user->get('usr'),
        params => $c->request->parameters, 
        schema => $c->model('DB')->schema
        );
    
    $c->stash( fillinform => $self->perfil_form->fif);
    return if !$self->perfil_form->validated; 

    my $user = $self->perfil_form->field('usr')->value; 

    if ($user ne $c->user->get('usr')){
        $c->user->logout(); 
        $c->delete_session(); 
        $c->flash->{message} ='Ao mudar de utilizador têm que efectuar login de novo.'; 
        $c->response->redirect($c->uri_for_action('user/login')); 
        $c->detach(); 
    }

    $c->flash->{message} = 'Alteração efectuada!'; 
    $c->response->redirect($c->uri_for_action( 'user/index'));
    $c->detach(); 
    return ;
}

sub register:Local :Args(0){
    my ($self, $c ) = @_; 
    if ($c->user_exists() ) {
        $c->response->redirect($c->uri_for_action('/')); 
        $c->detach(); 
    }

    $c->stash( template => 'user/register.tt' , 
               form => $self->register_form ) ; 

    my $new_user = $c->model('DB::User')->new_result({}); 

    $self->register_form->process( 
        item => $new_user, 
        params => $c->request->parameters, 
        schema => $c->model('DB')->schema
        );

    return if !$self->register_form->is_valid; 

    $c->flash->{message} = 'Registo efectuado'; 
    $c->response->redirect( $c->uri_for('/user/login')); 
}

sub checkUser:Private {
    my ($self , $c ) = @_ ;
    if (!$c->user_exists()){
        $c->response->redirect( $c->uri_for('/user/login')); 
        $c->detach(); 
    }
 }   
        
__PACKAGE__->meta->make_immutable;

1;
