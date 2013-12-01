#!/bin/bash

set -f

export PATH=""  # we call cmds only using full paths

readonly ldapsocket="ldapi://%2Fhome%2Fcontacts%2Fldap%2Fsocket"

readonly cat=/bin/cat
readonly grep=/bin/grep
readonly base64=/usr/bin/base64
readonly ldapsearch=/usr/bin/ldapsearch
readonly ldapadd=/usr/bin/ldapadd

readonly filter1='^userPassword'
readonly filter2='^mail'

print_cgi_header() {
	echo "Content-Type: $1"
	echo
}

urldecode(){
	local p="${1//\+/ }"
	echo -e "${p//%/\\x}"
}

register_params() {
	declare -a parm=("${!1}")

	for p in ${parm[@]}; do
		decoded_p="$(urldecode "$p")"
		export "${decoded_p//$'\n'/ }"
	done
}

parse_params() {
	local parm
	saveIFS="$IFS"
	IFS='&' parm=(${QUERY_STRING:-action=index})
	IFS="$saveIFS"

	register_params parm[@]
}

print_contact() {
	local fullname="$1"
	local phone="$2"
	local mail="$3"
	local userPassword="$4"

	echo '<div class="contact">'
	if [[ -n $fullname ]]; then
		echo '<div class="name" style="font-size: x-large; margin-bottom: 5px"><b>' $fullname '</b></div>'
	fi
	if [[ -n $phone ]]; then
		echo '<div class="phone">' '<span class="phone_text">Phone:</span>' $phone '</div>'
	fi
	if [[ -n $mail ]]; then
		echo '<div class="mail">' '<span class="mail_text">Mail:</span>' $mail '</div>'
	fi
	if [[ -n $userPassword ]]; then
		echo '<div class="password">' '<span class="password_text">Password:</span>' $userPassword '</div>'
	fi
	echo '</div>'
}

header() {
	echo "$IFS"

	$cat << EOF
<html>
<head>
<link href="//netdna.bootstrapcdn.com/bootstrap/3.0.2/css/bootstrap.min.css" rel="stylesheet">
<script src="//netdna.bootstrapcdn.com/bootstrap/3.0.2/js/bootstrap.min.js"></script>
<link rel="stylesheet" type="text/css" href="?action=css" media="all">
<title>Address book</title>
<head>
<body>

<div class="top_panel">
<a href="?" class="title h1">Address book</a>
</div>

EOF
}

footer() {
	$cat << EOF
</body>
</html>
EOF
}

index_page() {
	header

	$cat << EOF

<div class="row">

<form class="col-sm-4" action="">
	<button type="submit" class="form-control btn btn-primary">search</button>
	<input type="hidden" name="action" value="search">
	<input type="text" class="search-input form-control" name="q" value="" placeholder="*">
</form>


<form class="col-sm-4" action="">
	<button type="submit" class="form-control btn btn-warning">get userinfo</button>
	<input type="hidden" name="action" value="info">
	<input type="text" class="info-input form-control" name="name" value="$name" placeholder="first name">
	<input type="text" class="info-input form-control" name="surname" value="$surname" placeholder="last name">
	<input type="text" class="info-input form-control" name="password" value="$password" placeholder="password">
</form>

<form class="col-sm-4" action="">
	<button type="submit" class="form-control btn btn-success">add somebody</button>
	<input type="hidden" name="action" value="add">
	<input type="text" class="add-input form-control" name="name" value="$name" placeholder="first name">
	<input type="text" class="add-input form-control" name="surname" value="$surname" placeholder="last name">
	<input type="text" class="add-input form-control" name="phone" value="$phone" placeholder="phone">
	<input type="text" class="add-input form-control" name="email" value="$email" placeholder="email">
	<input type="text" class="add-input form-control" name="password" value="$password" placeholder="password">
</form>

</div>

EOF

	footer
}

add_page() {
	header

	$cat << EOF | $ldapadd -H $ldapsocket -w ctf -D "cn=Manager,dc=ructfe,dc=org" &>/dev/null
dn: cn=${name} ${surname},dc=ructfe,dc=org
cn: ${name} ${surname}
sn: ${surname}
telephoneNumber: ${phone}
objectclass: inetOrgPerson
mail: ${email}
userPassword: ${password}
EOF

	local result="$?"

	if [[ $result == 0 ]]; then
		echo '<a href="?" class="successmsg text-center text-success">Success</a>'
	elif [[ $result == 68 ]]; then
		echo '<a href="?" class="errormsg text-center">Already exists</a>'
	elif [[ $result == 34 ]]; then
		echo '<a href="?" class="errormsg text-center">Bad form data</a>'
	elif [[ $result == 21 ]]; then
		echo '<a href="?" class="errormsg text-center">Bad form data</a>'
	else
		echo '<a href="?" class="errormsg text-center">Unknown error</a>'
	fi

	footer
}

