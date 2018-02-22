select * from s3672792.cidades as c limit 100

select codmun from s3672792.cidades as c limit 100

select nome from s3672792.cidades as c limit 100

select codmun, nome from s3672792.cidades as c limit 100

select codmun, 1 as dummy from s3672792.cidades as c limit 100

select codmun,nome
,strpos(nome,'/') as pos_barra
,substr(nome, strpos(nome,'/')+1) as estado
from s3672792.cidades as c limit 100

select codmun,nome
,case when nome ilike '%R%' then 1 else 0 end as tem_r
,case when substr(nome,1,strpos(nome,'/')) ilike '%R%' then 1 else 0 end as tem_r_1
,case when codmun%2 = 0 then 1 else 0 end as eh_par
from s3672792.cidades as c limit 100

select codmun,nome
,substr(nome, strpos(nome,'/')+1) as estado
from s3672792.cidades as c where nome ilike 'Rib%Preto' limit 100

select 
c.codmun,c.nome,s.descricao,s.valor::integer
from s3672792.cidades c
left outer join s3672792.sintese_informacao s on (c.codmun = s.codmun)
where 
descricao = 'Estabelecimentos de Saúde SUS'
and 
case when valor = '-' then null else valor::integer end > 10


select 
c.codmun, c.nome
from s3672792.cidades c


select 
s.descricao, s.valor
from s3672792.sintese_informacao s


select 
c.codmun,c.nome,s.descricao,s.valor
from s3672792.cidades c
left outer join s3672792.sintese_informacao s on (c.codmun = s.codmun)


select 
c.codmun,c.nome,s.descricao, s.valor
from s3672792.cidades c
left outer join s3672792.sintese_informacao s on (c.codmun = s.codmun)
where 
descricao like 'População residente - %'


select 
c.codmun,c.nome,s.descricao, s.valor::numeric
from s3672792.cidades c
left outer join s3672792.sintese_informacao s on (c.codmun = s.codmun)
where 
descricao like 'População residente - %'


select 
c.codmun,c.nome,s.descricao, 
case when s.valor = '-' then null 
else s.valor::numeric 
end as valor
from s3672792.cidades c
left outer join s3672792.sintese_informacao s on (c.codmun = s.codmun)
where 
descricao like 'População residente - %'


select 
c.codmun,c.nome
,substr(c.nome,strpos(c.nome,'/')+1) as estado
,s.descricao
,case 
when s.valor = '-' then null 
else replace(s.valor,'.','')::numeric 
end as valor
from s3672792.cidades c
left outer join s3672792.sintese_informacao s on (c.codmun = s.codmun)
where 
descricao like 'População residente - %'


create view s3672792.vpopulacao as
select 
c.codmun,c.nome
,substr(c.nome,strpos(c.nome,'/')+1) as estado
,s.descricao
,case 
when s.valor = '-' then null 
else replace(s.valor,'.','')::numeric 
end as valor
from s3672792.cidades c
left outer join s3672792.sintese_informacao s on (c.codmun = s.codmun)
where 
descricao like 'População residente - %'



select * from s3672792.vpopulacao



select estado from s3672792.vpopulacao group by estado


select  estado, count(*) from s3672792.vpopulacao group by estado


select  estado, sum(valor) as total from s3672792.vpopulacao group by estado


select  estado, descricao, sum(valor) from s3672792.vpopulacao 
group by estado, descricao


select estado, descricao
,avg(valor)
,count(*)
,min(valor)
,max(valor)
,sum(valor)
,stddev_pop(valor) 
,stddev_samp(valor)
,var_pop(valor)
,var_samp(valor) 
from s3672792.vpopulacao
group by estado, descricao

create view s3672792.vregressao as
select 
c.codmun,c.nome,
substr(c.nome,strpos(nome,'/')+1) as estado
,case when spop.valor = '-' then null else replace(spop.valor,'.','')::numeric 
end as pop_alfabetizada
,case when smat.valor = '-' then null else replace(smat.valor,'.','')::numeric 
end as pop_matriculada_em_2015
from s3672792.cidades c
left outer join s3672792.sintese_informacao spop 
on (c.codmun = spop.codmun 
    and spop.descricao like 'População residente alfabetizada')
left outer join s3672792.sintese_informacao smat 
on (c.codmun = smat.codmun 
    and smat.descricao like 'Matrícula - Ensino médio - 2015')


select estado
,corr(v.pop_matriculada_em_2015,v.pop_alfabetizada)
,covar_pop(v.pop_matriculada_em_2015,v.pop_alfabetizada)
,regr_intercept(v.pop_matriculada_em_2015,v.pop_alfabetizada)
,regr_slope(v.pop_matriculada_em_2015,v.pop_alfabetizada)
,regr_r2(v.pop_matriculada_em_2015,v.pop_alfabetizada)
from s3672792.vregressao v
group by estado
order by estado


create table s3672792.sintese_informacao_new as 
select distinct * from s3672792.sintese_informacao;

delete from  s3672792.sintese_informacao;

insert into s3672792.sintese_informacao
select * from s3672792.sintese_informacao_new;

drop table s3672792.sintese_informacao_new;


ALTER TABLE s3672792.cidades DROP COLUMN "row.names"; /*apagando a coluna row.names*/
  ALTER TABLE s3672792.cidades ADD COLUMN estado CHAR(2); /*criando a coluna estado*/
  UPDATE s3672792.cidades SET estado = substr(nome,strpos(nome,'/')+1) /*atualizando a coluna estado*/
  
  drop table  s3672792.cidade_sintese;
create table s3672792.cidade_sintese as
select distinct c.codmun,c.nome, c.estado
,case when spop.valor = '-' then null else replace(spop.valor,'.','')::numeric end as pop_alfabetizada
,case when smat.valor = '-' then null else replace(smat.valor,'.','')::numeric end as pop_matriculada_em_2015
,case when spoph.valor = '-' then null else replace(spoph.valor,'.','')::numeric end as pop_homens
,case when spopm.valor = '-' then null else replace(spopm.valor,'.','')::numeric end as pop_mulheres
,case when sus.valor = '-' then null else replace(sus.valor,'.','')::numeric end as nro_estab_sus
from s3672792.cidades c left outer join s3672792.sintese_informacao spop 
on (c.codmun = spop.codmun and spop.descricao = 'População residente alfabetizada')
left outer join s3672792.sintese_informacao smat 
on (c.codmun = smat.codmun and smat.descricao = 'Matrícula - Ensino médio - 2015')
left outer join s3672792.sintese_informacao spoph 
on (c.codmun = spoph.codmun and spoph.descricao = 'População residente - Homens')
left outer join s3672792.sintese_informacao spopm 
on (c.codmun = spopm.codmun and spopm.descricao = 'População residente - Mulheres')
left outer join s3672792.sintese_informacao sus 
on (c.codmun = sus.codmun and sus.descricao = 'Estabelecimentos de Saúde SUS')


select *
  , c.pop_mulheres+c.pop_homens as pop_total
, c.pop_alfabetizada/pop_total
from s3672792.cidade_sintese c


select *, t1.pop_alfabetizada/pop_total from (
  select *
    , c.pop_mulheres+c.pop_homens as pop_total
  from s3672792.cidade_sintese c
) as t1
