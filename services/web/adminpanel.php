<?php
class adminpanel {
    protected $content;
    
    public function admin()
            {
        $this->content = "";
            }
   public function run()
           {
       global $DB;
       $search = array("/_title_/",  "/_login_/");
       $replace = array("Bank_CTF", $this->login() );
       $this->content.=preg_replace($search, $replace, file_get_contents('template/admin/header.template'));
   
        if(!isset($_GET['action']) || $_GET['action']=="login")
        {
            if(isset($_SESSION['email']) && isset($_SESSION['UID'])){
            $this->index(); 
            $this->login();}else{ $this->index();}
        }
       else if($_GET['action']=="logout")
           $this->logout();
       else if($_GET['action']=="transfer")
           $this->transfer();
       else if($_GET['action']=="user_info")
           $this->user_info();
       else if($_GET['action']=="company_info")
           $this->company_info();
       else
           {
            $this->index(); 
            }
            $this->content.=file_get_contents('template/footer.template');
     
        echo $this->content;
           }
           
    private function index()
    {   if(isset($_SESSION['email'])){
       
      
       $this->content.=  file_get_contents('template/admin/index.template');
    }
    }

           
    private function mysqlInit()
    {
        global $DB;
        mysql_connect($DB['host'], $DB['login'], $DB['passwd'])or die("can not connect");
        mysql_select_db($DB['db_name'])or die("can not select DB");
    }
    
    private function mysqlClose()
    {
        mysql_close();
    }
        private function redirectMsg($msg, $time, $location)
    {
        $search = array("/_msg_/", "/_time_/", "/_location_/", "/_seconds_/");
        $replace = array($msg, $time, $location, $time*1000);
        return preg_replace($search, $replace, file_get_contents('template/redirect.template'));
    }
    private function logout()
    {
        if(isset($_SESSION['email']))
        {
            session_unset();
            $this->content.=$this->redirectMsg("", 0, "badmin.php");
        }
    }
    private function login()
    {
        $result = "";
        if(isset($_SESSION['email']) && isset($_SESSION['UID']))
        {
             $this->mysqlInit();
            $sql="SELECT * FROM admins WHERE email='".$_SESSION['email']."'";
            $result=mysql_query($sql);
             if (($row = mysql_fetch_array($result)) == NULL) {
               
                $result = "SESSION ERROR!";
            }
            $this->mysqlClose();
        }
      else  if(isset($_POST['email']) && isset($_POST['passwd']))
        {
            $this->mysqlInit();
            $email = mysql_real_escape_string($_POST['email']);
            $passwd =$_POST['passwd'];
            $sql="SELECT * FROM admins WHERE email='$email'";
            $result=mysql_query($sql);
            if (($row = mysql_fetch_array($result)) != NULL) {
                if (password_verify($passwd, $row['pass'] )){
                    $_SESSION['email'] = $email;
                    $_SESSION['UID'] = $row['pass'];
                    $result = $this->redirectMsg("", 0, "badmin.php");
                } else {
                    $result =  "Incorrect Data!";
                }
            }
            else {
                $result =  "Incorrect Data!";
            }
            $this->mysqlClose();
        }
        else
        {
            $search = array("/_login_link_/");
            $replace = array("badmin.php?action=login");
            $result = preg_replace($search, $replace, file_get_contents('template/admin/login.template'));
        }

     
    }
    private function company_info()
    {
          if(isset($_SESSION['email']) && isset($_SESSION['UID'])){
        $this->index();
        $data="";
        $this->mysqlInit();
        $sql="SELECT id,name_company,doc FROM company_info";
        $result=mysql_query($sql);
           $this->mysqlClose();
                  while ($rows = mysql_fetch_array($result))
                    {
                        $data.="<tr><td>".$rows['id']."</td><td>".$rows['name_company']."</td><td>".$rows['doc']."</td></tr>";
                       
                    }
                    $search = array("/_tbody_/");
                    $replace = array($data );
          $this->content.= preg_replace($search, $replace, file_get_contents('template/admin/user_info.template'));}
    }
    
    private function user_info()
    {
          if(isset($_SESSION['email']) && isset($_SESSION['UID'])){
           $this->index();
           $data="";
        $this->mysqlInit();
        $sql="SELECT id,name,doc FROM user_info";
        $result=mysql_query($sql);
           $this->mysqlClose();
                  while ($rows = mysql_fetch_array($result))
                    {
                        $data.="<tr><td>".$rows['id']."</td><td>".$rows['name']."</td><td>".$rows['doc']."</td></tr>";
                      
                    }
                    $search = array("/_tbody_/");
                    $replace = array($data );
    $this->content.= preg_replace($search, $replace, file_get_contents('template/admin/user_info.template'));
    
                    }
    }
  
    
            }