info_page() {
	header

	if [[ $password = *'*'* ]]; then
		echo Security alert
		return
	fi

	local results=`$ldapsearch -LLL -H $ldapsocket -x -b "dc=ructfe,dc=org" -s sub "(&(objectclass=inetOrgPerson)(cn=${name} ${surname})(userPassword=${password}))"`

	if [[ -z $results ]]; then
		echo '<a href="?" class="longerrormsg text-center">Wrong username or password!</a>'

		return
	fi

	while read line; do
		if [[ -z $line ]]; then
			fullname=""
			phone=""
			email=""
			userPassword=""
		elif [[ $line == cn:* ]]; then
			fullname="${line:4}"
		elif [[ $line == telephoneNumber:* ]]; then
			phone="${line:17}"
		elif [[ $line == mail:* ]]; then
			mail="${line:6}"
		elif [[ $line == userPassword:* ]]; then
			userPassword="${line:15}"
		fi

		if [[ -n $fullname && -n $phone && -n $mail && -n $userPassword ]]; then
			print_contact "$fullname" "$phone" "$mail" "$userPassword"

			fullname=""
			phone=""
			email=""
			userPassword=""
		fi
	done <<< "$results"

	footer
}

search_results_page() {
	header

	$cat << EOF
<div class="row">
<form class="col-sm-4" action="">
	<input type="text" class="search-input form-control" name="q" value="$q" placeholder="*">
	<input type="hidden" name="action" value="search">
	<button type="submit" class="form-control btn btn-primary">search again</button>
</form>
</div>

EOF

	if [[ $q != '*'* ]]; then
		q="*$q"
	fi

	if [[ $q != *'*' ]]; then
		q="$q*"
	fi


	local results=`$ldapsearch -H $ldapsocket -LLL -x -b "dc=ructfe,dc=org" -S cn -s sub "(&(objectclass=inetOrgPerson)(cn=${q}))" | $grep -i -v $filter1 - | $grep -i -v $filter2 -`

	local fullname
	local phone

	echo '<div class="contactlist">'

	while read line; do
		if [[ -z $line ]]; then
			fullname=""
			phone=""
		elif [[ $line == cn:* ]]; then
			fullname="${line:4}"
		elif [[ $line == telephoneNumber:* ]]; then
			phone="${line:17}"
		fi

		# don't remove this raw functionality
		if [[ -n $raw ]]; then
			echo $line
		fi

		if [[ -n $fullname && -n $phone ]]; then
			print_contact "$fullname" "$phone"

			fullname=""
			phone=""
		fi
		# echo line $line;
	done <<< "$results"
	echo '</div>'

	footer
}

render_css() {
	# background-color: gray;
	$cat << EOF
	# width: 800px;
body {
	text-align: left;
}

.title {
	display: block;
	text-align: center;
	margin-top: 10px;
	margin-bottom: 25px;
}

.title:hover {
	color: black;
	text-decoration:none;
}

.row {
	margin: 0;
}

.add-input:hover {
	background-color: #DEF5DB;
}

.info-input:hover {
	background-color: #FCE7C8;
}

.search-input:hover {
	background-color: #D3E0EA;
}

input,button {
	margin: 5px;
}

.contactlist {
	clear: both;
}

.contact {
	margin: 10px;
	padding: 10px;
	border-style: solid;
	border-color: #428DCA;
	border-width: 3px;
	float: left;
}

.contact:hover {
	background-color: #D3E0EA;
}

.phone_text,.mail_text,.password_text {
	color: gray;
}

.successmsg {
	display: block;
	font-size: 100pt;
	color: #9DF588;
}

.errormsg {
	display: block;
	font-size: 100pt;
	color: #F59794;
}

.longerrormsg {
	display: block;
	font-size: 50pt;
	color: #F59794;
}

EOF
}

parse_params

case "$action" in
	index )
		print_cgi_header "text/html"
		index_page
		;;
	add )
		print_cgi_header "text/html"
		add_page
		;;
	info )
		print_cgi_header "text/html"
		info_page
		;;
	search )
		print_cgi_header "text/html"
		search_results_page
		;;
	css )
		print_cgi_header "text/css"
		render_css
		;;
	* )
		print_cgi_header "text/html"
		index_page
		;;
esac

