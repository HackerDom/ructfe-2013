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
        else if($_GET['action']=="registration")
             $this->registration();
        else if($_GET['action']=="acct")
            $this->acct();
        else if($_GET['action']=="login")
            $this->login();
        else if($_GET['action']=="transfer")
            $this->transfer();
         else if(isset($_GET['hash']))
            $this->bla();
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

        $sql="SELECT id, acct, type,balance FROM $tbl_name  WHERE user_id= '".$rows['id']."' ORDER BY id ";
        $result=mysql_query($sql);
        $this->mysqlClose();
                  while ($rows = mysql_fetch_array($result))
                   {
                        $search = array("/_title_/", "/_id_/", "/_acct_/","/_type_/","/_balance_/");
                        $replace = array("News Bank_CTF", $rows['id'],$rows['acct'], $rows['type'], $rows['balance'] );
                        $this->content.= preg_replace($search, $replace, file_get_contents('template/acct.template'));
                    }
         }
    }
    
    private function transfer()
    {  
        if(isset($_SESSION['name']))
        {
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
        if(isset($_POST['acct_out']) && isset($_POST['acct_in']) && isset($_POST['sum']))
        {
            $hash=base64_encode($_POST['acct_out'].' '.$_POST['acct_in'].' '.$_POST['sum']);
            header("Location: /index.php?hash=$hash");
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
                    $result = "HI, <a href=\"index.php?action=info\">".htmlspecialchars($row['name'])."</a>"
                            ."&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"index.php?action=logout\" class=\"exit\">Выйти</a>";
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
                    $result = "HI, <a href=\"index.php?action=info\">".htmlspecialchars($row['name'])."</a>"
                            ."&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"index.php?action=logout\" class=\"exit\">Выйти</a>";
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

    

    private function bla()
    {
         
            preg_match_all('/([a-zA-Z0-9]+)/',base64_decode($_GET['hash']),$ok);
            for ($i=0; $i<3; $i++) 
                {
                    $search = array("/_acct_out_/", "/_acct_in_/", "/_sum_/");
                     $replace = array(  $ok[1][$i++],  $ok[1][$i++],$ok[1][$i++]);
                    $this->content.= preg_replace($search, $replace, file_get_contents('template/review.template'));  
                }
          /*  $this->mysqlInit();
            $tbl_name="acct";
              $sql="SELECT balance, max_sum FROM $tbl_name  WHERE acct='".$acct_out."'";
            $result=mysql_query($sql);
            $this->mysqlClose();
            $rows = mysql_fetch_array($result);
            if ($rows['max_sum']<=$sum) 
            {
            $this->content.="Максимальная сумма перевода не должна привышать: ".$rows['max_sum'];
            } else
            {
                 $this->content.="бла бла бла бла";
            }*/
    }
}
?>