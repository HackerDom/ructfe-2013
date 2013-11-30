# Creating base messages
# --- !Ups

create table MESSAGES (
  ID int not null auto_increment primary key,
  MESSAGE text not null,
  SECRET VARCHAR(255),
  MARK VARCHAR (255) not null unique,
  CREATED TIMESTAMP default CURRENT_TIMESTAMP not null,
  AUTHOR_ID int not null,
  CONSTRAINT AUTHOR_FK foreign key(AUTHOR_ID) references USERS(ID),
);

create table MESSAGES_TO_USERS(
  USER_ID int not null,
  MESSAGE_ID int not null,

  unique(USER_ID,MESSAGE_ID),
  FOREIGN KEY (USER_ID) references USERS(ID),
  FOREIGN KEY (MESSAGE_ID) references MESSAGES(ID),
);

create index  on MESSAGES(MARK);
create index  on MESSAGES(AUTHOR_ID);
create index  on MESSAGES_TO_USERS(USER_ID);
create index  on MESSAGES_TO_USERS(MESSAGE_ID);

# --- !Downs

drop table MESSAGES;
drop table MESSAGES_TO_USERS;