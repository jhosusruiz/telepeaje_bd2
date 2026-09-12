INSERT INTO Categoria_Vehiculos (nombre_categoria, tarifa_base, ejes) VALUES
    ('Moto', 2000, 2), ('Automóvil', 8000, 2), ('Camioneta', 10000, 2),
    ('Bus', 15000, 3), ('Camión 2 ejes', 18000, 2), ('Camión 3+ ejes', 25000, 4);

INSERT INTO Estaciones_Peaje (nombre_estacion, ubicacion_via, carriles_activos) VALUES
    ('Peaje Norte', 'Autopista Norte km 12', 4),
    ('Peaje Sur', 'Autopista Sur km 8', 3),
    ('Peaje Occidente', 'Vía al Pacífico km 20', 3),
    ('Peaje Oriente', 'Vía al Llano km 15', 2),
    ('Peaje Centro', 'Autopista Central km 5', 5),
    ('Peaje La Línea', 'Vía La Línea km 30', 2);

INSERT INTO Propietarios (documento_id, nombre_completo, correo, telefono, fecha_registro)
SELECT '10' || lpad(i::text, 8, '0'), 'Propietario ' || i,
       'propietario' || i || '@correo.com',
       '300' || lpad((floor(random() * 9999999))::text, 7, '0'),
       CURRENT_DATE - (floor(random() * 1000))::int
FROM generate_series(1, 2000) AS i;

INSERT INTO Vehiculos (placa, id_propietario, id_categoria, marca, modelo)
SELECT 'VHC' || lpad(i::text, 6, '0'),
       (floor(random() * 2000) + 1)::int,
       (floor(random() * 6) + 1)::int,
       (ARRAY['Toyota','Chevrolet','Renault','Mazda','Kia','Ford'])[floor(random() * 6) + 1],
       (ARRAY['Modelo A','Modelo B','Modelo C','Modelo D'])[floor(random() * 4) + 1]
FROM generate_series(1, 3000) AS i;

INSERT INTO Tags_Telepeaje (codigo_tag_rfid, placa_vehiculo, saldo, estado)
SELECT 'RFID' || lpad(i::text, 8, '0'), 'VHC' || lpad(i::text, 6, '0'),
       (floor(random() * 100000))::numeric / 100,
       (ARRAY['ACTIVO','ACTIVO','ACTIVO','BLOQUEADO','INACTIVO'])[floor(random() * 5) + 1]
FROM generate_series(1, 3000) AS i;

INSERT INTO Pasos_Peaje (id_tag, id_estacion, monto_cobrado, fecha_paso)
SELECT (floor(random() * 3000) + 1)::int,
       (floor(random() * 6) + 1)::int,
       (floor(random() * 23000) + 2000)::numeric,
       now() - (random() * interval '90 days')
FROM generate_series(1, 60000) AS i;
