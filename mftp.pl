#!/usr/bin/perl -w
use Net::FTP;
use Net::Cmd;
sub logar  {
	$hora=localtime;
	print "$hora;$_[0]\n";
}
if ( $#ARGV == 4 ) {
	$hostname = $ARGV[0];
	$username = $ARGV[1];
	$password = $ARGV[2];
	$LOGFILE=$ARGV[3];
	$home=$ARGV[4];
  print "$home\n";
} else {
	print "Erro no numero de argumentos no FTP.PL, provavelmente senha.\n";
	exit '2';
}
$ftp = Net::FTP->new($hostname, Debug => 0) or die "Nao foi possivel conectar ao servidor de ftp $hostname: $@";
$LOG_ERRO_CODE=$ftp->code;
$LOG_ERRO_MESSAGE=$ftp->message;
logar "$LOG_ERRO_CODE;$LOG_ERRO_MESSAGE";
logar "$LOG_ERRO_CODE;$LOG_ERRO_MESSAGE\n";
$ftp->login($username,$password) or die "Nao foi possivel logar em $hostname, verifique senha e usuario.", $ftp->message;
$LOG_ERRO_CODE=$ftp->code;
$LOG_ERRO_MESSAGE=$ftp->message;
logar "$LOG_ERRO_CODE;$LOG_ERRO_MESSAGE";
$ftp->cwd($home) or die "Diretorio do FTP esta inacessivel ", $ftp->message;
$LOG_ERRO_CODE=$ftp->code;
$LOG_ERRO_MESSAGE=$ftp->message;
logar "$LOG_ERRO_CODE;$LOG_ERRO_MESSAGE";
$retorno = $ftp->pwd or die "Diretorio do FTP esta inacessivel ", $ftp->message;
$LOG_ERRO_CODE=$ftp->code;
$LOG_ERRO_MESSAGE=$ftp->message;
logar "$LOG_ERRO_CODE;$LOG_ERRO_MESSAGE";
$ftp->binary or die "Nao foi possivel habilitar transferencia em modo binario", $ftp->message;
$LOG_ERRO_CODE=$ftp->code;
$LOG_ERRO_MESSAGE=$ftp->message;
logar "$LOG_ERRO_CODE;$LOG_ERRO_MESSAGE";
logar "$LOGFILE\n";
open(LOGFILE) or die("Nao foi possivel ler lista de arquivos do FTP a ser processada.");
foreach $line (<LOGFILE>) {
	chomp($line);
	@lista=split(" ",$line);
	#print "lista 0=$lista[0], lista 1=$lista[1], lista 2=$lista[2]\n";
  #print "1 $lista[0] 2 $lista[1]";
	$ftp->put($lista[0],$lista[1]) or die "Nao foi possivel gravar $lista[1]";
	$RC=$?;
	$LOG_ERRO_CODE=$ftp->code;
	$LOG_ERRO_MESSAGE=$ftp->message;
	@LOG_ERRO_MESSAGE_A=split("\n",$LOG_ERRO_MESSAGE);
	logar "$LOG_ERRO_CODE;$LOG_ERRO_MESSAGE_A[0];$LOG_ERRO_MESSAGE_A[1];dado $lista[0] foi armazenado em $hostname:$home ;$RC\n";
}
$ftp->quit;
logar "Transferencia de FTP para $hostname:$retorno concluido, nada mais para fazer.\n";
