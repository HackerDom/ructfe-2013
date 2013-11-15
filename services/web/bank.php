<?php
class bank
{
    protected $content;

    public function forum()
    {
        $this->content = "";
    }

    public function run()
    {
        global $DB;

        $search = array("/_title_/",  "/_login_/");
        $replace = array("Bank_CTF", $this->login() );
        $this->content.=preg_replace($search, $replace, file_get_contents('template/header.template'));
        if(!isset($_GET['action']) && !isset($_GET['hash']))
            $this->news();
        else if(isset($_GET['hash']))
            $this->hash();
        
        else if($_GET['action']=="accept")
             $this->accept();
        else if($_GET['action']=="registration")
             $this->registration();
        else if($_GET['action']=="acct")
            $this->acct();
        else if($_GET['action']=="login")
            $this->login();
        else if($_GET['action']=="logout")
            $this->logout();
        else if($_GET['action']=="transfer")
            $this->transfer();
        else if($_GET['action']=="addacct")
            $this->AddAcct();
        else
            $this->news();
     
        $this->content.=file_get_contents('template/footer.template');
     
        echo $this->content;
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

private function registration()
    {
        if(/*isset($_POST['register']) && isset($_POST['tbl_name']) &&*/ isset  ($_POST['name']) &&  isset ($_POST['passwd']) && isset($_POST['email'])&&  isset($_POST['country'])&& isset($_POST['numbers'])&& isset($_POST['gender'])&& isset($_POST['birthday']))
        {
            $name = mysql_real_escape_string($_POST['name']);
            $passwd = mysql_real_escape_string($_POST['passwd']);
            $email=mysql_real_escape_string($_POST['email']);
            $country= mysql_real_escape_string($_POST['country']);
            $numbers= mysql_real_escape_string($_POST['numbers']);
            $gender= mysql_real_escape_string($_POST['gender']);
            $birthday= mysql_real_escape_string($_POST['birthday']);
            $hashed_password = md5( $passwd);
            //password_hash($passwod, PASSWORD_DEFAULT);
            $tbl_name="user";
            //mysql_real_escape_string($_POST['tbl_name']);;
            $this->mysqlInit();

            $sql="SELECT * FROM $tbl_name WHERE name='$name'";
            $result=mysql_query($sql);
            if(mysql_fetch_array($result) == NULL)
            {
                $sql="INSERT INTO $tbl_name (name,email, pass,country,  numbers, gender,birthday) VALUES ('$name','$email', '$hashed_password', '$country',  '$numbers','$gender','$birthday')";
                $result = mysql_query($sql);
                if($result)
                    $this->content.=$this->redirectMsg("Удача!", 1, "index.php");
                else
                    $this->content.=$this->redirectMsg("Произошла ошибка!", 2, "index.php?action=registration");

            }
            else
                $this->content.=$this->redirectMsg("В наших рядах уже есть \"$name\"!", 3, "index.php?action=registration");
            $this->mysqlClose();
        }
        else
           $this->content.= preg_replace("/_link_/", "index.php?action=registration", file_get_contents('template/registration.template'));
    }
   private function redirectMsg($msg, $time, $location)
    {
        $search = array("/_msg_/", "/_time_/", "/_location_/", "/_seconds_/");
        $replace = array($msg, $time, $location, $time*1000);
        return preg_replace($search, $replace, file_get_contents('template/redirect.template'));
    }
    private function news()
    {
     
        $this->mysqlInit();
        $search = array("/_title_/",  "/_news_/");
        $replace = array("News Bank_CTF", "ааавсвыячсофылор" );
        $this->content.= preg_replace($search, $replace, file_get_contents('template/news.template'));
        $this->mysqlClose();
    }

    public function acct()
    {
         if(isset($_SESSION['name']))
        {
        $this->mysqlInit();
        $tbl_name='user';
        $sql="SELECT * FROM $tbl_name WHERE name='".$_SESSION['name']."'";
        $result=mysql_query($sql);
        $rows=mysql_fetch_array($result);
        $tbl_name="accts";
        $data="";
        $i=0;
        $sql="SELECT id, acct, type,balance FROM $tbl_name  WHERE user_id= '".$rows['id']."' ORDER BY id ";
        $result=mysql_query($sql);
        $this->mysqlClose();
                  while ($rows = mysql_fetch_array($result))
                    {
                        $data.="<tr><td>".$rows['id']."</td><td>".$rows['acct']."</td><td>".$rows['type']."</td><td>".$rows['balance']."</td></tr>";
                        $i++;
                    }
                    $search = array("/_tbody_/");
                    $replace = array($data );
                    $this->content.= preg_replace($search, $replace, file_get_contents('template/acct.template'));
                     $this->content.= ($i>1) ? "<a href=\"index.php?action=transfer\" class=\"btn btn-large btn-primary\">Перевести с карты на карту</a>" :"";
         }
    }
    
    private function transfer()
    {  
        if(isset($_SESSION['name']))
        {
       
        if(isset($_POST['acct_out']) && isset($_POST['acct_in']) && isset($_POST['sum']))
        {
            $hash=base64_encode($_POST['acct_out'].' '.$_POST['acct_in'].' '.$_POST['sum']);
            $this->content.=$this->redirectMsg("Идет обработка запроса!", 10, "index.php?hash=$hash");
        }else{

             $this->mysqlInit();
        $tbl_name='user';
        $sql="SELECT * FROM $tbl_name WHERE name='".$_SESSION['name']."'";
        $result=mysql_query($sql);
        $rows=mysql_fetch_array($result);
        $tbl_name="accts";
        $sql="SELECT acct, type FROM $tbl_name  WHERE  user_id= '".$rows['id']."' ORDER BY id ";
        $result=mysql_query($sql);
        $this->mysqlClose();
        $this->content.= file_get_contents('template/transfer.template');
        }
         
    }
        }


    private function logout()
    {
        if(isset($_SESSION['name']))
        {
            session_unset();
            SetCookie("name","");
            SetCookie("UID","");
            $this->content.=$this->redirectMsg("", 0, "index.php");
        }
    }

 
    
    private function login()
    {
        $result = "";
        if(isset($_SESSION['name']) && isset($_SESSION['UID']))
        {
            $this->mysqlInit();
            $tbl_name='user';
            $sql="SELECT * FROM $tbl_name WHERE name='".$_SESSION['name']."'";
            $result=mysql_query($sql);
            if(($row=mysql_fetch_array($result)) != NULL)
            {
                if($row['pass']==$_SESSION['UID'])
                  $result = "<ul class='nav'><li><a href=\"index.php?action=info\">".htmlspecialchars($row['name'])."</a></li>"
                            ."<li><a href=\"index.php?action=acct\">ACCT</a></li><li><a href=\"index.php?action=logout\" class=\"exit\">Выйти</a></li></ul>";
                  }
            else
                $result = "SESSION ERROR!";
            $this->mysqlClose();
        }
        else if(isset($_COOKIE['name']) && isset($_COOKIE['UID']))
        {
            $this->mysqlInit();
            $tbl_name='user';
            $sql="SELECT * FROM $tbl_name WHERE name='".$_COOKIE['name']."'";
            $result=mysql_query($sql);
            if(($row=mysql_fetch_array($result)) != NULL)
            {
                if($row['pass']==$_COOKIE['UID'])
                {
                    $result = "HI, <li><a href=\"index.php?action=info\">".htmlspecialchars($row['name'])."</a></li>"
                            ."&nbsp;&nbsp;&nbsp;<li><a href=\"#index.php?action=acct\">ACCT</a></li>&nbsp;&nbsp;&nbsp;<li><a href=\"index.php?action=logout\" class=\"exit\">Выйти</a></li>";
                    $_SESSION['name'] = $_COOKIE['name'];
                    $_SESSION['UID'] = $_COOKIE['UID'];
                    $result.=$this->redirectMsg("", 0, "index.php");
                }
            }
            else
                $result = "COOKIE ERROR!";
            $this->mysqlClose();
        }else       if(isset($_POST['login']) && isset($_POST['passwd']))
        {
            $this->mysqlInit();
            $name = mysql_real_escape_string($_POST['login']);
            $passwd =md5($_POST['passwd']);
            $tbl_name='user';
            $sql="SELECT * FROM $tbl_name WHERE name='$name'";
            $result=mysql_query($sql);
            if(($row = mysql_fetch_array($result)) != NULL)
            {
                if($passwd==$row['pass'])//password_verify($passwd, $row['passwd'] ))
                {
                    $_SESSION['name'] = $name;
                    $_SESSION['UID'] = $row['pass'];
                    if(isset($_POST['remember']) && $_POST['remember']=="remember")
                    {
                        setcookie("name", $name, time()+28800);
                        setcookie("UID",$row['pass'], time()+28800);
                    }
                    $result = $this->redirectMsg("", 0, "index.php");
                }
                else
                    $result = "Неправильные данные!";
            }
            else
                $result = "Неправильные данные!";
            $this->mysqlClose();
        }
        else
        {
            $search = array("/_login_link_/", "/_reg_link_/");
            $replace = array("index.php?action=login", "index.php?action=registration");
            $result = preg_replace($search, $replace, file_get_contents('template/login.template'));
        }

        return $result;
    }

    private function acctRand()
    {
       $acct="";
       for ($i=0; $i <4 ; $i++) { 
                $acct.= mt_rand(1000, 9999);
            }
            return $acct;
    }
    private function AddAcct()
    {
        if(isset($_SESSION['name']))
            {
                if( isset  ($_POST['summ']) &&  isset ($_POST['type']))
                    {
                        $summ = mysql_real_escape_string($_POST['summ']);
                        $type=mysql_real_escape_string($_POST['type']);
                        $acct= $this->acctRand();
                        $this->mysqlInit();
                        $tbl_name='user';
                        $sql="SELECT id FROM $tbl_name WHERE name='".$_SESSION['name']."'";
                        $result=mysql_query($sql);
                        $rows=mysql_fetch_array($result);
                        $user_id= $rows['id'];
                        $tbl_name="accts";
                       
                        $sql="SELECT * FROM $tbl_name WHERE acct='$acct'";
                        $result=mysql_query($sql);
                        if(mysql_fetch_array($result) == NULL)
                            {
                                $sql="INSERT INTO $tbl_name (user_id,acct, type,balance,max_sum) VALUES ('$user_id','$acct', '$type','100', '$summ')";
                                $result = mysql_query($sql);
                                if($result)
                                    $this->content.=$this->redirectMsg("Удача!", 1, "index.php");
                                else
                                    $this->content.=$this->redirectMsg("Произошла ошибка!", 2, "index.php?action=addacct");
                            }
                            else
                                {
                                    $acct= $this->acctRand();
                                }
                    }
                    else
                        {
                              $this->content.= preg_replace("/_link_/", "index.php?action=addacct", file_get_contents('template/addacct.template')); 
                        }
            }
            else
                {
                    $this->content.=$this->redirectMsg("Войдите в систему!", 2, "index.php?action=index");
                }
    }


    private function hash()
    {
         
            preg_match_all('/([a-zA-Z0-9]+)/',base64_decode($_GET['hash']),$ok);
  /*          for ($i=0; $i<3; $i++) 
                {
                    $search = array("/_acct_out_/", "/_acct_in_/", "/_sum_/");
                     $replace = array(  $ok[1][$i++],  $ok[1][$i++],$ok[1][$i++]);
                    $this->content.= preg_replace($search, $replace, file_get_contents('template/review.template'));  
                }
*/
      
            $this->mysqlInit();
            $tbl_name="accts";
              $sql="SELECT balance, max_sum FROM $tbl_name  WHERE acct='". $ok[1][0]."'";
            $result=mysql_query($sql);
            $this->mysqlClose();
            $rows = mysql_fetch_array($result);
            if ($rows['max_sum']<=$ok[1][2]) 
            {
            $this->content.="<p>Максимальная сумма перевода не должна привышать: ".$rows['max_sum']."</p>";
            $this->content.=$this->redirectMsg("Повторите платеж!", 5, "index.php?action=index");
            } else
     
                 $this->content.="Перевод осуществлен";
            }
     
    
}

?>