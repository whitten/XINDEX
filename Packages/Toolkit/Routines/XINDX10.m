XINDX10 ;ISC/GRK - assemble DD executable code ;11/12/2002  11:40
 ;;7.3;TOOLKIT;**20,27,66,68,132**;Apr 25, 1995;Build 13
 ; Per VHA Directive 2004-038, this routine should not be modified.
ASK ;Ask for Build, Install, or Package file.
 N X,Y,P,V,RN
 S DA=0,Y=-1,INP(11)=""
 S:$D(^DD(9.6,0)) P=9.6,Y=$$BUILD^XTRUTL1 Q:$D(DUOUT)  D:Y>0  I Y<0 S:$D(^DD(9.7,0)) P=9.7,Y=$$INSTALL^XTRUTL1 D:Y>0
 . S INP(10)=P,DA=+Y,X=$P(Y,"^",2),V=$$VER^XTRUTL1(X)
 . S INP(11)="I $P(LIN,"";"",3)'["""_V_""" D E^XINDX1(44)",INP(11.1)=V
 . I $L($P(X,"*",3)) S INP(12)="I $P(LIN,"";"",5)'?.E1P1"""_$P(X,"*",3)_"""1P.E S ERR=56,ERR(1)=INP(12.1) D E^XINDX1(.ERR)",INP(12.1)=$P(X,"*",3)
 . Q
 K DIC Q:$D(DUOUT)
 I $D(^DD(9.4,0)),'DA S DIC="^DIC(9.4,",DIC(0)="AEQMZ" D ^DIC S INP(10)=9.4,DA=+Y
 D ASKNS,ASKFILES
 Q
ASKNS ;Ask for a list of namespaces
 N NSC,NS
 W !,"LIST OF NAMESPACES TO BE INDEXED; PRESS RETURN TO TERMINATE LIST",! S NSC=0
N1 R !,"NAMESPACE: ",NS:$S($G(DTIME):DTIME,1:360) Q:NS=""  Q:NS="^"
 I NS'?1(1"%",1"!",1"-").UN&(NS'?1U.UN) W "  INVALID NAMESPACE" G N1
 I NS?1(1"!",1"-").UN S $E(NS,1,1)="!" S NSC=NSC+1,ENAMESPACES($J,NS)=""
 E  S NSC=NSC+1,NAMESPACES($J,NS)=""
 S INP(10)="NAMESPACE",DA=1
 G N1
 Q
 ;
ASKFILES ;Ask for a list of files
 N FILESC,FILE
 W !,"LIST OF FILES TO BE INDEXED; PRESS RETURN TO TERMINATE LIST",! S FILESC=0
F1 R !,"FILE: ",FILE:$S($G(DTIME):DTIME,1:360) Q:FILE=""  Q:FILE="^"
 I FILE'?1.45UNP&('$D(^DIC(FILE))!'($D(^DIC("B",FILE)))) W "  INVALID FILENAME" G F1
 ; should only get file number for list, but accept file name or number
 E  D
 . ; translate the file name into a number
 . I FILE'=+FILE S FILE=$O(^DIC("B",FILE,"")) I FILE="" W "  INVALID FILENAME" Q
 . ; if we have a number then we can add it and continue
 . S FILESC=FILESC+1,FILES($J,FILE)=""
 S INP(10)="NAMESPACE",DA=1
 G F1
 Q
 ;
START ;called from SETUP^XINDX7
 G PKG:INP(10)=9.4,NEXT:INP(10)=9.7,NS:INP(10)="NAMESPACE"
 ;Get routines and other code from BUILD.
 W !,"The BUILD file Data Dictionaries are being processed.",!
 F J=0:0 S J=$O(^XPD(9.6,DA,4,J)) Q:J'>0  I $D(^(J,0)) S INDFN=+^(0),INDRN="|dd"_INDFN D XPD
 G NEXT
NS W !,"The selected file Data Dictionaries are being processed.",!
 F J=0:0 S J=$O(FILES($J,J)) Q:J'>0  I $D(^DIC(J,0)) S INDFN=J,INDRN="|dd"_INDFN,(INDF,INDL)=0 D INSERT
 G NEXT
PKG W !,"The package file Data Dictionaries are being processed.",!
 F J=0:0 S J=$O(^DIC(9.4,DA,4,J)) Q:J'>0  I $D(^(J,0)) S INDFN=+^(0),INDRN="|dd"_INDFN,(INDF,INDL)=0 D INSERT
NEXT D ^XINDX11,REMCOMP:'INP(9) K A,B,C,C9,G,H,INDD,INDEL,INDF,INDFN,INDID,INDL,INDN,INDRN,INDSB,INDX,INDXN,INDXRF,DA,DIC,J,INDLC,INDC
 Q
XPD ;Check if Full/Partial DD
 N IND1,IND222,J2,J3 S IND222=$G(^XPD(9.6,DA,4,J,222))
 S (INDF,INDL)=0 I $P(IND222,"^",3)="f" K IND222 D INSERT Q
 ;Each entry at the J2 level is a new file/sub-file.
 F J2=0:0 S J2=$O(^XPD(9.6,DA,4,J,2,J2)) Q:J2'>0  S IND1=^(J2,0) D
 . S INDFN=J2,INDRN="|dd"_INDFN,INDLC=0 Q:'$$HDR()
 . ;Each J3 is a field in the file.
 . F J3=0:0 S J3=$O(^XPD(9.6,DA,4,J,2,J2,1,J3)) Q:J3'>0  S INDFN=J2,INDF=J3,INDL=0 D STRIP
 . S ^UTILITY($J,1,INDRN,0,0)=INDLC
 . Q
 Q
HDR() ;Display Header and start faux routine build
 I '$D(^DD(INDFN)) W !,"File # ",INDFN," is missing !",$C(7) Q 0
 S ^UTILITY($J,INDRN)="",NRO=NRO+1 W !,INDFN," ",$O(^DD(INDFN,0,"NM",0))
 S INDLC=0,INDC=INDRN_" ;"_$S($D(IND222):"Partial ",1:"")_"DD of the "_$O(^DD(INDFN,0,"NM",0))_$S(INDL:" sub-",1:" ")_"file"_$S(INDL:" of the "_$O(^DD(INDFN(1),0,"NM",0))_" (#"_INDFN(1)_") file.",1:"."),INDX="" D ADD
 Q 1
INSERT ;Find executable code in this DD
 Q:'$$HDR
ID S INDID=-1 F G=0:0 S INDID=$O(^DD(INDFN,0,"ID",INDID)) Q:INDID=""  I $D(^(INDID))#2 S INDC="ID"_INDID_" ; IDENTIFIER CODE FOR "_INDID S INDX=$S(^(INDID)]"":^(INDID),1:"Q") D ADD
W I $D(^DD(INDFN,0,"W"))#2 S INDX=^("W"),INDC="W ; 'W' code ??" D ADD
FILE ;Get additional File level fields that contain executable code
 I $D(^DD(INDFN,0,"ACT"))#2 S INDC="ACT ; POST-ACTION",INDX=^("ACT") D ADD
 I $D(^DD(INDFN,0,"DIC"))#2 S INDC="DIC ; SPECIAL LOOKUP",INDX="D ^"_^("DIC") D ADD
INDX ;Get New-Style Cross-Reference stored in the INDEX File
 ;We can get this from the "BB" index on the INDEX file (INDEL is the index name)
 S INDEL="" F  S INDEL=$O(^DD("IX","BB",INDFN,INDEL)) Q:INDEL=""  D
 . S X=$Q(^(INDEL)),X=$QS(X,5) ; Naked reference to ^DD("IX","BB",INDFN)
 . I $D(^DD("IX",X,1))#2 S INDC="IX"_INDEL_"SL ; SET LOGIC",INDX=$E(^DD("IX",X,1),1,245) D ADD
 . S SUB="" F  S SUB=$O(^DD("IX",X,1.2,SUB)) Q:SUB=""  Q:SUB'=+SUB  I $D(^DD("IX",X,1.2,SUB,1))#2 S INDC="IX"_INDEL_"P"_SUB_"SOF ; OVERFLOW SET LOGIC ("_SUB_")",INDX=$E(^DD("IX",X,1.2,SUB,1),1,245) D ADD
 . I $D(^DD("IX",X,1.4))#2 S INDC="IX"_INDEL_"SCC ; SET CONDITION CODE",INDX=$E(^DD("IX",X,1.4),1,245) D ADD
 . I $D(^DD("IX",X,2.1))#2 S INDC="IX"_INDEL_"KL ; KILL LOGIC",INDX=$E(^DD("IX",X,2.1),1,245) D ADD
 . S SUB="" F  S SUB=$O(^DD("IX",X,2.2,SUB)) Q:SUB=""  Q:SUB'=+SUB  I $D(^DD("IX",X,2.2,SUB,2))#2 S INDC="IX"_INDEL_"P"_SUB_"KOF ; OVERFLOW KILL LOGIC ("_SUB_")",INDX=$E(^DD("IX",X,2.2,SUB,2),1,245) D ADD
 . I $D(^DD("IX",X,2.4))#2 S INDC="IX"_INDEL_"KCC ; KILL CONDITION CODE",INDX=$E(^DD("IX",X,2.4),1,245) D ADD
 . I $D(^DD("IX",X,2.5))#2 S INDC="IX"_INDEL_"KEIC ; KILL ENTIRE INDEX CODE",INDX=$E(^DD("IX",X,2.5),1,245) D ADD
 . S SUB="" F  S SUB=$O(^DD("IX",X,11.1,SUB)) Q:SUB=""  Q:SUB'=+SUB  D
 . . I $D(^DD("IX",X,11.1,SUB,1.5))#2 S INDC="IX"_INDEL_"P"_SUB_"CC ; COMPUTED CODE ("_SUB_")",INDX=$E(^DD("IX",X,11.1,SUB,1.5),1,245) D ADD
 . . I $D(^DD("IX",X,11.1,SUB,2))#2 S INDC="IX"_INDEL_"P"_SUB_"TS ; TRANSFORM FOR STORAGE ("_SUB_")",INDX=$E(^DD("IX",X,11.1,SUB,2),1,245) D ADD
 . . I $D(^DD("IX",X,11.1,SUB,4))#2 S INDC="IX"_INDEL_"P"_SUB_"TL ; TRANSFORM FOR LOOKUP ("_SUB_")",INDX=$E(^DD("IX",X,11.1,SUB,4),1,245) D ADD
 . . I $D(^DD("IX",X,11.1,SUB,3))#2 S INDC="IX"_INDEL_"P"_SUB_"TD ; TRANSFORM FOR DISPLAY ("_SUB_")",INDX=$E(^DD("IX",X,11.1,SUB,3),1,245) D ADD
FLD S INDF=$O(^DD(INDFN,INDF)) I INDF>0 D STRIP W "." G FLD
 S ^UTILITY($J,1,INDRN,0,0)=INDLC Q
STRIP ;
 S A=$P(^DD(INDFN,INDF,0),"^",2) I A D PUSH,INSERT,POP Q
 I A'["W",A'["S" S INDX=$P(^(0),"^",5,99),INDC=INDF_" ; "_$P(^(0),"^",1) D ADD
 I $D(^DD(INDFN,INDF,2))#2 S INDC=INDF_"OT ; OUTPUT TRANSFORM CODE",INDX=^(2) D ADD
 I $D(^DD(INDFN,INDF,4))#2 S INDC=INDF_"HELP ; EXECUTABLE HELP CODE",INDX=^(4) D ADD
 I $D(^DD(INDFN,INDF,12)) S INDC=INDF_"SCR ; "_$E(^(12),1,220) S INDX=$S($D(^(12.1))#2:^(12.1),1:"Q") D ADD
 I $D(^DD(INDFN,INDF,7.5))#2 S INDC=INDF_"TPL ; TRANSFORM DONE PRIOR TO THE DIC LOOK-UP",INDX=^(7.5) D ADD
 I $D(^DD(INDFN,INDF,"AX"))#2 S INDC=INDF_"AX ; EXECUTABLE AUDIT CHECK CODE",INDX=^("AX") D ADD
 F INDEL=9.2:.1:9.9 I $D(^DD(INDFN,INDF,INDEL))#2 S INDC=INDF_"OF"_INDEL_" ; OVERFLOW CODE",INDX=^(INDEL) D ADD
 S INDEL="" F  S INDEL=$O(^DD(INDFN,INDF,"DEL",INDEL)) Q:INDEL=""  I $D(^(INDEL,0))#2 S INDC=INDF_"DEL"_INDEL_" ; DELETE PROTECTION CODE",INDX=^(0) D ADD
 S INDEL="" F G=0:0 S INDEL=$O(^DD(INDFN,INDF,"LAYGO",INDEL)) Q:INDEL=""  I $D(^(INDEL,0))#2 S INDC=INDF_"LAYGO"_INDEL_" ; LAYGO CHECK CODE",INDX=^(0) D ADD
 F INDXRF=0:0 S INDXRF=$O(^DD(INDFN,INDF,1,INDXRF)) Q:INDXRF'>0  S C=$P(^(INDXRF,0),"^",2) F G=0:0 S G=$O(^DD(INDFN,INDF,1,INDXRF,G)) Q:G'>0  D XREFS
 ; Additional Data Dictionary fields that contain executable code
 I $D(^DD(INDFN,INDF,12.2)) S INDC=INDF_"SCREXP ; EXPRESSION FOR POINTER SCREEN",INDX=$S($D(^(12.2))#2:^(12.2),1:"Q") D ADD
 S INDEL="" F  S INDEL=$O(^DD(INDFN,INDF,"V",INDEL)) Q:INDEL=""  I $D(^(INDEL,1))#2 S INDC=INDF_"VPSCR"_INDEL_" ; VARIABLE POINTER SCREEN",INDX=^(1) D ADD
 Q
XREFS Q:('$D(^(G))#2)!(G=3)  ;Node 3 is don't delete comment.
 S INDC=INDF_"XRF"_INDXRF_$S(G=1:"S",G=2:"K",1:"n"_G)_" ; "_$S(G<2:"SET",G<3:"KILL",1:"OVERFLOW")_" LOGIC FOR '"_$S(C]"":C,1:INDXRF)_"' XREF",INDX=^(G) D ADD
 Q
ADD ;Put code in UTILITY for processing
 S INDLC=INDLC+1,^UTILITY($J,1,INDRN,0,INDLC,0)=INDC I INDX]"" S INDLC=INDLC+1,^UTILITY($J,1,INDRN,0,INDLC,0)=" "_INDX
 Q
PUSH S INDL=INDL+1 F A="INDFN","INDF","INDLC","INDRN" S @(A_"(INDL)")=@A
 S INDFN=+$P(^DD(INDFN,INDF,0),"^",2),INDRN="|dd"_INDFN,(INDLC,INDF)=0
 Q
POP F A="INDFN","INDF","INDLC","INDRN" S @A=@(A_"(INDL)")
 S INDL=INDL-1 Q
REMCOMP ;Remove compiled template routines from selected list
 S %="|dd"
 F J=1:1 S %=$O(^UTILITY($J,%)) Q:%'?1"|dd".NP  S INDFN=+$E(%,4,999) I '$D(^DD(INDFN,0,"UP")) F F="^DIE(","^DIPT(" S F1=F_"""F"_INDFN_""",",%1="" F J=0:0 S %1=$O(@(F1_"%1)")) Q:%1=""  F %2=0:0 S %2=$O(@(F1_"%1,%2)")) Q:%2'>0  D P
 Q
P I $D(@(F_"%2,0)")) S R=$E($S($D(^("ROU")):^("ROU"),$D(^("ROUOLD")):^("ROUOLD"),1:""),2,999)
 Q:R=""
 I $D(^UTILITY($J,R)) K ^UTILITY($J,R)
 S RN=R F J=0:0 S RN=$O(^UTILITY($J,RN)) Q:RN=""!(RN'?@("1"""_R_"""1N.N"))  K ^UTILITY($J,RN)
 Q
