 



/*  Etude de cas  */

/* On consid�re l'exemple d'app�tence de la carte visa premier pr�sent� au chapitre 3 */
/* (voir aussi cours de P. Besse : http://www.math.univ-toulouse.fr/~besse/Wikistat/pdf/st-scenar-app-visa.pdf) */
/* Les proc�dures ci-dessous seront comment�es et expliqu�es au cours de la sc�ance des traveaux pratiques */
 

libname cas1 "C:\Users\User\Desktop\tpdatamining\" ;


/* Programme de lecture et premier filtrage des donn�es */
 
data cas1.visprem0;
infile "C:\Users\User\Desktop\tpdatamining\visa_raw.dat" 
       dlm=';' lrecl=500;
input
 MATRIC $ DEPTS $ PVS $ SEXEQ $  AGER FAMIQ $ 
 RELAT PCSPQ $ QUALS $ G03G04S $ G25G26S $ 
 G29G30S $ G35G36S $ G37G38S  $ G45G46S $ G47G48S $
 IMPNBS REJETS OPGNB MOYRV TAVEP ENDET GAGET
 GAGEC GAGEM KVUNB QSMOY QCRED DMVTP BOPPN
 FACAN LGAGT VIENB VIEMT UEMNB UEMMTS XLGNB
 XLGMT YLVNB YLVMT NBELTS MTELTS NBCATS MTCATS
 NBBECS MTBECS ZOCNB NTCAS NPTAG SEGV2S $ ITAVC
 HAVEF JNBJD1S JNBJD2S JNBJD3S CARVP $;
run;

data cas1.visprem;
set cas1.visprem0;
select(sexeq);
when('1') do; sexeq='Shom'; sexer=0; end;
when('2') do; sexeq='Sfem'; sexer=1; end;
otherwise sexeq='Sinc';
end;
run;


data cas1.visprem;
set cas1.visprem;
select(famiq);
when('M') famiq='Fmar';
when('C') famiq='Fcel';
when('S') famiq='Fsep';
when('U') famiq='Fuli';
when('D') famiq='Fdiv';
when('V') famiq='Fveu';
otherwise famiq='Finc';
end;
select(CARVP);
when('oui') do; CARVP='Coui'; CARVPr=1; end;
when('non') do; CARVP='Cnon'; CARVPr=0; end;
otherwise   do; CARVP='Cinc'; CARVPr=.; end;
end;
/* regrouper les csp */
PCSPQ=substr(PCSPQ,1,1);
select(PCSPQ);
when('1') PCSPQ='Pagr';
when('2') PCSPQ='Part';
when('3') PCSPQ='Pcad';
when('4') PCSPQ='Pint';
when('5') PCSPQ='Pemp';
when('6') PCSPQ='Pouv';
when('7') PCSPQ='Pret';
when('8') PCSPQ='Psan';
otherwise PCSPQ='Pinc'; 
end;

/* regrouper les jours debiteurs */
jnbjd=jnbjd1s+jnbjd2s+jnbjd3s;
run;


data cas1.visprem;
set cas1.visprem;
/* suppression des clients non concernes */
if ager<18 then delete;
if ager>65 then delete;
/* interdits bancaires */
if g29g30s='B' or g29g30s='X' then delete;
if g03g04s='B' or g03g04s='X' then delete;
if g45g46s='A' or g45g46s='B' or g45g46s='X' then delete;
if g37g38s='A' then delete;
if g25g26s='A' or g25g26s='B' or g25g26s='X' then delete;
if g47g48s='B' then delete;
/* avec compte a terme ou cat. bon et certificat */
if nbcats=1 then delete;
if nbbecs=1 then delete;
drop DEPTS PVS  QUALS G03G04S  G25G26S G29G30S
     G35G36S  G37G38S G45G46S  G47G48S SEGV2S
     JNBJD1S JNBJD2S JNBJD3S;
run;



