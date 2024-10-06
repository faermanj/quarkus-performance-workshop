create table "clients" ("id" serial not null primary key, "limit" integer not null, "current_balance" integer not null default '0');
create table "transactions" ("id" serial not null primary key, "client_id" integer not null, "amount" integer not null, "kind" varchar(1) not null, "description" varchar(10) not null, "submitted_at" varchar(255) not null);
create index "transactions_client_id_id_index" on "transactions" ("client_id", "id");
insert into "clients" ("id", "limit") values (1, 100000), (2, 80000), (3, 1000000), (4, 10000000), (5, 500000) on conflict ("id") do update set "id" = "excluded"."id", "limit" = "excluded"."limit";
