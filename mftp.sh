#!/bin/bash
export SCRIPTPATH=/var/lib/zabbix/scripts/ftpmonitor
export SCRIPTFTP=$SCRIPTPATH/mftp.pl
export SCRIPTCONF=$SCRIPTPATH/mftp.cfg
export SCRIPTLISTA=$SCRIPTPATH/mftp.lista
export SCRIPTLOG=$SCRIPTPATH/mftp.log
export INICIO=1
export FIM=500
export DIRDADOS=$SCRIPTPATH/dados
function inicia_ftp() {
  $SCRIPTFTP $FTPSERVER $USUARIO $SENHA $LOGFILE $HOMEFTP 2> /dev/null | tee $SCRIPTLOG
  RC=$?
  if [ $RC -eq 0 ]
  then
    echo -e "\e[42m Todos os arquivos foram transferidos com sucesso!"
  else
    echo -e "\e[41m Erro na transferencia, favor verificar o $SCRIPTLOG"
  fi
  echo -en "\e[0m"
  /usr/bin/zabbix_sender -z 127.0.0.1 -s FTP_WIS -k ftpcon[] -o $RC
}
function ler_cfg() {
  cat $SCRIPTCONF | grep -w $1 | awk -F = '{print $2}'
}
function gera_lista() {
  > $DIRDADOS/dados.md5
  echo $DIRDADOS/dados.md5 $HOMEFTP/dados.md5> $SCRIPTLISTA
  echo Preparando para gerar $(expr $(expr $FIM + 1) - $INICIO) arquivos.
  seq $INICIO $FIM | \
    while read numero
    do
      #echo Gerando dados.$numero
      echo -ne "Gerando dados.$numero\r"
      dd if=/dev/urandom of=$DIRDADOS/dados.$numero count=100 bs=1K 2> /dev/null
      md5sum $DIRDADOS/dados.$numero  >> $DIRDADOS/dados.md5 2>/dev/null
      echo $DIRDADOS/dados.$numero $HOMEFTP/dados.$numero >> $SCRIPTLISTA
    done
}
export FTPSERVER=$(ler_cfg FTPSERVER)
export USUARIO=$(ler_cfg USUARIO)
export SENHA=$(ler_cfg SENHA)
export LOGFILE=$(ler_cfg LOGFILE)
export HOMEFTP=$(ler_cfg HOME)
gera_lista
inicia_ftp