/* Programme de transformation des donn�es */
data cas1.vispremt;
set cas1.visprem;
/* regrouper encore les csp */
If PCSPQ='Pagr' then  PCSPQ='Pint';
If PCSPQ='Part' then  PCSPQ='Pint';
If PCSPQ='Pret' then  PCSPQ='Psan';
If PCSPQ='Pinc' then  PCSPQ='Psan';
/* regrouper les situations familiales */
select(famiq);
when('Fmar') famiq='Fcou';
when('Fcel') famiq='Fseu';
when('Fsep') famiq='Fseu';
when('Fuli') famiq='Fcou';
when('Fdiv') famiq='Fseu';
when('Fveu') famiq='Fseu';
otherwise famiq='Finc'; end;
/* completer la variable ZOCNB */
if zocnb = . then zocnb=0;
/* supprimer les 6 dernieres valeurs manquantes*/
if dmvtp= . then delete;
/* Correction des plus grosses erreurs de RELAT */
if relat > 600 then relat = relat -600;

/* transformations des variables quantitative (propos�e par P. Besse) elles pourraient �tre affin�es*/
OPGNBL  = log(1+ OPGNB);
MOYRVL  = log(1+ MOYRV);
TAVEPL  = log(1+ TAVEP);
ENDETL  = log(1+ ENDET);
GAGETL  = log(1+ GAGET);
GAGECL  = log(1+ GAGEC);
GAGEML  = log(1+ GAGEM);
QCREDL  = log(1+ QCRED);
DMVTPL  = log(1+ DMVTP);
BOPPNL  = log(1+ BOPPN);
FACANL  = log(1+ FACAN);
LGAGTL  = log(1+ LGAGT);
VIEMTL  = log(1+ VIEMT);
XLGMTL  = log(1+ XLGMT);
YLVMTL  = log(1+ YLVMT);
ITAVCL  = log(1+ ITAVC);
HAVEFL  = log(1+ HAVEF);
JNBJDL  = log(1+ JNBJD); 
ZOCNBR  = sqrt(ZOCNB);
/* liste des variables conservees pour la suite */
keep MATRIC SEXEQ SEXER AGER FAMIQ RELAT PCSPQ
     OPGNBL MOYRVL TAVEPL ENDETL GAGETL GAGECL 
     GAGEML KVUNB  QSMOY QCREDL DMVTPL BOPPNL 
     FACANL LGAGTL VIENB VIEMTL UEMNB  
     XLGNB  XLGMTL YLVNB YLVMTL ZOCNBR 
     NPTAG  ITAVCL HAVEFL JNBJDL CARVP CARVPR ;
run;



/* codage des variables quantitatives en qualitatives */
data cas1.vispremv;
set cas1.vispremt;
select(famiq); /* variables sit. fam. quantitative */
when('Fseu') familr=0;
when('Fcou') familr=1;
/* repartition aleatoire des famiq inconnues*/
otherwise if ranuni(7) < 0.45 
          then do; famiq='Fseu';familr=0;end;
          else do; famiq='Fcou';familr=1;end;
end;
/* rendre qualitatives (2 ou 3 classes) 
             les variables d'effectifs */
select(kvunb);
when(0,1) kvunbq='K0';/* regroupement de deux variables en une*/
otherwise kvunbq='K1';end;
select(vienb);
when(0) vienbq='V0';
otherwise vienbq='V1';end;
select(uemnb);
when(0) uemnbq='U0';
when(1) uemnbq='U1';
otherwise uemnbq='U2';end;
select(xlgnb);
when(0) xlgnbq='X0';
when(1) xlgnbq='X1';
otherwise xlgnbq='X2';end;
select(ylvnb);
when(0) ylvnbq='Y0';
when(1) ylvnbq='Y1';
otherwise ylvnbq='Y2';end;
select(zocnbr);
when(0) zocnbq='Z0';
otherwise zocnbq='Z1';end;
select(nptag);
when(0) nptagq='N0';
otherwise nptagq='N1';end;
/* rendre qualitatives (2 classes) 
        les variables de montant */
