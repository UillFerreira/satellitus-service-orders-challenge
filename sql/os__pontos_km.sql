-- Retorna a distância em quilômetros entre dois pontos
-- Pesquisei essa função que faz o calculo dos pontos
CREATE OR REPLACE FUNCTION os__pontos_km(
    lat1 DOUBLE PRECISION, lon1 DOUBLE PRECISION,
    lat2 DOUBLE PRECISION, lon2 DOUBLE PRECISION
) RETURNS DOUBLE PRECISION AS $$
DECLARE
    r INTEGER := 6371; -- Raio da Terra em km
    dlat DOUBLE PRECISION;
    dlon DOUBLE PRECISION;
    a DOUBLE PRECISION;
    c DOUBLE PRECISION;
BEGIN
    dlat := radians(lat2 - lat1);
    dlon := radians(lon2 - lon1);

    a := sin(dlat / 2)^2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2)^2;
    c := 2 * atan2(sqrt(a), sqrt(1 - a));

    RETURN r * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
