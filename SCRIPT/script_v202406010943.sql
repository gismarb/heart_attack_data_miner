-- PARTE 01: CARREGANDO DADOS NO FORMATO ORIGINAL (TRANSFORMANDO CSV EM UMA TABELA)
-- Criacao do BD para carga dos dados iniciais (orginais e com tratamentos)
create database ha;

-- Rotina ha01: criando tabelas, importando dados CSV
use ha;

-- Rotina para criar a tabela dataset01 (sem tratamento)
create table dataset01 (
	age numeric(15,2),
    anaemia int,
    creatinine_phosphokinase int,
    diabetes int,
    ejection_fraction int,
    high_blood_pressure int,
    platelets numeric(15,2),
    serum_creatinine numeric(15,2),
    serum_sodium int,
    sex int,
    smoking int,
    time int,
    DEATH_EVENT int
);

-- Analisando o escopo da tabela criada
describe dataset01;

-- Rotina para importar "CSV" para a tabela "dataset01"
load data infile 'C:/TEMP/heart_failure_clinical_records_dataset.csv'
into table dataset01
fields terminated by ','
ignore 1 rows;

-- Conferindo a consistência da importacao (299 linhas retirando a linha de rotulo) 
select count(*) from dataset01;

-- Consultando os dados (projetando a tabela dataset01)
select * from dataset01;

-- --------------------------------------------------

-- PARTE 02: PRIMEIRA RODADA DE TRATAMENTO - INDENTIFICANDO CLASSES NOS ATRIBUTOS BINÁRIOS

-- Rotina para criar a tabela dataset02
create table dataset02 (
	age numeric(15,2),
    anaemia varchar(3),
    creatinine_phosphokinase numeric(15,2),
    diabetes varchar(3),
    ejection_fraction int,
    high_blood_pressure varchar(3),
    platelets numeric(15,2),
    serum_creatinine numeric(15,2),
    serum_sodium int,
    sex char(1),
    smoking varchar(3),
    time int,
    DEATH_EVENT varchar(3)
);

-- Projetando dados usando a estrutura (SQL) "CASE" para tratar dados binarios e inserindo na NOVA TABELA (dataset02)
insert into dataset02
select ds.age,
	   case 
	       when ds.anaemia = 1 then 'YES'
           else 'NO'
	   end as anaemia,
	   ds.creatinine_phosphokinase,
	   case
           when ds.diabetes = 1 then 'YES'
           else 'NO'
	   end as diabetes,
	   ds.ejection_fraction,
	   case
           when ds.high_blood_pressure = 1 then 'YES'
           else 'NO'
	   end as high_blood_pressure,
	   ds.platelets,
	   ds.serum_creatinine,
	   ds.serum_sodium,
	   case
           when ds.sex = 1 then 'M'
           else 'F'
	   end as sex,
	   case
           when ds.smoking = 1 then 'YES'
           else 'NO'
       end as smoking,
	   ds.time,
	   case
           when ds.DEATH_EVENT = 1 then 'YES'
           else 'NO'
       end as DEATH_EVENT
       
from ha.dataset01 ds;

-- Conferindo a consistência da importacao (299 linhas retirando a linha de rotulo) 
select count(*) from dataset02;

-- Consultando os dados (projetando a tabela dataset01)
select * from dataset02;

-- Rotina para gerar CSV para testes (WEKA)
(select 'age',
        'anaemia',
        'creatinine_phosphokinase',
        'diabetes',
        'ejection_fraction',
        'high_blood_pressure',
        'platelets',
        'serum_creatinine',
        'serum_sodium',
        'sex',
        'smoking',
        'time',
        'DEATH_EVENT'
)
union
(select age,
        anaemia,
        creatinine_phosphokinase,
        diabetes,
        ejection_fraction,
        high_blood_pressure,
        platelets,
        serum_creatinine,
        serum_sodium,
        sex,
        smoking,
        time,
        DEATH_EVENT

into outfile 'C:/TEMP/dataset02.csv'
fields enclosed by ''
terminated by ','
lines terminated by '\r\n'

from ha.dataset02);

-- --------------------------------------------------