/* pr�sence absence de certains produits */
if endetl >0 then endetq='E1';
             else endetq='E0';
if gagetl >0 then gagetq='G1';
             else gagetq='G0';
if facanl >0 then facanq='f1';
             else facanq='f0';
if lgagtl >0 then lgagtq='L1';
             else lgagtq='L0';
if havefl >0 then havefq='H1';
             else havefq='H0';
run;

/* rendre qualitatives  (3 classes) par  decoupage aux quantiles */ 
proc rank data=cas1.vispremt /*  pour des variables qualitatives */
            out=cas1.vispremw groups=3;
var ager relat qsmoy opgnbl moyrvl tavepl 
       dmvtpl boppnl itavcl jnbjdl;
run;

/* recodage des modalites*/
data cas1.vispremw;
set cas1.vispremw (keep=ager relat qsmoy opgnbl 
    moyrvl tavepl dmvtpl boppnl itavcl jnbjdl);
select(ager);
when(0) ageq='A0'; /* changement du nom des variables*/
when(1) ageq='A1';
otherwise ageq='A2';end;
select(relat);
when(0) relatq='R0';
when(1) relatq='R1';
otherwise relatq='R2';end;
select(qsmoy);
when(0) qsmoyq='Q0';
when(1) qsmoyq='Q1';
otherwise qsmoyq='Q2';end;
select(opgnbl);
when(0) opgnbq='O0';
when(1) opgnbq='O1';
otherwise opgnbq='O2';end;
select(moyrvl);
when(0) moyrvq='M0';
when(1) moyrvq='M1';
otherwise moyrvq='M2';end;
select(tavepl);
when(0) tavepq='T0';
when(1) tavepq='T1';
otherwise tavepq='T2';end;
select(dmvtpl);
when(0) dmvtpq='D0';
when(1) dmvtpq='D1';
otherwise dmvtpq='D2';end;
select(boppnl);
when(0) boppnq='B0';
when(1) boppnq='B1';
otherwise boppnq='B2';end;
select(jnbjdl);
when(0) jnbjdq='J0';
when(1) jnbjdq='J1';
otherwise jnbjdq='J2';end;
select(itavcl);
when(0) itavcq='I0';
when(1) itavcq='I1';
otherwise itavcq='I2';end;
keep ageq relatq qsmoyq opgnbq moyrvq tavepq 
    dmvtpq boppnq itavcq jnbjdq;
run;

/* concatenation en une table comprenant vispremv et vispremw*/
data cas1.vispremv;/* ici on a la destruction de cette table via les deux derni�res tables*/
set cas1.vispremv;
set cas1.vispremw;
run;

 
/* Partition de l'�chantillon en deux parties; �chantillon d'apprentissage vpappt et l'�chantillon test vptest */

data cas1.vpappt cas1.vptest;
set cas1.vispremv;
if ranuni(552) < 0.66 then output cas1.vpappt ; /* permet de faire le classesment des tables d'apprentissage et test si s'est >2/3 on affecte � appt et si s'est< on affecte � 1/3*/ 
                     else output cas1.vptest ;
run;


/* Voici les proportions des d�tenteurs et des non d�tenteurs dans chaque �chantillon */
 
proc freq data=cas1.vpappt ;
table carvp;
run;



proc freq data=cas1.vptest ;
table carvp;
run;

 
/*****************************************************************************************************************************************************************/ 

/* Classification par les plus proches voisins et par l'analyse discriminante */

/* S�lection des variables quantitatives */

proc  stepdisc  data=cas1.vpappt ;/* stepdisc permet de trouver la variable qui nous intresse*/
class  carvp;
var ager relat kvunb--nptag opgnbl--zocnbr;
title "S�lection des variables quantitatives";
run;


