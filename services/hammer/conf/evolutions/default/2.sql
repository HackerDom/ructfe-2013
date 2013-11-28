# Creating base messages
# --- !Ups

create table MESSAGES (
  ID int not null auto_increment primary key,
  MESSAGE text not null,
  SECRET VARCHAR(255) not null,
  MARK VARCHAR (255) not null unique,
  CREATED TIMESTAMP not null,
  AUTHOR int not null,
  CONSTRAINT author_fk foreign key(AUTHOR) references USERS(ID),
);

create table MESSAGES_TO_USERS(
  USER int not null,
  MESSAGE int not null,

  unique(USER,MESSAGE),
  FOREIGN KEY (USER) references USERS(ID),
  FOREIGN KEY (MESSAGE) references MESSAGES(ID),
);

create index  on MESSAGES(MARK);
create index  on MESSAGES(AUTHOR);
create index  on MESSAGES_TO_USERS(USER);
create index  on MESSAGES_TO_USERS(MESSAGE);

# --- !Downs

drop table MESSAGES;
drop table MESSAGES_TO_USERS;