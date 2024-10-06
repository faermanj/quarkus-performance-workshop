
    create sequence current_balance_SEQ start with 1 increment by 50;

    create sequence transacao_SEQ start with 1 increment by 50;

    create table current_balance (
        limit integer,
        total integer,
        id bigint not null,
        primary key (id)
    );

    create table transacao (
        kind varchar(1),
        amount integer,
        id bigint not null,
        submitted_at timestamp(6) with time zone,
        current_balance_id bigint,
        description varchar(10),
        primary key (id)
    );

    alter table if exists transacao 
       add constraint FKf375low74a2iyfxep0bk2maek 
       foreign key (current_balance_id) 
       references current_balance;
insert into current_balance (id, total, limit) values (1, 0, 100000);
insert into current_balance (id, total, limit) values (2, 0, 80000);
insert into current_balance (id, total, limit) values (3, 0, 1000000);
insert into current_balance (id, total, limit) values (4, 0, 10000000);
insert into current_balance (id, total, limit) values (5, 0, 500000);