/*  M�thode des plus proches voisins */

 
proc  discrim  data=  cas1.vpappt
method=npar  k=11 crossvalidate noclassify ;
class  carvp;
var  ager relat kvunb--vienb nptag opgnbl--moyrvl endetl gagecl--lgagtl havefl zocnbr ;
title 'Erreur par validation crois�e sur �chantillon apprentissage k=11';
run;
 
 
/*  Recherche du k optimal */

/* k=10, 9 */
proc  discrim  data=  cas1.vpappt
method=npar  k=10 crossvalidate noclassify ;
class  carvp;
var  ager relat kvunb--vienb nptag opgnbl--moyrvl endetl gagecl--lgagtl havefl zocnbr ;
title 'Erreur avec k=10';
run;
 

proc  discrim  data=  cas1.vpappt
method=npar  k=9 crossvalidate noclassify ;
class  carvp;
var  ager relat kvunb--vienb nptag opgnbl--moyrvl endetl gagecl--lgagtl havefl zocnbr ;
title 'Erreur avec k=9';
run;
 
 
/*k=12, 13 */

proc  discrim  data=  cas1.vpappt
method=npar  k=12 crossvalidate noclassify ;
class  carvp;
var  ager relat kvunb--vienb nptag opgnbl--moyrvl endetl gagecl--lgagtl havefl zocnbr ;
title 'Erreur avec k=12';/* ici 12 est le meilleur k avec le taux d'errur le plus faible*/
run;
 

proc  discrim  data=  cas1.vpappt
method=npar  k=13 crossvalidate noclassify ;
class  carvp;
var  ager relat kvunb--vienb nptag opgnbl--moyrvl endetl gagecl--lgagtl havefl zocnbr ;
title 'Erreur avec k=13';
run;
 
 

/* On note Ei l'erreur obtenue avec k=i. Ainsi, E9=0.2392 ; E10=0.2340 ;  E11=0.2339  ;  E12=0.2297 ; E13=0.2435 */
/* Attention, ces valeurs peuvent �tre d�ff�rentes d'une personne � l'autre ; �tant donn� que l'�chantillon d'apprentissage n'est pas la m�me pour tous*/
/* On choisit donc k=11*/


/* Erreur de classement et pr�vision sur l'�chantillon test */

   
proc  discrim  data=  cas1.vpappt
  method=npar  k=11 crossvalidate
  testdata = cas1.vptest
  testout = cas1.fitkNN;
  class  carvp;
  var ager relat kvunb--vienb nptag opgnbl--moyrvl endetl gagecl--lgagtl havefl zocnbr ;
  title 'Erreur de classement et pr�vision sur �chantillon test';
  run;


proc print data=cas1.fitkNN; title 'kNN: Pr�vision'; run;



/* Analyse discriminante */


/* Analyse discriminante lin�aire */
proc  discrim  data=  cas1.vpappt
method=NORMAL  pool=yes /*  discrimination  lineaire  */ 
crossvalidate ;
class  carvp ;    
var ager relat kvunb--vienb nptag opgnbl--moyrvl endetl gagecl--lgagtl havefl zocnbr;
title 'ADL : construction de la fonction discriminante lin�aire';
run ;
/* l'erreur de prediction pour l'ADL EST 0.20*/


/* Analyse discriminante lin�aire */
proc  discrim  data=  cas1.vpappt
method=NORMAL  pool=yes /*  discrimination  lineaire  */ 
crossvalidate
testdata=cas1.vptest
testout=cas1.fitADL;
class  carvp ;    
var ager relat kvunb--vienb nptag opgnbl--moyrvl endetl gagecl--lgagtl havefl zocnbr;
title 'ADL : erreur de classement et pr�vision sur �chantillon test';
run ;


proc print data=cas1.fitADL; title 'ADL: Pr�vision'; run;

 

