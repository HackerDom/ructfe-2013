<?php
class bank
{
    protected $content;
    
    public function bank()
            {
        $this->content = '';
            }
            
    public function run()
            {
        global $DB;
   
        if(isset($_SESSION['email']) && isset($_SESSION['type']) && $_SESSION['type']=="user" ){
$data="<li><a href=\"index.php?action=info_".$_SESSION['type']."\"> Info</a></li><li><a href=\"index.php?action=acct_".$_SESSION['type']."\"> ACCT</a></li><li><a href=\"index.php?action=add_review\"> Review</a></li><li><a href=\"index.php?action=transfer\">Transfer</a></li></li>";
		  $search = array("/_links_/");
        $replace = array($data );
        $this->content.= preg_replace($search, $replace, file_get_contents('template/header.template'));

		}else if(isset($_SESSION['email'])&& isset($_SESSION['type'])&& $_SESSION['type']=="company"  ){
$data="<li><a href=\"index.php?action=info_".$_SESSION['type']."\"> Info</a></li><li><a href=\"index.php?action=acct_".$_SESSION['type']."\"> ACCT</a></li><li><a href=\"index.php?action=transfer\">Transfer</a></li>";
		  $search = array("/_links_/");
        $replace = array($data );
        $this->content.= preg_replace($search, $replace, file_get_contents('template/header.template'));

		}
                else{
  	$search = array("/_links_/");
        $replace = array("" );
$this->content.= preg_replace($search, $replace, file_get_contents('template/header.template'));
      }
        if (!isset($_GET['action']) && !isset($_GET['hash'])&& !isset($_GET['hash_t'])) {
            $this->guestbook();
        } else if (isset($_GET['hash'])) {
        $this->hash();}
            else if (isset($_GET['hash_t'])) {
            $this->hash_transfer();
        } else if ($_GET['action'] == "accept") {
            $this->accept();
        }
        else if ($_GET['action'] == "add_review") {
            $this->add_review();
        } 
        else if ($_GET['action'] == "registration") {
            $this->registration();
        } else if ($_GET['action'] == "reg_user") {
            $this->reg_user();
        } else if ($_GET['action'] == "reg_company") {
            $this->reg_company();
        } else if ($_GET['action'] == "acct_user") {
            $this->acct_user();
        } else if ($_GET['action'] == "acct_company") {
            $this->acct_company();
        } else if ($_GET['action'] == "info_user") {
            $this->info_user();
        } else if ($_GET['action'] == "info_company") {
            $this->info_company();
        } else if ($_GET['action'] == "login") {
            $this->login();
        } else if ($_GET['action'] == "logout") {
            $this->logout();
        } else if ($_GET['action'] == "mytransfer") {
            $this->mytransfer();
        }else if ($_GET['action'] == "transfer") {
            $this->transfer();
        }else if ($_GET['action'] == "addacct") {
            $this->AddAcct();
        } else if ($_GET['action'] == "associates") {
            $this->associates();
        
        } else if ($_GET['action'] == "info") {
            $this->info_user();
        } else {
            $this->guestbook();
        }
        $search = array("/_login_/");
        $replace = array( $this->login());
        
      
            $this->content.=preg_replace($search, $replace,file_get_contents('template/footer.template'));
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
            
    private function associates()
            {
        $data="";
        $this->mysqlInit();
        $sql="SELECT  id,name_company,company_id FROM company_info  ORDER BY id LIMIT 30";
        $result=mysql_query($sql);
        $this->mysqlClose();
        while ($rows = mysql_fetch_array($result))
        {
              $this->mysqlInit();
            $sql="SELECT  email FROM company WHERE id='".$rows['company_id']."' ";
            $email = mysql_fetch_array(mysql_query($sql));
            $this->mysqlClose();
            $data.="<tr><td>".htmlspecialchars($rows['id'])."</td><td>".htmlspecialchars($rows['name_company'])."</td><td>".htmlspecialchars($email['email'])."</td></tr>";
        }
        $search = array("/_tbody_/");
        $replace = array($data );
        $this->content.= preg_replace($search, $replace, file_get_contents('template/associates.template'));
            }

    private function registration()
            {
        if( isset($_POST['passwd']) && isset($_POST['email']) && isset($_POST['type_table']))
            {
            $this->mysqlInit();
            $email = mysql_real_escape_string($_POST['email']);
            $passwd = mysql_real_escape_string($_POST['passwd']);
            $hashed_password =  password_hash($passwd, PASSWORD_DEFAULT);
            $tbl_name = mysql_real_escape_string($_POST['type_table']);
            $sql = "INSERT INTO $tbl_name (email, pass) VALUES ('$email', '$hashed_password')";
            $result = mysql_query($sql);
            if ($result)
                {
                $_SESSION['email'] = $email;
                $_SESSION['UID'] = $hashed_password;
                $_SESSION['type'] = $tbl_name;
                $this->login();
                $this->content.= $this->redirectMsg("Registration Continues", 1, "index.php?action=reg_".$tbl_name);
                } 
                } else {
                 $this->content.=preg_replace("/_link_/", "index.php?action=registration", file_get_contents('template/registration.template'));
    
                 
                    }
           }
           
    private function reg_user()
            {
        if(isset($_SESSION['email']) &&($_SESSION['type'])=="user")
            {
            if(isset($_POST['name'])&& isset($_POST['max_sum'])&& isset($_POST['surname']) && isset($_POST['country']) && isset($_POST['numbers']) && isset($_POST['birthday']))
                {
                $this->mysqlInit();
                $sql = "SELECT id FROM user WHERE email='".$_SESSION['email']."'";
                $rows = mysql_fetch_array(mysql_query($sql));
                $user_id=$rows['id'];
                $name = mysql_real_escape_string($_POST['name']);
                $currency = mysql_real_escape_string($_POST['currency']);
                $country = mysql_real_escape_string($_POST['country']);
                $numbers = mysql_real_escape_string($_POST['numbers']);
                $birthday = mysql_real_escape_string($_POST['birthday']);
                $surname=mysql_real_escape_string($_POST['surname']);
                $max_sum = mysql_real_escape_string($_POST['max_sum']);
                if(!isset($_FILES['doc']) || $_FILES['doc']['error'] == 4)
                    {
                    $this->content.=$this->redirectMsg("DOC!", 2, "index.php?action=reg_user");
                    }else{
                        $doc = basename($_FILES['doc']['name']);
                        move_uploaded_file($_FILES['doc']['tmp_name'], "scandoc/" . $doc);
                        $sql = "SELECT * FROM user_info WHERE name='$name'";
                        $result = mysql_query($sql);
                        if(mysql_fetch_array($result) == NULL){
                            $sql = "INSERT INTO `user_info`( `user_id`, `name`, `surname`, `country`, `numbers`, `birthday`, `doc`) VALUES ('$user_id','$name','$surname','$country','$numbers','$birthday','$doc')";
                            $result = mysql_query($sql);
                            if($result){
                                $acct = $this->acctRand();
                                $sql = "SELECT * FROM accts WHERE acct='$acct'";
                                if(mysql_fetch_array(mysql_query($sql)) == NULL)
                                    {
                                    $sql = "INSERT INTO accts (user_id,acct, currency,balance,max_sum) VALUES ('$user_id','$acct', '$currency','100', '$max_sum')";
                                    $result = mysql_query($sql);
                                    if(!$result)
                                        {
                                        $this->content.=$this->redirectMsg("An error has occurred!", 2, "index.php?action=reg_company");
                                        }
                                    }else{
                                        $acct = $this->acctRand();
                                        }
                               $this->content.=$this->redirectMsg("Registration was successful!", 1, "index.php");
                               }else{
                                   $this->content.=$this->redirectMsg("An error has occurred!", 2, "index.php?action=reg_user");
                                   }
                    }else {
                        $this->content.=$this->redirectMsg("This username is already used in DataBase.", 2, "index.php?action=reg_user");
                        }
                    }
                    
                    }else{
                        $this->content.= preg_replace("/_link_/", "index.php?action=reg_user", file_get_contents('template/reg_user.template'));
                        }
                        }
                        }
       
 private function reg_company()
    {
        $this->login();
           if(isset($_SESSION['email']) &&($_SESSION['type'])=="company")
        {
            if(isset($_POST['name_company'])&& isset($_POST['max_sum'])&& isset($_POST['address']) && isset($_POST['country']) 
                    && isset($_POST['numbers']) && isset($_POST['owner'])&& isset($_POST['created'])) {
            $this->mysqlInit();
              $sql = "SELECT * FROM company WHERE email='".$_SESSION['email']."'";
            $rows = mysql_fetch_array(mysql_query($sql));
             $company_id=$rows['id'];
             $name = mysql_real_escape_string($_POST['name_company']);
             $max_sum = mysql_real_escape_string($_POST['max_sum']);
             $address = mysql_real_escape_string($_POST['address']);
             $country = mysql_real_escape_string($_POST['country']);
             $numbers = mysql_real_escape_string($_POST['numbers']);
             $owner = mysql_real_escape_string($_POST['owner']);
             $created = mysql_real_escape_string($_POST['created']);
            $currency = mysql_real_escape_string($_POST['currency']);
          if (!isset($_FILES['doc']) || $_FILES['doc']['error'] == 4) {
                     $this->content.=$this->redirectMsg("DOC!", 2, "index.php?action=reg_user");
                } else {
                    $doc = basename($_FILES['doc']['name']);
                     move_uploaded_file($_FILES['doc']['tmp_name'], "scandoc/" . $doc);
            $sql = "SELECT * FROM company_info WHERE name_company='$name'";
            $result = mysql_query($sql);
            if (mysql_fetch_array($result) == NULL) {
                $sql = "INSERT INTO  `company_info` (  `company_id`,`name_company` ,  `country` ,  `address` ,  `created` ,  `numbers` ,  `owner` ,  `doc` ) 
VALUES (
'$company_id','$name',  '$country',  '$address',  '$created',  '$numbers',  '$owner',  ' $doc'
)";

                $result = mysql_query($sql);
                if ($result) {
                    $acct = $this->acctRand();
                    $sql = "SELECT company_id FROM company_info  WHERE name_company='$name'";
                    $result = mysql_query($sql);
                    $rows = mysql_fetch_array($result);
                    $company_id = $rows['company_id'];
                    $sql = "SELECT * FROM accts_company WHERE acct='$acct'";
                    $result = mysql_query($sql);
                    if (mysql_fetch_array($result) == NULL) {
                    $sql = "INSERT INTO accts_company (company_id,acct, currency,balance,max_sum) VALUES ('$company_id','$acct', '$currency','100', '$max_sum')";
                    $result = mysql_query($sql);
                    if (!$result){
                            $this->content.=$this->redirectMsg("An error has occurred!", 2, "index.php?action=reg_company");
                        }
                    }
                    else {
                        $acct = $this->acctRand();
                    }

                    $this->content.=$this->redirectMsg("Registration was successful!", 1, "index.php");
                } else {
                    $this->content.=$this->redirectMsg("An error has occurred!", 4, "index.php?action=reg_company");
                }
            }else {
                    $this->content.=$this->redirectMsg("This username is already used in DataBase.", 2, "index.php?action=reg_company");
                    
            }
                    
                    }}
         else {
            $this->content.= preg_replace("/_link_/", "index.php?action=reg_company", file_get_contents('template/reg_company.template'));
        }
        
         }
         
}

    private function redirectMsg($msg, $time, $location)
    {
        $search = array("/_msg_/", "/_time_/", "/_location_/", "/_seconds_/");
        $replace = array($msg, $time, $location, $time*1000);
        return preg_replace($search, $replace, file_get_contents('template/redirect.template'));
    }
    private function info_user()
            {
        if(isset($_SESSION['email']) && $_SESSION['type']=="user")
            {
            $this->mysqlInit();
            $sql="SELECT * FROM user INNER JOIN user_info on user.id = user_info.user_id WHERE email='".$_SESSION['email']."'";
            if(($row=mysql_fetch_array(mysql_query($sql))) != NULL )
                {
              $search = array("/_name_/","/_surname_/", "/_email_/",  "/_country_/",  "/_numbers_/", "/_birthday_/","/_doc_/");
                $replace = array(htmlspecialchars($row['name']),htmlspecialchars($row['surname']),htmlspecialchars($row['email']),htmlspecialchars($row['country']),htmlspecialchars($row['numbers']),htmlspecialchars($row['birthday']),htmlspecialchars($row['doc']));
                $this->content.= preg_replace($search, $replace, file_get_contents('template/info_user.template'));
                }}
                
            }
   private function info_company()
            {
        if(isset($_SESSION['email']))
            {
            $this->mysqlInit();
            $sql="SELECT * FROM company INNER JOIN company_info on company.id = company_info.company_id WHERE pass='".$_SESSION['UID']."'";
            if(($row=mysql_fetch_array(mysql_query($sql))) != NULL )
                {
              $search = array("/_name_company_/","/_email_/","/_country_/", "/_address_/",  "/_created_/",  "/_numbers_/", "/_owner_/","/_doc_/");
                $replace = array(htmlspecialchars($row['name_company']),htmlspecialchars($row['email']),htmlspecialchars($row['country']),htmlspecialchars($row['address']),htmlspecialchars($row['created']),htmlspecialchars($row['numbers']),htmlspecialchars($row['owner']),htmlspecialchars($row['doc']));
                $this->content.= preg_replace($search, $replace, file_get_contents('template/info_company.template'));
                }}
                
            }
   
      private function add_review()
           {
            if(isset($_SESSION['email']) &&($_SESSION['type'])=="user")
                {
                if(isset($_POST['comment'])){
                    
       $this->mysqlInit();
        $sql = "SELECT id FROM user WHERE email='".$_SESSION['email']."'";
        $result=mysql_query($sql);
           $row = mysql_fetch_array($result);
       $sql="INSERT INTO `reviews`( `id_user`, `comment`) VALUES ('". $row['id']."','".$_POST['comment']."')";
       $result=mysql_query($sql);
       $this->mysqlClose();
       $this->content.=$this->redirectMsg("", 0, "index.php");
                }else{
                     $this->content.= preg_replace("/_add_link_/", "index.php?action=add_review", file_get_contents('template/add_review.template'));
                }
           }
           
        }
        
   private function guestbook()
           {
       $this->mysqlInit();
       $data="";
       $sql="SELECT * FROM reviews INNER JOIN user on reviews.id_user = user.id  ORDER BY reviews.id DESC  LIMIT 30";
       $result=mysql_query($sql);
       $this->mysqlClose();
       while ($row = mysql_fetch_array($result))
                {
           $comment=htmlspecialchars($row["comment"]);
           $email=htmlspecialchars($row["email"]);
           $data.= " <div class=\"hero-unit\"><h2>$email:</h2><p>  $comment</p></div> ";
           }
           $this->content.= preg_replace("/_reviews_/", $data, file_get_contents('template/reviews.template'));
        }

    public function acct_user()
    {
         if(isset($_SESSION['email'])&&($_SESSION['type'])=="user")
        {
        $this->mysqlInit();
            
           $sql="SELECT * FROM user INNER JOIN user_info on user.id = user_info.user_id WHERE pass='".$_SESSION['UID']."'";
            if(($row=mysql_fetch_array(mysql_query($sql))) != NULL )
                {
                $data="";
        $i=0;
        $sql="SELECT  acct, currency,balance,max_sum FROM accts  WHERE user_id= '".$row['user_id']."' ORDER BY id ";
        $result=mysql_query($sql);
        $this->mysqlClose();
                  while ($rows = mysql_fetch_array($result))
                    {
                        $data.="<tr><td>".htmlspecialchars($rows['acct'])."</td><td>".htmlspecialchars($rows['balance'])."</td><td>".htmlspecialchars($rows['max_sum'])."</td><td>".htmlspecialchars($rows['currency'])."</td></tr>";
                        $i++;
                    }
                    $search = array("/_tbody_/");
                    $replace = array($data );
                    $this->content.= preg_replace($search, $replace, file_get_contents('template/acct.template'));
                     $this->content.= ($i>1) ? "<a href=\"index.php?action=mytransfer\" class=\"btn btn-large btn-primary\">Transfer between two cards</a>" :"";
                }
            }
    
                    }
     public function acct_company()
             {
         if(isset($_SESSION['email']))
             {
             $this->mysqlInit();
             $sql="SELECT * FROM company INNER JOIN company_info on company.id = company_info.company_id WHERE pass='".$_SESSION['UID']."'";
             if(($row=mysql_fetch_array(mysql_query($sql))) != NULL )
                {
                 $data="";
                 $sql="SELECT  acct, currency,balance,max_sum FROM accts_company  WHERE company_id= '".$row['company_id']."' ORDER BY id ";
                 $result=mysql_query($sql);
                 $rows=mysql_fetch_array($result);
                 $this->mysqlClose();
                 $data.="<tr><td>".htmlspecialchars($rows['acct'])."</td><td>".htmlspecialchars($rows['balance'])."</td><td>".htmlspecialchars($rows['max_sum'])."</td><td>".htmlspecialchars($rows['currency'])."</td></tr>";
                 $search = array("/_tbody_/");
                 $replace = array($data );
                 $this->content.= preg_replace($search, $replace, file_get_contents('template/accts_company.template'));
                 } 
            }else{
                $this->content.='Please Login!';
                }
            }
            
   private function mytransfer()
    {  
        if(isset($_SESSION['email']) &&($_SESSION['type'])=="user")
        {
       
        if(isset($_POST['acct_out']) && isset($_POST['acct_in']) && isset($_POST['sum']))
        {
            $hash=base64_encode($_POST['acct_out'].' '.$_POST['acct_in'].' '.$_POST['sum']);
            $this->content.=$this->redirectMsg("Request is being processed!", 5, "index.php?hash=$hash");
        }else{
            $data="";
            $this->mysqlInit();
            $sql="SELECT user_id FROM user INNER JOIN user_info on user.id = user_info.user_id WHERE email='".$_SESSION['email']."'";
            $row=mysql_fetch_array(mysql_query($sql));
            $sql="SELECT acct FROM accts  WHERE  user_id= '".$row['user_id']."' ORDER BY id ";
            $resylt=mysql_query($sql);
            $this->mysqlClose();
            while ($rows = mysql_fetch_array($resylt))
        {
           
          
         
            $data.="<option value=".$rows['acct'].">".htmlspecialchars($rows['acct'])."</option>";
        }
            $search = array("/_select_/");
                 $replace = array($data );
                 $this->content.= preg_replace($search, $replace, file_get_contents('template/mytransfer.template'));
           
            }
        }
     }


             private function transfer()
    {  
        if(isset($_SESSION['email']))
        {
       
        if(isset($_POST['acct_out']) && isset($_POST['acct_in']) && isset($_POST['sum']))
        {
            $hash=base64_encode($_POST['acct_out'].' '.$_POST['acct_in'].' '.$_POST['sum']);
            $this->content.=$this->redirectMsg("Request is being processed!", 5, "index.php?hash_t=$hash");
        }else{
            $this->content.= file_get_contents('template/transfer.template');
           
            }
        }
     }
    private function logout()
    {
        if(isset($_SESSION['email']))
        {
            session_unset();
            if(isset($_COOKIE['email']) && isset($_COOKIE['UID']))
                {
                SetCookie("email","");
                SetCookie("UID","");
                }
            $this->content.=$this->redirectMsg("", 0, "index.php");
        }
    }
    private function login()
    {
        $result = "";
        if(isset($_COOKIE['email']) && isset($_COOKIE['UID']) && isset($_SESSION['type']))
        {
            $this->mysqlInit();
           $type=$_SESSION['type'];
           $email =$_COOKIE['email'];
   
           $sql="SELECT * FROM $type WHERE email='$email' and pass='".$_COOKIE['UID']."'" ;
            $result=mysql_query($sql);
     
            if (($row = mysql_fetch_array($result)) != NULL) {
              
                    $result = "<div class='well span3'>
<legend>Welcome <a href=\"index.php?action=info_".$_COOKIE['type']."\">" . htmlspecialchars($row['email']) . "</a>!</legend>

<h4>Our community is glad to see you! We value our customers.  we believe it is our duty to inform you that there is no bank safer than ours!</h4>
<form method='POST' action='index.php?action=logout' accept-charset'UTF-8'>
<button type='submit' name='submit' class='btn btn-block btn-success btn-large'>Exit<i class='icon-move'></i></button>
</form>
</div>"; 
                $_SESSION['email'] = $_COOKIE['email'];
                    $_SESSION['UID'] = $_COOKIE['UID'];
                    $_SESSION['type'] = $_COOKIE['type'];
                   
              
            
            $this->mysqlClose();
        }
            }
        else if(isset($_SESSION['email']) && isset($_SESSION['UID']) && isset($_SESSION['type']))
        {
            $this->mysqlInit();
            $type=$_SESSION['type'];
            $sql="SELECT * FROM $type WHERE email='".$_SESSION['email']."'";
            $result=mysql_query($sql);
            if (($row = mysql_fetch_array($result)) != NULL) {
                if ($row['pass'] == $_SESSION['UID']) {
                    $result = "<div class='well span3'>
<legend>Welcome <a href=\"index.php?action=info_".$_SESSION['type']."\">" . htmlspecialchars($row['email']) . "</a>!</legend>

<h4>Our community is glad to see you! We value our customers. And we believe it is our duty to inform you that there is no bank safer than ours!</h4>
<form method='POST' action='index.php?action=logout' accept-charset'UTF-8'>
<button type='submit' name='submit' class='btn btn-block btn-success btn-large'>Exit<i class='icon-move'></i></button>
</form>
</div>";
                            
                }else{$result = "erro";}
            }
           
          else {
                $result = "COOKIE ERROR!";
            }
            $this->mysqlClose();
        }else       if(isset($_POST['email']) && isset($_POST['passwd']) )
        {
            $this->mysqlInit();
            if ( isset($_POST['type']))
                {
                $tbl_name="company";
                
                }else{
                    $tbl_name="user";}
            $email = mysql_real_escape_string($_POST['email']);
            $passwd =mysql_real_escape_string($_POST['passwd']);
            
            $sql="SELECT * FROM $tbl_name WHERE email='$email'";
            $result=mysql_query($sql);
            if (($row = mysql_fetch_array($result)) != NULL) {
                if (password_verify($passwd, $row['pass'] )){
                    $_SESSION['email'] = $email;
                    $_SESSION['UID'] = $row['pass'];
                    $_SESSION['type'] = $tbl_name;
                    if (isset($_POST['remember']) && $_POST['remember'] == "remember") {
                        setcookie("email", $email, time() + 28800);
                        setcookie("UID", $row['pass'], time() + 28800);
                         setcookie("type", $tbl_name, time() + 28800);
                         
                    }
                    $result = $this->redirectMsg("", 0, "index.php");
                } else {
                    $result = "<div class='well span3'>Incorrect Data!</div>";
                    
                }
            }
            else {
                $result = "<div class='well span3'>Incorrect Data!</div>";
                
            }
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
        for ($i=0; $i <4 ; $i++)
        {
            $acct.= mt_rand(1000, 9999);
        }
        return $acct;
     }
     
    private function AddAcct()
            {
        if(isset($_SESSION['email']))
            {
            if( isset($_POST['summ']) &&  isset($_POST['currency']))
                {
                $this->mysqlInit();
                $currency=mysql_real_escape_string($_POST['currency']);
                $summ=mysql_real_escape_string($_POST['summ']);
                 $sql="SELECT * FROM user INNER JOIN user_info on user.id = user_info.user_id WHERE pass='".$_SESSION['UID']."'";
                 $result=mysql_query($sql);
                if(($row=mysql_fetch_array($result)) != NULL )
                {
                    $user_id=$row['user_id'];
                    $acct= $this->acctRand();
                    $tbl_name="accts";
                    $sql="SELECT * FROM $tbl_name WHERE acct='$acct'";
                    $result=mysql_query($sql);
                    if(mysql_fetch_array($result) == NULL)
                        {
                        $sql="INSERT INTO $tbl_name (user_id,acct, currency,balance,max_sum) VALUES ('$user_id','$acct', '$currency','100', '$summ')";
                        $result = mysql_query($sql);
                        if ($result)
                            {
                            $this->content.=$this->redirectMsg("Success!", 1, "index.php");
                            }else{
                                $this->content.=$this->redirectMsg("An error has occurred!", 2, "index.php?action=addacct");
                                 }
                                 
                        }else{
                            $acct= $this->acctRand();
                            }
                            
                        }
                        
                        }else{
                            $this->content.= preg_replace("/_link_/", "index.php?action=addacct", file_get_contents('template/addacct.template'));
                            
                        }
                        
                        }else{
                            $this->content.=$this->redirectMsg("Please Login!", 2, "index.php?action=index");
                            
                        }
    }


    private function hash()
    {
         
            preg_match_all('/([a-zA-Z0-9]+)/',base64_decode($_GET['hash']),$ok);
            $this->mysqlInit();
            $sql="SELECT balance, max_sum FROM accts  WHERE acct='". $ok[1][0]."'";
            $result=mysql_query($sql);
            $this->mysqlClose();
            $out = mysql_fetch_array($result);
            $this->mysqlInit();
             $sql="SELECT balance, max_sum FROM accts  WHERE acct='". $ok[1][1]."'";
            $result=mysql_query($sql);
            $this->mysqlClose();
            $in = mysql_fetch_array($result);
            $balans_in=base_convert($in['balance'], 36, 10);
            $balans_out=base_convert($out['balance'], 36, 10);
            $max_sum=base_convert($out['max_sum'], 36, 10);
            $sum_trans=base_convert($ok[1][2], 36, 10);
            if ($max_sum <=  $sum_trans ) {
            $this->content.="<p>Maximum amount of transfer not to exceed:" . $out['max_sum'] . "</p>";
            $this->content.=$this->redirectMsg("Please re-transfer!", 5, "index.php?action=index");
        } else if($balans_out<=  $sum_trans){
            $this->content.="You have insufficient funds for the transaction.";
        } else {
             $this->mysqlInit();
               $balans_out-=$sum_trans;
               $balans_in+=$sum_trans;
              $balans_out=base_convert($balans_out, 10, 36);
              $balans_in=base_convert($balans_in, 10, 36);
           
              $sql="UPDATE `accts` SET  `balance` = '$balans_out' WHERE `acct`='". $ok[1][0]."'";
               $result=mysql_query($sql); 
              $sql="UPDATE `accts` SET  `balance` = '$balans_in' WHERE `acct`='". $ok[1][1]."'";
             $result=mysql_query($sql);
          
        $this->content.="Transfer done!";
        }
    }
    
    private function hash_transfer()
    {
         
            preg_match_all('/([a-zA-Z0-9]+)/',base64_decode($_GET['hash_t']),$ok);
            
            if($_SESSION['type']=="company" || $_COOKIE['type']=="company"){
            $this->mysqlInit();    
            $sql="SELECT balance, max_sum FROM accts_company  WHERE acct='". $ok[1][0]."'";
            $result1=mysql_query($sql);
            $this->mysqlClose();
            $out_table="accts_company";
            }else{
                $this->mysqlInit();
            $sql="SELECT balance, max_sum FROM accts  WHERE acct='". $ok[1][0]."'";
            $result1=mysql_query($sql);
            $this->mysqlClose();
            $out_table="accts";
            }
            
            $this->mysqlInit();
            $sql="SELECT balance, max_sum FROM accts  WHERE acct='". $ok[1][1]."'";
            $result=mysql_query($sql);
            $this->mysqlClose();
            $in_table="accts";
            if(!$result){
            $this->mysqlInit();    
            $sql="SELECT balance, max_sum FROM accts_company  WHERE acct='". $ok[1][1]."'";
            $result=mysql_query($sql);
            $this->mysqlClose();
            $in_table="accts_company";
             }
            $in = mysql_fetch_array($result);
            $out = mysql_fetch_array($result1);
            $balans_in=base_convert($in['balance'], 36, 10);
            $balans_out=base_convert($out['balance'], 36, 10);
          
            $max_sum=base_convert($out['max_sum'], 36, 10);
            $sum_trans=base_convert($ok[1][2], 36, 10);
            if($balans_out<  $sum_trans){
            $this->content.="You have insufficient funds for the transaction.";
        } else {
             $this->mysqlInit();
               $balans_out-=$sum_trans;
               $balans_in+=$sum_trans;
              $balans_out=base_convert($balans_out, 10, 36);
              $balans_in=base_convert($balans_in, 10, 36);
        
              $sql="UPDATE   $out_table SET  `balance` = '$balans_out' WHERE `acct`='". $ok[1][0]."'";
               $result1=mysql_query($sql); 
              $sql="UPDATE   $in_table SET  `balance` = '$balans_in' WHERE `acct`='". $ok[1][1]."'";
             $result=mysql_query($sql);
            
        $this->mysqlClose();
         $this->content.="Transfer done!";
        }
    }
}
