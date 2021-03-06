set datestyle to 'iso, mdy';

create table public.mam_test_reindex(pk_id serial8,my_text text[], constraint idx_mam_test_reindex_pkey primary key (pk_id));
CREATE INDEX es_mam_test_reindex ON public.mam_test_reindex USING zombodb((mam_test_reindex.*)) WITH ( replicas=1, shards=5);
insert into public.mam_test_reindex(my_text) values(array['bob']);
insert into public.mam_test_reindex(my_text) values(array['mark']);
alter table public.mam_test_reindex alter column my_text type text using my_text[1];
select assert(zdb.count('es_mam_test_reindex','my_text: "bob"'), 1, 'count estimate');
drop table mam_test_reindex;