/* Analyse discriminante quadratique */
proc  discrim  data=  cas1.vpappt
method=NORMAL  pool=no /*  discrimination  quadratique */ 
crossvalidate;
class  carvp ;    
var ager relat kvunb--vienb nptag opgnbl--moyrvl endetl gagecl--lgagtl havefl zocnbr;
title 'ADQ : construction du mod�le';
run ;


/* Analyse discriminante quadratique */
proc  discrim  data=  cas1.vpappt
method=NORMAL  pool=no /*  discrimination  quadratique  */ 
crossvalidate
testdata=cas1.vptest
testout=cas1.fitADQ;
class  carvp ;    
var ager relat kvunb--vienb nptag opgnbl--moyrvl endetl gagecl--lgagtl havefl zocnbr;
title 'ADQ : erreur de classement et pr�vision sur �chantillon test';
run ;

proc print data=cas1.fitADL; title 'ADQ: Pr�vision'; run;



/* Comparer les resultats de l'ADL et ceux de l'ADQ. Quel mod�le choissirez vous?  */
/* L'ERREUR DE PREDICTION POUR l'ADQ est 0.24*/
/* En comparant les modeles , on retient l'ADL car il a l'erreur de prediction le plus faible*/





/******************************************************************************************************************************************************************/




/* Regression logistique */
 
 
 
/* Regression logistique sur les variables quantitatives */
proc  logistic  data=cas1.vpappt;
model carvp (event='Coui') = ager relat kvunb--nptag opgnbl--zocnbr;
score data=cas1.vptest out=test_score; 
score data=cas1.vptest outroc=roc_score;
title 'Regression logistique sur les variables quantitatives';
run; 
/* dans la regression logistique on peut utiliser toutes les variables quatitatives */


/* Calcul erreur de classement */


 proc print data =test_score; run;


data test_score;
set test_score;
  if (carvp="Coui" and P_Coui>=0.5) or (carvp="Cnon" and P_Coui<0.5) then erreur=0;
  else erreur=1;
run;


 proc print data =test_score; run;


proc means data=test_score;
var erreur;
run;


/* Comparez ce mod�le avec l'ADL et l'ADQ obtenus pr�c�demment*/





/*************************************************************************************************************************************************************/


 
 
/* Regression logistique sur tous les variables (non cod�es) avec s�lection de variables */
proc  logistic  data=cas1.vpappt;
class sexeq  famiq  pcspq ;
model carvp (event='Coui') = sexeq  famiq  pcspq  ager relat kvunb--nptag opgnbl--zocnbr / selection=stepwise;
score data=cas1.vptest out=test_score; 
score data=cas1.vptest outroc=roc_score;
title "Regression logistique sur tous les variables (non cod�es) avec s�lection de variables ";
run; /* ici on doit regarder l'AIC constante plus que  covariables doit augmenter*/


/* Calcul erreur classement */


 proc print data =test_score; run;


data test_score;
set test_score;
  if (carvp="Coui" and P_Coui>=0.5) or (carvp="Cnon" and P_Coui<0.5) then erreur=0;
  else erreur=1;
run; /* ici l'erreur est>1/2 alor son a une bonne classement du modele oui et l/erreur est = a 0 sinon =1*/


 proc print data =test_score; run;


proc means data=test_score;
var erreur;
run;


/* Comparez les r�sultats � ceux obtenus pr�c�demment */ 
/* on observe que le modele logistique a le plus faible erreur de prediction*/
/* Quel mod�le choisirez-vous? Justifiez. */
/* on choisit le modele ;ogistique*/



/*  Exercice :   1-) Construisez le un mod�le de r�gression logistique avec les variables cod�es (on utilisera une proc�dure de s�lection de variables) */
/*               2-)  Comparez les r�sultats � ceux obtenus pr�c�demment  */

/* Quel model (kNN, ADL, ADQ, r�gression logistique) retiendrez-vous? */





 
