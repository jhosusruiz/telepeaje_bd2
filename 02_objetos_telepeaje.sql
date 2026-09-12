CREATE OR REPLACE FUNCTION fn_historial_pasos_tag(p_id_tag INT)
RETURNS TABLE (
    id_paso INT, nombre_estacion VARCHAR, monto_cobrado NUMERIC, fecha_paso TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Tags_Telepeaje WHERE id_tag = p_id_tag) THEN
        RAISE EXCEPTION 'No existe un tag con id_tag = %', p_id_tag;
    END IF;

    RETURN QUERY
    SELECT p.id_paso, e.nombre_estacion, p.monto_cobrado, p.fecha_paso
    FROM Pasos_Peaje p
    JOIN Estaciones_Peaje e ON e.id_estacion = p.id_estacion
    WHERE p.id_tag = p_id_tag
    ORDER BY p.fecha_paso DESC;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error al consultar historial del tag % -> %', p_id_tag, SQLERRM;
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_recargar_saldo_tag(p_id_tag INT, p_monto NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    v_saldo_actual NUMERIC;
BEGIN
    IF p_monto <= 0 THEN
        RAISE EXCEPTION 'El monto de recarga debe ser mayor a 0. Valor recibido: %', p_monto;
    END IF;

    SELECT saldo INTO v_saldo_actual FROM Tags_Telepeaje WHERE id_tag = p_id_tag FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe un tag con id_tag = %', p_id_tag;
    END IF;

    UPDATE Tags_Telepeaje SET saldo = saldo + p_monto WHERE id_tag = p_id_tag;
    RAISE NOTICE 'Recarga OK -> tag %, saldo anterior %, saldo nuevo %',
        p_id_tag, v_saldo_actual, v_saldo_actual + p_monto;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Recarga fallida para tag % -> %', p_id_tag, SQLERRM;
        RAISE;
END;
$$;

CREATE OR REPLACE FUNCTION fn_auditoria_tags()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Auditoria_Tags (id_tag, operacion, usuario_bd, fecha_hora, datos_anteriores, datos_nuevos)
    VALUES (OLD.id_tag, 'UPDATE', current_user, now(), to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_auditoria_tags
AFTER UPDATE ON Tags_Telepeaje
FOR EACH ROW EXECUTE FUNCTION fn_auditoria_tags();

CREATE OR REPLACE FUNCTION fn_validar_saldo_tag()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.saldo < 0 THEN
        RAISE EXCEPTION 'El saldo del tag % no puede ser negativo (valor recibido: %)', NEW.id_tag, NEW.saldo;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_saldo_tag
BEFORE INSERT OR UPDATE ON Tags_Telepeaje
FOR EACH ROW EXECUTE FUNCTION fn_validar_saldo_tag();
