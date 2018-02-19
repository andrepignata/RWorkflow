ALTER TABLE XXXXXXXXXX.cidades DROP COLUMN "row.names"; /*apagando a coluna row.names*/
ALTER TABLE XXXXXXXXXX.cidades ADD COLUMN estado CHAR(2); /*criando a coluna estado*/
UPDATE XXXXXXXXXX.cidades SET estado = substr(nome,strpos(nome,'/')+1) /*atualizando a coluna estado*/
========================================================================================================
/*drop table  XXXXXXXXXX.cidade_sintese;*/
create table XXXXXXXXX.cidade_sintese as
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

========================================================================================================
select *
    , c.pop_mulheres+c.pop_homens as pop_total
    , c.pop_alfabetizada/pop_total
  from XXXXXXXXXX.cidade_sintese c


========================================================================================================  
select *, t1.pop_alfabetizada/pop_total from (
    select *
      , c.pop_mulheres+c.pop_homens as pop_total
    from XXXXXXXXXX.cidade_sintese c
  ) as t1