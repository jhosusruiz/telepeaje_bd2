CREATE TABLE Categoria_Vehiculos (
    id_categoria     SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL UNIQUE,
    tarifa_base      NUMERIC(10,2) NOT NULL CHECK (tarifa_base > 0),
    ejes             SMALLINT NOT NULL CHECK (ejes > 0)
);

CREATE TABLE Estaciones_Peaje (
    id_estacion      SERIAL PRIMARY KEY,
    nombre_estacion  VARCHAR(100) NOT NULL,
    ubicacion_via    VARCHAR(150) NOT NULL,
    carriles_activos SMALLINT NOT NULL CHECK (carriles_activos > 0)
);

CREATE TABLE Propietarios (
    id_propietario   SERIAL PRIMARY KEY,
    documento_id     VARCHAR(20) NOT NULL UNIQUE,
    nombre_completo  VARCHAR(150) NOT NULL,
    correo           VARCHAR(150) UNIQUE,
    telefono         VARCHAR(20),
    fecha_registro   DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE Vehiculos (
    placa          VARCHAR(10) PRIMARY KEY,
    id_propietario INT NOT NULL REFERENCES Propietarios(id_propietario),
    id_categoria   INT NOT NULL REFERENCES Categoria_Vehiculos(id_categoria),
    marca          VARCHAR(50) NOT NULL,
    modelo         VARCHAR(50) NOT NULL
);

CREATE TABLE Tags_Telepeaje (
    id_tag          SERIAL PRIMARY KEY,
    codigo_tag_rfid VARCHAR(30) NOT NULL UNIQUE,
    placa_vehiculo  VARCHAR(10) NOT NULL REFERENCES Vehiculos(placa),
    saldo           NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (saldo >= 0),
    estado          VARCHAR(15) NOT NULL DEFAULT 'ACTIVO'
                     CHECK (estado IN ('ACTIVO', 'BLOQUEADO', 'INACTIVO'))
);

CREATE TABLE Pasos_Peaje (
    id_paso        BIGSERIAL PRIMARY KEY,
    id_tag         INT NOT NULL REFERENCES Tags_Telepeaje(id_tag),
    id_estacion    INT NOT NULL REFERENCES Estaciones_Peaje(id_estacion),
    monto_cobrado  NUMERIC(10,2) NOT NULL CHECK (monto_cobrado > 0),
    fecha_paso     TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_pasos_peaje_id_tag ON Pasos_Peaje(id_tag);

CREATE TABLE Auditoria_Tags (
    id_auditoria      BIGSERIAL PRIMARY KEY,
    id_tag            INT NOT NULL REFERENCES Tags_Telepeaje(id_tag),
    operacion         VARCHAR(10) NOT NULL,
    usuario_bd        VARCHAR(50) NOT NULL,
    fecha_hora        TIMESTAMP NOT NULL DEFAULT now(),
    datos_anteriores  JSONB,
    datos_nuevos      JSONB
);
