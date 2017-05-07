#!/usr/bin/perl
#
# gen.pl Password generator by nuTshell
# <carloslack at gmail dot com>
# http://nutshell.gotfault.net
#
# Part of eland(c) by posidron http://posidron.gotfault.net
#
# Gen was originally written to be part of Eland and then i`ve
# decided to publish this "user" version.
#
# Usage eg:
# $ ./gen.pl -all 8 3 join users.txt
# [!] Generating: Ge|{R[12
# [!] Generating: ;?#MMT%A
# [!] Generating: k8bW$RHx
#
# Passwords number: 3
# Passwords length: 8
# Output file pass_all.txt created
# Combo file combo.txt created
# $ cat users.txt
# root
# admin
# you
# $ cat combo.txt
# root:Ge|{R[12
# root:;?#MMT%A
# root:k8bW$RHx
# admin:Ge|{R[12
# admin:;?#MMT%A
# admin:k8bW$RHx
# you:Ge|{R[12
# you:;?#MMT%A
# you:k8bW$RHx
#
use strict;
use Switch;

sub usage() {
printf("Gen by nuTshell <http://nutshell.gotfault.net>\n");
printf("Usage: $0 options parameters\n");
printf("Options are:\n");
printf("-lower [gen lower case passwords only]\n");
printf("-uplowerchar [gen upper case passwords only]\n");
printf("-uplowerint [gen upper case/lower case/integer passwords only]\n");
printf("-uplower [gen upper case/lower case passwords only]\n");
printf("-upper [gen upper case passwords only]\n");
printf("-int [gen integer passwords only]\n");
printf("-lowerint [gen lower case/integer passwords only]\n");
printf("-upint [gen upper case/integer passwords only]\n");
printf("-lowerchar [gen lower case/special caracters passwords only]\n");
printf("-upchar [gen upper case/special caracters passwords only]\n");
printf("-all [FULL! gen all passwords options]\n");
printf("Parameters are:\n");
printf("passowrd length (required integer)\n");
printf("number of passwords (required integer)\n");
printf("join (literal optional)\n");
printf("userfile name (optional)\n");
exit(0)
}

my @lower =
split(",","a,b,c,d,e,f,g,h,i,j,l,m,n,o,p,q,r,s,t,u,v,x,z,y,w,k");

my @upper =
split(",","A,B,C,D,E,F,G,H,I,J,L,M,N,O,P,Q,R,S,T,U,V,X,Z,Y,W,K");

my @uplower =
split("," ,"b,c,d,e,f,g,h,i,j,l,m,n,o,p,q,r,s,t,u,v,x,z,y,w,k,A,B,C," . "D,E,F,G,H,I,J,L,M,N,O,P,Q,R,S,T,U,V,X,Z,Y,W,K");

my @uplowerchar =
split("=", "#=*=,=.=;=:=_=-=+=!=\$=%=&=/=|=?={=}=[=]=(=)=" . "
-a=b=c=d=e=f=g=h=i=j=l=m=n=o=p=q=r=s=t=u=v=x=z=y=" . "w=k=A=B=C=D=E=F=G=H=I=J=L=M=N=O=P=Q=R=S=T=U=V=X=Z=Y=W=K");

my @uplowerint =
split(",","1,2,3,4,5,6,7,8,9,0,b,c,d,e,f,g,h,i,j,l,m,n,o,p,q,r," . "s,t,u,v,x,z,y,w,k,A,B,C,D,E,F,G,H,I,J,L,M,N,O,P,Q,R,S,T,U,V," . "X,Z,Y,W,K");

my @int = split(",","1,2,3,4,5,6,7,8,9,0");

my @lowerint =
split(",","1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,l,m,n," . "o,p,q,r,s,t,u,v,x,z,y,w,k");

my @upint =
split(",","1,2,3,4,5,6,7,8,9,0,A,B,C,D,E,F,G,H,I,J,L,M," . "N,O,P,Q,R,S,T,U,V,X,Z,Y,W,K");

my @lowerchar =
split("=","a=b=c=d=e=f=g=h=i=j=l=m=n=o=p=q=r" . "=s=t=u=v=x=z=y=w=k=#=*=,=.=;=:=_=-=+=!=\" . "$=%=&=/=|=?={=}=[=]=(=)=");

my @upchar =
split("=","A=B=C=D=E=F=G=H=I=J=L=M=N=O=P=Q=" . "R=S=T=U=V=X=Z=Y=W=K=#=*=,=.=;=:=_=-=+=!=" . "\$=%=&=/=|=?={=}=[=]=(=)=");

my @all =
split("=","1=2=3=4=5=6=7=8=9=0=a=b=c=d=e=f=" . "g=h=i=j=l=m=n=o=p=q=r=s=t=u=v=x=z=y=w=k=" . "#=*=,=.=;=:=_=-=+=!=\$=%=&=/=|=?={=}=[=]=(=)" . "=A=B=C=D=E=F=G=H=I=J=L=M=N=O=P=Q=R=S=T" . "=U=V=X=Z=Y=W=K=");

my $passoutputfile;
my $var;
my $x;
my $usersfile;
my @array;

my $ARRAY = $ARGV[0] or die &usage;
my $LOOPLENGTH = $ARGV[1] or die &usage;
my $PASSWORDNUMBER = $ARGV[2] or die &usage;

switch($ARRAY) {
        case "-all" {@array = @all ; $passoutputfile = "pass_all.txt"}
        case "-upchar" {@array = @upchar ; $passoutputfile = "pass_upchar.txt"}
        case "-lowerchar" {@array = @lowerchar ; $passoutputfile =
"pass_lowerchar.txt"}
        case "-upint" {@array = @upint ; $passoutputfile = "pass_upint.txt"}
        case "-lowerint" {@array = @lowerint ; $passoutputfile =
"pass_lowerint.txt"}
        case "-int" {@array = @int ; $passoutputfile = "pass_int.txt"}
        case "-upper" {@array = @upper ; $passoutputfile = "pass_upper.txt"}
        case "-lower" {@array = @lower ; $passoutputfile = "pass_lower.txt"}
        case "-uplower" {@array = @uplower ; $passoutputfile = "pass_uplower.txt"}
        case "-uplowerchar" {@array = @uplowerchar ; $passoutputfile =
"pass_uplowerchar.txt"}
        case "-uplowerint" {@array = @uplowerint ; $passoutputfile =
"pass_uplowerint.txt"}
         else {&usage}
}


sub genpass () {

open(PASSFILE, ">$passoutputfile") or die "$!\n";

for($x=0;$x<$PASSWORDNUMBER;$x++) {
foreach(1..$LOOPLENGTH) {
my $array = $array[rand(@array)] ;
$var .= "$array";
}
print("[!] Generating: $var\n");
print(PASSFILE "$var\n");
$var = "";
}
close(PASSFILE);
printf "\nPasswords number: $PASSWORDNUMBER\n";
printf "Passwords length: $LOOPLENGTH\n";
printf "Output file $passoutputfile created\n";
}
&genpass;


sub joinfiles (){
my @loop1 = `/bin/cat $usersfile` or die "$\n";
my @loop2 = `/bin/cat $passoutputfile` or die "$\n";
open(COMBO, ">combo.txt") or die "$!\n";
foreach my $user (@loop1) {
           foreach (@loop2) {
                  chomp($user);
                print(COMBO "$user:$_");
         }
}
close(COMBO);
printf("Combo file combo.txt created\n");
}

if ($ARGV[3] eq "join") {
        if($ARGV[4]) {$usersfile = $ARGV[4]}else{$usersfile = "users.txt"}
        &joinfiles
}
#eof 
