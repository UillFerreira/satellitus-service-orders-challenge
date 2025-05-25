-- Retorna a distância em quilômetros entre dois pontos
-- Pesquisei essa função que faz o calculo dos pontos
-- A função rece os pontos da OS (os_lat e os_lon) e os pontos do técnico (tec_lat, tec_lon)
CREATE OR REPLACE FUNCTION os__pontos_km(
    os_lat DOUBLE PRECISION, os_lon DOUBLE PRECISION,
    tec_lat DOUBLE PRECISION, tec_lon DOUBLE PRECISION
) RETURNS DOUBLE PRECISION AS $$
DECLARE
    r INTEGER := 6371; -- Raio da Terra em km
    dlat DOUBLE PRECISION;
    dlon DOUBLE PRECISION;
    a DOUBLE PRECISION;
    c DOUBLE PRECISION;
BEGIN
    dlat := radians(tec_lat - os_lat);
    dlon := radians(tec_lon - os_lon);

    a := sin(dlat / 2)^2 + cos(radians(os_lat)) * cos(radians(tec_lat)) * sin(dlon / 2)^2;
    c := 2 * atan2(sqrt(a), sqrt(1 - a));

    RETURN r * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
