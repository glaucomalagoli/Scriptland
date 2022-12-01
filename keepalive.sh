#!/bin/bash

 # Set de variaveis:
 # SCPT_HOME = Home do script;
 #     COUNT = Numeral Decimal - Contador de execucao do script;
 #      WAIT = Numeral Decimal - Define tempo de espera entre cada execução;
 #  QTD_PING = Numeral Decimal - Define a quantidade de pings que o scrit deve executar em cada execucao;
 #      LOOP = Numeral Decimal - Quantidade de loops que o script deve ser executado - Sempre o alvo desejado +1 ;
 #        IP = Endereço IP alvo do teste;
 #       LOG = String de log criada para log. Deve ser gerado um log por dia independente da quantidade de execucoes;

 # Sintaxe : alive.sh -wait=espera_entre_exec -ping=qtd_de_ping -loop=qtd_loops -IP=End_IP
 #      Ex : alive.sh -wait=5 -ping=4 -loop=11 -IP=10.0.0.188

 # Variaveis
 SCPT_HOME="/opt/scripts"
     COUNT="1"
      WAIT="$(echo ${1} | cut -f 2 -d =)"
  QTD_PING="$(echo ${2} | cut -f 2 -d =)"
      LOOP="$(echo ${3} | cut -f 2 -d =)"
        IP="$(echo ${4} | cut -f 2 -d =)"
       LOG="${SCPT_HOME}/log/alive_$(date +%d%m%Y).log"

 # Monta o cabecalho da execucao
 echo " ----------------------------------------------------------- " >> ${LOG}
 echo " -                      Keep Alive                         - " >> ${LOG}
 echo " ----------------------------------------------------------- " >> ${LOG}
 echo "" >> ${LOG}

 # Funcao de execucao
 fn_ping()
 {
   # Inicio do loop
   while [ ${COUNT} -ne ${LOOP} ]
   do
     echo " Execucao ${COUNT} : $(date +%D" "%H":"%M":"%S)" >> ${LOG}
     echo " ------------------------------" >> ${LOG}
     echo "" >> ${LOG}
     # Execucao do cmd de ping
     ping -c ${QTD_PING} ${IP} | grep -i ttl  >> ${LOG}
     echo "" >> ${LOG}
     # Aguarda para comecar novo loop
           sleep ${WAIT}
     #Aumenta +1 no loop
     COUNT="$((${COUNT}+1))"
   done
   echo "" >> ${LOG}
   # Testa se o teste foi executado com sucesso para incremento do status no log

   ping -c 1 ${IP} &> /dev/null

   if [ $? -eq 0 ]
     then
       echo " Status Alive: $(date) : OK " >> ${LOG}
     else
       echo " Status Alive: $(date) : NOK" >> ${LOG}
   fi
   echo "" >> ${LOG}
   exit 0
 }

 # Execucao
 fn_ping
