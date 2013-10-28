Checksystem Control Panel
-------------------------

0. INSTALL

   On Ubuntu 12.04 LTS: 
   apt-get install libdancer-perl libdbi-perl libdbd-pg-perl 

   For 'Git pull' function to work, you need '~/.git/askpass' 
   executable, which prints to stdout your Git's password :)

1. CONFIGURE

   Edit ./environments/*.yml

2. START / STOP 

   Run: ./start.sh to start, ./stop.sh to stop

3. USE

   Open URL "http://<IP>:3000/" in your browser

