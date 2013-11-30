# Add user tables
# --- !Ups

create table USERS (
  ID int not null auto_increment primary key,
  LOGIN varchar(255) not null ,
  PASSWORD varchar(255) not null ,
  SALT varchar (32) not null ,
  NAME varchar(255) not null,

  unique(LOGIN)
)
# --- !Downs
drop table USERS;