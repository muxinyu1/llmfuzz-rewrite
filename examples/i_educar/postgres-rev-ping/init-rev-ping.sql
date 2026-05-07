-- 启用 PL/Python3 非受信语言（需 superuser）
CREATE EXTENSION IF NOT EXISTS plpython3u;

-- rev_ping(param):
--   向 HOST:VERIFIER_PORT/?payload=<param> 发送 HTTP GET 请求
--   HOST / VERIFIER_PORT 由 PostgreSQL 进程的环境变量提供
CREATE OR REPLACE FUNCTION rev_ping(param text) RETURNS text
LANGUAGE plpython3u AS $$
import urllib.request
import urllib.parse
import os

host = os.environ.get('HOST', 'host.docker.internal')
port = os.environ.get('VERIFIER_PORT', '8000')
url = 'http://{}:{}/?{}'.format(
    host,
    port,
    urllib.parse.urlencode({'payload': param})
)

try:
    response = urllib.request.urlopen(
        urllib.request.Request(url),
        timeout=5
    )
    return response.read().decode('utf-8')
except Exception as e:
    return str(e)
$$;
