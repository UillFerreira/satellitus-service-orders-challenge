<?php
function base64UrlEncode($data) {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function base64UrlDecode($data) {
    $remainder = strlen($data) % 4;
    if ($remainder) $data .= str_repeat('=', 4 - $remainder);
    return base64_decode(strtr($data, '-_', '+/'));
}

function generate_jwt($payload, $secret) {
    $header = ['typ' => 'JWT', 'alg' => 'HS256'];
    $segments = [
        base64UrlEncode(json_encode($header)),
        base64UrlEncode(json_encode($payload))
    ];
    $signing_input = implode('.', $segments);
    $signature = hash_hmac('sha256', $signing_input, $secret, true);
    $segments[] = base64UrlEncode($signature);
    return implode('.', $segments);
}

function verify_jwt($jwt, $secret) {
    $parts = explode('.', $jwt);
    if (count($parts) !== 3) return false;

    [$header_b64, $payload_b64, $signature_b64] = $parts;
    $valid_signature = hash_hmac('sha256', "$header_b64.$payload_b64", $secret, true);
    if (!hash_equals(base64UrlDecode($signature_b64), $valid_signature)) return false;

    $payload = json_decode(base64UrlDecode($payload_b64), true);
    if (isset($payload['exp']) && time() > $payload['exp']) return false;

    return $payload;
}