-- PARTE 03: SEGUNDA RODADA DE TRATAMENTO - DISCRETIVANDO ATRIBUTOS (VALORADOS)
-- Rotina para criar a tabela dataset03
create table dataset03 (
	age numeric(15,2),
    anaemia varchar(3),
    creatinine_phosphokinase varchar(10),
    diabetes varchar(3),
    ejection_fraction varchar(10),
    high_blood_pressure varchar(3),
    platelets varchar(10),
    serum_creatinine varchar(10),
    serum_sodium varchar(10),
    sex char(1),
    smoking varchar(3),
    time int,
    DEATH_EVENT varchar(3)
);

-- Projetando dados usando a estrutura (SQL) "CASE" para tratar dados binarios e inserindo na NOVA TABELA (dataset02)
insert into dataset03
select ds.age,
       ds.anaemia,
       case
       when ds.sex = 'M' and (ds.creatinine_phosphokinase * 0.0167) < 32 then 'LOW'
       when ds.sex = 'M' and (ds.creatinine_phosphokinase * 0.0167) > 294 then 'HIGH'
       when ds.sex = 'M' and ((ds.creatinine_phosphokinase * 0.0167) >= 32 or (ds.creatinine_phosphokinase * 0.0167) <= 294) then 'NORMAL'
       when ds.sex = 'F' and (ds.creatinine_phosphokinase * 0.0167) < 33 then 'LOW'
       when ds.sex = 'F' and (ds.creatinine_phosphokinase * 0.0167) > 211 then 'HIGH'
       when ds.sex = 'F' and ((ds.creatinine_phosphokinase * 0.0167) >= 33 or (ds.creatinine_phosphokinase * 0.0167) <= 211) then 'NORMAL'
       else 'WRONG'
       end as creatinine_phosphokinase,
       ds.diabetes,
       case
           when ds.ejection_fraction < 40 then 'LOW'
           when ds.ejection_fraction > 55 then 'HIGH'
           else 'NORMAL'
       end as ejection_fraction,
       ds.high_blood_pressure,
       case
           when ds.platelets < 150000 then 'LOW'
           when ds.platelets > 450000 then 'HIGH'
           else 'NORMAL'
       end as platelets,
       case 
           when ds.sex = 'M' and ds.serum_creatinine < 0.74 then 'LOW'
           when ds.sex = 'M' and ds.serum_creatinine > 1.35 then 'HIGH'
           when ds.sex = 'M' and (ds.serum_creatinine >= 0.74 or ds.serum_creatinine <= 1.35) then 'NORMAL'
           when ds.sex = 'F' and ds.serum_creatinine < 0.59 then 'LOW'
           when ds.sex = 'F' and ds.serum_creatinine > 1.04 then 'HIGH'
           when ds.sex = 'F' and (ds.serum_creatinine >= 0.59 or ds.serum_creatinine <= 1.04) then 'NORMAL'
           else 'WRONG'
       end as serum_creatinine,
       case
           when ds.serum_sodium < 135 then 'LOW'
           when ds.serum_sodium > 145 then 'HIGH'
           else 'NORMAL'
       end as serum_sodium,
       ds.sex,
       ds.smoking,
       ds.time,
       ds.DEATH_EVENT
       
from ha.dataset02 ds;

-- Conferindo a consistência da importacao (299 linhas retirando a linha de rotulo) 
select count(*) from dataset03;

-- Consultando os dados (projetando a tabela dataset02)
select * from dataset03;

-- Rotina para gerar CSV para testes (WEKA)
(select 'age',
        'anaemia',
        'creatinine_phosphokinase',
        'diabetes',
        'ejection_fraction',
        'high_blood_pressure',
        'platelets',
        'serum_creatinine',
        'serum_sodium',
        'sex',
        'smoking',
        'time',
        'DEATH_EVENT'
)
union
(select age,
        anaemia,
        creatinine_phosphokinase,
        diabetes,
        ejection_fraction,
        high_blood_pressure,
        platelets,
        serum_creatinine,
        serum_sodium,
        sex,
        smoking,
        time,
        DEATH_EVENT

into outfile 'C:/TEMP/dataset03.csv'
fields enclosed by ''
terminated by ','
lines terminated by '\r\n'

from ha.dataset03);





