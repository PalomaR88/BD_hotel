create table REGIMENES
(
    CODIGO  varcahr2(2),
    NOMBRE  varcahr2(50),
    constraint PK_COD_REG primary key (CODIGO),
    constraint FORMAT_COD_REG check (CODIGO in ('AD','MP','PC','TI')),
    constraint UNICO_NOMB_REG unique (NOMBRE)
);

create table PERSONAS
(
    NIF         varchar2(9),
    NOMBRE      varchar2(50) constraint NULL_NOMBRE_PERS NOT NULL,
    APELLIDOS   varchar2(50) constraint NULL_APELLIDOS_PERS NOT NULL,
    DIRECCION   varchar2(50) constraint NULL_DIRECCION_PERS NOT NULL,
    LOCALIDAD   varchar2(50) constraint NULL_LOCALIDAD_PERS NOT NULL,
	constraint PK_NIF_PERS primary key (NIF),
	constraint FORMAT_NIF_PERS check(regexp_like(NIF, '^[0-9]{8}[A-Z]$|^[KLMXYZ][0-9]{7}[A-Z]$')),
	constraint FORMAT_LOCALIDAD_PERS check(LOCALIDAD like '%(Salamanca)%' or LOCALIDAD like '%(Avila)%' or LOCALIDAD like '%(Madrid)%'),
	constraint UNICO_DIRECCION_PERS unique (DIRECCION)
);

create table TEMPORADAS
(
    CODIGO  varchar2(1),
    NOMBRE  varchar2(50),
    constraint PK_COD_TEMP primary key (CODIGO),
    constraint UNICO_NOMBRE_TEMP unique (NOMBRE)
);

create table TIPOS_HABITACIONES
(
    CODIGO  varchar2(1),
    NOMBRE  varchar2(50),
    constraint PK_COD_THAB primary key (CODIGO),
    constraint UNICO_NOMB_THAB unique (NOMBRE)
);

create table HABITACIONES
(
    NUMERO      varchar2(2),
    COD_TIPO    varchar2(1),
    constraint PK_NUM_HAB primary key (NUMERO),
    constraint FK_TIPO_HAB foreign key (COD_TIPO) references TIPOS_HABITACIONES (CODIGO)
);

create table TARIFAS
(
    CODIGO          varchar2(2),
    COD_TIPO_HAB    varchar2(1),
    COD_TEMP        varchar2(1),
    COD_REG         varchar2(2),
    PRECIO_DIA      NUMBER(6,2),
    constraint PK_COD_TAR primary key (CODIGO),
    constraint FK_TIPO_HAB_TAR foreign key (COD_TIPO_HAB) references TIPOS_HABITACIONES (CODIGO),
    constraint FK_COD_TEMP_TAR foreign key (COD_TEMP) references TEMPORADAS (CODIGO),
    constraint FK_COD_REG_TAR foreign key (COD_REG) references REGIMENES (CODIGO)
);

create table ACTIVIDADES
(
    CODIGO              varchar2(7),
    NOMBRE              varchar2(40),
    DESCRIPCION         varchar2(40),
    PRECIO_PERS         number(6,2),
    COMISION_HOTEL      number(6,2),
    COSTE_PERS_HOTEL    number(6,2),
    constraint PK_COD_ACT primary key (CODIGO),
    constraint FORMAT_COD_ACT check (regexp_like(CODIGO, '^[A-Z]\-[0-9]{4,10}$')),
    constraint FORMAT_COMISION_ACT check (trunc(COMISION_HOTEL,2) < PRECIO_PERS * 0.25),
    constraint UNICO_NOMB_ACT unique (NOMBRE)
);

create table ESTANCIAS
(
    CODIGO          varchar2(5),
    FECHA_INICIO    date,
    FECHA_FIN       date,
    NUM_HABITACION  varchar2(2),
    NIF_RESPONSABLE varchar2(9),
    NIF_CLIENTE     varchar2(9),
    COD_REGIMEN     varchar2(2),
    constraint PK_COD_EST primary key (CODIGO),
    constraint FK_NUM_HAB_EST foreign key (NUM_HABITACION) references HABITACIONES (NUMERO),
    constraint FK_NIF_RESP_EST foreign key (NIF_RESPONSABLE) references PERSONAS (NIF),
    constraint FK_NIF_CLIEN_EST foreign key NIF_CLIENTE) references PERSONAS (NIF),
    constraint FK_COD_EST_EST foreign key (COD_REGIMEN) references REGIMENES(CODIGO),
    constraint FORMAT_FECHA_INICIO_EST check (to_char(FECHA_INICIO, 'HH24:MI') < '21:00')
);

create table GASTOS_EXTRAS
(
    COD_GASTOS      varchar2(5),
    COD_ESTANCIA    varchar2(2),
    FECHA           date,
    CONCEPTO        varchar2(40),
    CUANTIA         number(5,2),
    constraint PK_COD_GASTOS_GASTOS_EXT primary key (COD_GASTOS),
    constraint FK_COD_ESTANCIA_GASTOS_EXT foreign key (COD_ESTANCIA) references ESTANCIAS (CODIGO)           
);

create table ACTIVIDADES_REALIZADAS
(
    COD_ESTANCIA    varchar2(2),
    COD_ACTIVIDAD   varchar2(7),
    FECHA           date,
    NUM_PERSONAS    number default 1,
    ABONADO         number(1),
    constraint PK_COD_EST_ACT_FECHA_ACT_REALIZADAS primary key (COD_ESTANCIA, COD_ACTIVIDAD, FECHA),
    constraint FK_COD_ESTANCIA_ACT_REALIZADAS foreign key (COD_ESTANCIA) references ESTANCIAS (CODIGO),
    constraint FK_COD_ACT_ACT_REALIZADAS foreign key (COD_ACTIVIDAD) references ACTIVIDADES (CODIGO),
    constraint FORMAT_FECHA_ACT_REALIZADAS check (to_char(FECHA, 'day') != 'Lunes'),
    constraint FORMAT2_FECHA_ACT_REALIZADAS check (to_char(FECHA, 'HH24:MI') not between '00:00' and '05:59')
);

create table FACTURAS
(
    NUMERO          varchar2(5),
    COD_ESTANCIA    varchar2(2),
    FECHA           date,
    constraint PK_NUMERO_FAC primary key (NUMERO), 
    constraint FK_COD_EST_FAC foreign key (COD_ESTANCIA) references ESTANCIAS (CODIGO)
);